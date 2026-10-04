//
//  CloudkitOperator.swift
//  Thirukural
//
//  Created by Anbarasu S on 28/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import Foundation
import CloudKit
import UIKit
import CoreData

let publicDatabase = CKContainer.default().publicCloudDatabase
let privateDatabse = CKContainer.default().privateCloudDatabase

protocol CloudKitOperator: CloudKitToCoreDataHandler {

}

extension CloudKitOperator {

    func startDownloadingRecords(managedObjectContext moc: NSManagedObjectContext) {

        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated

        let recordTypes: [ThirukuralCloudKitRecordType] = [.CKSection,.CKSubSection,.CKChapter,.CKCouplet]

        for recordType in recordTypes {
            let operation = fetchAllRecordsQueryOperationForRecordType(recordType)
            operation.database = recordType.database

            performQueryOperation(operation, onOperationQueue: operationQueue,managedObjectContext: moc, completionBlock: { (success) -> () in
                if success && operation.isFinished {
//                    prettyPrint("\(recordType.tamilName) downloaded")
                }
            }) // end of performQueryOperation
        }
    }


    //MARK: - Fetching funcs

    /**
     Creates a CKQueryOperation, which can be added to any operation queue.
     The query is configured to fetch all records of the given recordType from CloudKit

     - parameter recordType: RecordType for which the query operation to be created

     - returns: CKQueryOperation, which is not added to any Operation Queue
     */
    func fetchAllRecordsQueryOperationForRecordType(_ recordType: ThirukuralCloudKitRecordType) -> CKQueryOperation {

        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType.recordName, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)

