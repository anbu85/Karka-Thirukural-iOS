//
//  CloudKitToCoreDataHandler.swift
//  Thirukural
//
//  Created by Anbarasu S on 28/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import Foundation
import CoreData
import CloudKit
import UIKit

protocol CloudKitToCoreDataHandler {

}

extension CloudKitToCoreDataHandler {

    


    func isInitialDataFromCloudKitDownloadedtoMOC(_ moc:NSManagedObjectContext) -> Bool {

        let isDownloadDone = isCompleteChapterDownloadedOnMOC(moc) && isCompleteSubSectionDownloadedOnMOC(moc) && isCompleteChapterDownloadedOnMOC(moc) && isCompleteCoupletDownloadedOnMOC(moc)

        return isDownloadDone
    }

    func deleteRecord(_ recordID: CKRecord.ID) {

    }

    func moc() -> NSManagedObjectContext {
        
        let app = UIApplication.shared.delegate as! AppDelegate
        let moc = app.persistentContainer.viewContext
        return moc
    }

    

    func addRecordToCoreData(_ record: CKRecord,_ moc: NSManagedObjectContext, completionBlock: (_ success: Bool) -> ()) {

        switch record.recordType {
        case ThirukuralCloudKitRecordType.CKSection.recordName:
            addSectionToStoreFromRecord(record, moc, completionBlock: completionBlock)
        case ThirukuralCloudKitRecordType.CKSubSection.recordName:
            addSubSectionToStoreFromRecord(record, moc, completionBlock: completionBlock)
        case ThirukuralCloudKitRecordType.CKChapter.recordName:
            addChapterToStoreFromRecord(record, moc, completionBlock: completionBlock)
        case ThirukuralCloudKitRecordType.CKCouplet.recordName:
            addCoupletToStoreFromRecord(record, moc, completionBlock: completionBlock)
//        case RecordType.Favourites.rawValue:
//            updateFavouriteStautsOnCoupletFromRecord(record)
//        case RecordType.CoupletVideo.rawValue:
//            addCoupletVideoToStoreFromRecord(record, completionBlock: completionBlock)
        default:
            prettyPrint("Record \(record) from cloudkit is not handled")
        }
    }

/*
    func processSubscriptionToRealm(_ subscription: CKSubscription, completionBlock: (_ success: Bool) -> ()) {

        let aSubscription = RSubscription.subscriptionObject(fromRealm: encryptedRealm()!)

        try! encryptedRealm()!.write {
            switch subscription.subscriptionID {
            case RecordType.Section.subscription.subscriptionID: aSubscription.isSectionCloudKitChangesSubscribed = true
            case RecordType.SubSection.subscription.subscriptionID: aSubscription.isSubSectionCloudKitChangesSubscribed = true
            case RecordType.Chapter.subscription.subscriptionID: aSubscription.isChapterCloudkitChangesSubscribed = true
            case RecordType.Couplet.subscription.subscriptionID: aSubscription.isCoupletCloudkitChangesSubscribed = true
            case RecordType.Favourites.subscription.subscriptionID: aSubscription.isFavouriteCloudkitChangesSubscribed = true
            case RecordType.CoupletVideo.subscription.subscriptionID: aSubscription.isCoupletVideoCloudKitChangesSubscribed = true

            default:
                break
            }
        }

    }
*/



    func addSectionToStoreFromRecord(_ record: CKRecord,_ moc: NSManagedObjectContext , completionBlock: (_ success: Bool) -> ()) {


        guard let object = CDSection.fetchSectionWithRecordName(record.recordID.recordName, fromMOC: moc) else {
            return
        }
        object.recordName = record.recordID.recordName
        object.sectionIndex = unwrapedInt16ForKey(SectionKeys.sectionNumber, onRecord: record)
        object.sectionTamil = unwrapedStringForKey(SectionKeys.sectionTamil, onRecord: record)

        do {
            try moc.save()
        } catch {
            print(error)
        }

    }


