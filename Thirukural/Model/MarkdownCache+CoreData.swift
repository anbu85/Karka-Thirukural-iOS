//
//  MarkdownCache+CoreData.swift
//  Thirukural
//

import CoreData
import Foundation

@objc(CDMarkdownCache)
public final class CDMarkdownCache: NSManagedObject {
    @NSManaged public var resourceURL: String
    @NSManaged public var eTag: String?
    @NSManaged public var lastModified: String?
    @NSManaged public var lastChecked: Date?
    @NSManaged public var lastUpdated: Date?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMarkdownCache> {
        NSFetchRequest<CDMarkdownCache>(entityName: "CDMarkdownCache")
    }

    static func record(
        for resourceURL: URL,
        in context: NSManagedObjectContext,
        createIfNeeded: Bool
    ) -> CDMarkdownCache? {
        let request = fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "resourceURL == %@",
            resourceURL.absoluteString
        )

        if let existingRecord = try? context.fetch(request).first {
            return existingRecord
        }

        guard createIfNeeded else {
            return nil
        }

        let record = CDMarkdownCache(context: context)
        record.resourceURL = resourceURL.absoluteString
        return record
    }
}