        return queryOperation
    }

    /**
     This function fetches all records of the given recordType from CloudKit.

     It creates a queryOperation and adds to a new operationQueue.
     You are not given any control over the opeation Queue

     - parameter recordType:      RecordType for which all records has to be downloaded
     - parameter completionBlock: an optional completionBlock
     */
    func fetchRecordsOfType(_ recordType: ThirukuralCloudKitRecordType,managedOjectContext moc:NSManagedObjectContext, completionBlock: ((_ success: Bool) -> ())?) {

        let predicate = NSPredicate(format: "TRUEPREDICATE", argumentArray: nil)
        let query = CKQuery(recordType: recordType.recordName, predicate: predicate)
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.database = recordType.database

        performQueryOperation(queryOperation, onOperationQueue: OperationQueue(), managedObjectContext: moc, completionBlock: completionBlock)
    }


    /**
     This function performs these blocks
     - recordFetchedBlock
     - queryCompletionBlock

     on the already configured and given CKQueryOperation.
     Finally adds the CKQueryOperation to the given operationQueue

     - parameter queryOperation:  CKQueryOperation on which the recordFetchedBlock and queryCompletionBlock to be performed
     - parameter operationQueue:  NSOperationQueue to which the queryOperation has to be added
     - parameter completionBlock: an optional completion block
     */
    func performQueryOperation(_ queryOperation: CKQueryOperation, onOperationQueue operationQueue: OperationQueue, managedObjectContext moc: NSManagedObjectContext, completionBlock: ((_ success: Bool) -> ())?) {

        //2.
        queryOperation.recordFetchedBlock = { (record: CKRecord) -> Void in
            // process each record
//            prettyPrint(record)

            DispatchQueue.main.async { // Correct
               self.addRecordToCoreData(record, moc, completionBlock: { (success) in
                   if success {
                       prettyPrint("\(record.recordID) successfully added to realm")
                   } else {
                       prettyPrint("\(record.recordID) failed to add to realm")
                   }
               })
            }

        }

        //3.
        queryOperation.queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error: Error?) -> Void in
            guard error == nil else {
                // hnadle the error
                completionBlock?(false)
                prettyPrint(error)
                return
            }

            if let queryCursor = cursor {
//                prettyPrint("got cursor -\(queryCursor) - performing next fetch")
                let queryCursorOperation = CKQueryOperation(cursor: queryCursor)
                queryCursorOperation.database = queryOperation.database
                self.performQueryOperation(queryCursorOperation, onOperationQueue: operationQueue, managedObjectContext: moc, completionBlock: completionBlock)
            }
        }

        queryOperation.completionBlock = { () -> Void in
            completionBlock?(true)
        }

        operationQueue.addOperation(queryOperation)

    }


    func fetchRecordWithRecordID(_ recordID: CKRecord.ID, isPublicDatabase: Bool, callback: ((_ success: Bool, _ record: CKRecord?) -> ())?) {

        var database: CKDatabase!

        if isPublicDatabase {
            database = publicDatabase
        } else {
            database = privateDatabse
        }

        database.fetch(withRecordID: recordID) { (record: CKRecord?, error: Error?) -> Void in
            guard error == nil else {
                prettyPrint(error)
                callback?(false, nil)
                return
            }

            if let record = record {
                callback?(true, record)
            }
        }
    }


    // MARK: - Uploading funcs

    func uploadRecords(_ recordsToUpload: [CKRecord], ofRecordType recordType:ThirukuralCloudKitRecordType, completionHandler: ((_ isUploaded: Bool) -> ())?)  {

        let uploadOperation = CKModifyRecordsOperation(recordsToSave: recordsToUpload, recordIDsToDelete: nil)

        uploadOperation.isAtomic = false
        uploadOperation.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.allKeys
        uploadOperation.database = recordType.database


        uploadOperation.modifyRecordsCompletionBlock = {
            (savedRecords: [CKRecord]?, deletedRecords: [CKRecord.ID]?, operationError: Error?) -> Void in

            guard operationError == nil else {
                // Handle the error
                prettyPrint(operationError)
                completionHandler?(false)
                return
            }

            if let records = savedRecords {
                for record in records {
                    prettyPrint("success - \(record.recordID)")

//                    if record.recordType == ThirukuralCloudKitRecordType.Favourites.rawValue {
//                        //prettyPrint("isFavourite = \(record.valueForKey(CloudKitKeys.isFavourite))")
//                    }
                }

                completionHandler?(true)
            }
        }


        OperationQueue().addOperation(uploadOperation)

    }


    //MARK:- Zone funcs

    /// creates custom zone in private database
    func ensureZonesIsCreatedForRecordType(_ recordType: ThirukuralCloudKitRecordType) {

        CKContainer.default().privateCloudDatabase.fetchAllRecordZones { (zones:[CKRecordZone]?, error:Error?) -> Void in

            guard error == nil else {
                prettyPrint(error)
                return
            }

            var isZonePresent = false

            for zone in zones! {
                prettyPrint(zone.zoneID.zoneName)
                if zone.zoneID.zoneName == recordType.recordName {
                    isZonePresent = true
                    break
                }
            }

            if isZonePresent == false {
                self.createZoneForRecordType(recordType, onOperationQueue: OperationQueue(), completionHandler: { (isCreated) in
                    if isCreated == true {
                        prettyPrint("\(recordType) successfully created")
                    }
                })
            }

        }
    }


    func createZoneForRecordType(_ recordType: ThirukuralCloudKitRecordType, onOperationQueue operationQueue: OperationQueue, completionHandler: ((_ isCreated: Bool) -> ())?) {


        let op = CKModifyRecordZonesOperation(recordZonesToSave: [recordType.zone], recordZoneIDsToDelete: nil)
        op.qualityOfService = .userInitiated
        op.database = recordType.database

        op.modifyRecordZonesCompletionBlock = { (savedRecords: [CKRecordZone]?, deletedRecordIDs: [CKRecordZone.ID]?, error: Error?) -> Void in

            guard error == nil else {
                prettyPrint(error)
                completionHandler?(false)
                return
            }

            prettyPrint(savedRecords)
            completionHandler?(true)
        }

        operationQueue.addOperation(op)
    }



}