    func addSubSectionToStoreFromRecord(_ record: CKRecord,_ moc: NSManagedObjectContext, completionBlock: (_ success: Bool) -> ()) {

        guard let object = CDSubSection.fetchSubSectionWithRecordname(record.recordID.recordName, fromMOC: moc) else {
            return
        }

        object.recordName = record.recordID.recordName
        object.subSectionIndex = unwrapedInt16ForKey(SubSectionKeys.subSectionNumber, onRecord: record)
        object.subSectionTamil = unwrapedStringForKey(SubSectionKeys.subSectionTamil, onRecord: record)
        object.parentSection = unwrapedStringForKey(SubSectionKeys.parentSectionID, onRecord: record)

        do {
            try moc.save()
        } catch {
            print(error)
        }

    }

    func addChapterToStoreFromRecord(_ record: CKRecord,_ moc:NSManagedObjectContext, completionBlock: (_ success: Bool) -> ()) {

        guard let object = CDChapter.fetchChapterWithRecordname(record.recordID.recordName, fromMOC: moc) else {
            return
        }

        object.recordName = record.recordID.recordName
        object.chapterIndex = unwrapedInt16ForKey(ChapterKeys.chapterNumber, onRecord: record)
        object.chapterTamil = unwrapedStringForKey(ChapterKeys.chapterTamil, onRecord: record)
        object.parentSubSection = unwrapedStringForKey(ChapterKeys.parentSubSectionID, onRecord: record)

        do {
            try moc.save()
        } catch {
            print(error)
        }

    }

    func addCoupletToStoreFromRecord(_ record: CKRecord,_ moc:NSManagedObjectContext, completionBlock: (_ success: Bool) -> ()) {

        guard let object = CDCouplet.fetchCoupletWithRecordname(record.recordID.recordName, fromMOC: moc) else {
            return
        }

        object.recordName = record.recordID.recordName
        object.coupletIndex = unwrapedInt16ForKey(CoupletKeys.coupletNo, onRecord: record)
        object.coupletTamil = unwrapedStringForKey(CoupletKeys.coupletTamil, onRecord: record)
        object.parimelazhagarExplanation = unwrapedStringForKey(CoupletKeys.parimelazhagarExpln, onRecord: record)

        do {
            try moc.save()
        } catch {
            print(error)
        }

    }

//    func addCoupletVideoToStoreFromRecord(_ record: CKRecord, completionBlock: (_ success: Bool) -> ()) {
//
//        let aCoupletVideo = CoupletVideo()
//
//        aCoupletVideo.recordName = record.recordID.recordName
//        aCoupletVideo.coupletIndex = unwrapedIntForKey("coupletNo", onRecord: record)
//        aCoupletVideo.startTime = unwrapedIntForKey("startTime", onRecord: record)
//        aCoupletVideo.endTime = unwrapedIntForKey("endTime", onRecord: record)
//        aCoupletVideo.url = unwrapedStringForKey("url", onRecord: record)
//
//        do {
//            try moc().save()
//        } catch {
//            print(error)
//        }
//    }


//    func updateFavouriteStautsOnCoupletFromRecord(_ record: CKRecord) {
//
//        let realm = encryptedRealm()!
//
//        guard let aCouplet = RCouplet.coupletObjectmatchingFavouriteRecord(record, fromRealm: realm) else {
//            prettyPrint("unable to find article for favourite record - \(record)")
//            return
//        }
//
//
//        try! realm.write({ () -> Void in
//
//            if let modifiedDate = record.modificationDate {
//
//                if modifiedDate.compare(aCouplet.favouriteModifiedDate) == ComparisonResult.orderedDescending {
//
//                    // means server record is latest, so change bool value and also update the date
//                    if let boolValue = record.value(forKey: "isFavourite") as? Bool {
//                        aCouplet.isFavourite = boolValue
//                        aCouplet.favouriteModifiedDate = modifiedDate
//                    }
//
//                } else {
//                    aCouplet.isFavouriteInSyncWithServer = false
//                }
//            }
//
//        })
//
//    }

