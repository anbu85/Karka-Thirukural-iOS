//
//  Couplet+CoreDataProperties.swift
//  Thirukural
//
//  Created by Anbarasu S on 28/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//
//

import Foundation
import CoreData


extension CDCouplet: Identifiable {

    @nonobjc public class func allObjectsFetchRequest() -> NSFetchRequest<CDCouplet> {
        let request = CDCouplet.fetchRequest() as! NSFetchRequest<CDCouplet>
        request.sortDescriptors = [NSSortDescriptor(key: "coupletIndex", ascending: true)]
        return request
    }

    func parentChapterForCouplet(_ couplet: CDCouplet, fromMOC moc: NSManagedObjectContext) -> CDChapter? {

        let reminder = couplet.coupletIndex%10
        var chapterIndex: Int16
        if reminder > 0 {
            chapterIndex = (coupletIndex-reminder)/10 + 1
        } else {
            chapterIndex = (coupletIndex-reminder)/10
        }

        let request = CDChapter.fetchRequest() as! NSFetchRequest<CDChapter>
        request.sortDescriptors = [NSSortDescriptor(key: "chapterIndex", ascending: true)]
        request.predicate = NSPredicate(format: "chapterIndex = %@", chapterIndex)

        do {
            let objects = try moc.fetch(request)
            if let validObject = objects.first {
                return validObject
            } else {
                return CDChapter(context: moc)
            }
        }   catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                return nil
        }
    }

    @nonobjc public class func fetchCoupletWithRecordname(_ recordName: String, fromMOC moc:NSManagedObjectContext) -> CDCouplet? {
        let request = CDCouplet.fetchRequest() as! NSFetchRequest<CDCouplet>
        request.sortDescriptors = [NSSortDescriptor(key: "coupletIndex", ascending: true)]
        request.predicate = NSPredicate(format: "recordName = %@", recordName)

        do {
          let objects = try moc.fetch(request)

            if let validObject = objects.first {
                return validObject
            } else {
                return CDCouplet(context: moc)
            }

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }

    }



    @NSManaged public var recordName: String
    @NSManaged public var coupletIndex: Int16
    @NSManaged public var coupletTamil: String
    @NSManaged public var parimelazhagarExplanation: String

    public var id: String {
        return recordName
    }

    
    

}


// properties in relation to local persistance
extension CDCouplet {

    public var fileName: String {
        return String(format: "%04d.md", self.coupletIndex)
    }

    public var gitHubURL: URL {
        return URL(string: "https://raw.githubusercontent.com/anbarasu0504/UyarValluvam/master/%E0%AE%95%E0%AF%81%E0%AE%B1%E0%AE%B3%E0%AF%8D/\(fileName)")!
    }

}