    func isCompleteSectionDownloadedOnMOC(_ moc: NSManagedObjectContext) -> Bool {
        return allObjectCount(ofType: CDSection.self, fromMOC: moc) == ThirukuralCloudKitRecordType.CKSection.maxCount
    }

    func isCompleteSubSectionDownloadedOnMOC(_ moc:NSManagedObjectContext) -> Bool {
        return allObjectCount(ofType: CDSubSection.self, fromMOC: moc) == ThirukuralCloudKitRecordType.CKSubSection.maxCount
    }

    func isCompleteChapterDownloadedOnMOC(_ moc: NSManagedObjectContext) -> Bool {
        return allObjectCount(ofType: CDChapter.self, fromMOC: moc) == ThirukuralCloudKitRecordType.CKChapter.maxCount
    }

    func isCompleteCoupletDownloadedOnMOC(_ moc: NSManagedObjectContext) -> Bool {
        return allObjectCount(ofType: CDCouplet.self, fromMOC: moc) == ThirukuralCloudKitRecordType.CKCouplet.maxCount
    }

    func unwrapedStringForKey(_ key: String, onRecord record: CKRecord) -> String {

        switch record.object(forKey: key) {
        case let object as String:
            return object
        case let object as CKAsset:
            do {
                 return try String(contentsOf: object.fileURL!)
            } catch let error as NSError {
                prettyPrint("\(error)")
                return ""
            }
        default:
            return ""
        }

    }


    func unwrapedIntForKey(_ key: String, onRecord record: CKRecord) -> Int {

        switch record.object(forKey: key) {
        case let object as Int:
            return object
        default:
            return 0
        }

    }



}


func prettyPrint<T>(_ object: T, _ filePath: String = #file, _ function: String = #function, _ line: Int = #line) {
    let className = (filePath as NSString).lastPathComponent
    let info = "\(className).\(function)[\(line)]:\(object)\n"
    print(info)
}

struct ChapterKeys {
    static let chapterNumber = "chapterNumber"
    static let chapterTamil = "chapterTamil"
    static let parentSubSectionID = "parentSubSectionID"
}

struct CoupletKeys  {
    static let coupletNo = "coupletNo"
    static let coupletTamil = "coupletTamil"
    static let kalaignarExpln = "kalaignarExpln"
    static let manakudavarExpln = "manakudavarExpln"
    static let pappaiahExplan = "pappaiahExplan"
    static let parimelazhagarExpln = "parimelazhagarExpln"
    static let popeCouplet = "popeCouplet"
    static let popeExpln = "popeExpln"
    static let varatharasanarExpln = "varatharasanarExpln"
}

struct  CoupletAudioKeys {
    static let kuralAudio = "kuralAudio"
    static let kuralNo = "kuralNo"
}

struct SectionKeys {
    static let sectionEnglish = "sectionEnglish"
    static let sectionFrench = "sectionFrench"
    static let sectionNumber = "sectionNumber"
    static let sectionTamil = "sectionTamil"
}

struct SubSectionKeys {
    static let parentSectionID = "parentSectionID"
    static let subSectionEnglish = "subSectionEnglish"
    static let subSectionNumber = "subSectionNumber"
    static let subSectionTamil = "subSectionTamil"
}

func unwrapedStringForKey(_ key: String, onRecord record: CKRecord) -> String {

    switch record.object(forKey: key) {
    case let object as String:
        return object
    case let object as CKAsset:
        do {
            return try String(contentsOf: object.fileURL!)
        } catch let error as NSError {
            prettyPrint("\(error)")
            return ""
        }
    default:
        return ""
    }

}


func unwrapedInt16ForKey(_ key: String, onRecord record: CKRecord) -> Int16 {

    switch record.object(forKey: key) {
    case let object as Int16:
        return object
    default:
        return 0
    }

}
