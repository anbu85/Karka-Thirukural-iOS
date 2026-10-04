//
//  Section+CoreDataProperties.swift
//  Thirukural
//
//  Created by Anbarasu S on 28/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI


extension CDSection: Identifiable {

    @nonobjc public class func allObjectsFetchRequest() -> NSFetchRequest<CDSection> {
        let request = CDSection.fetchRequest() as! NSFetchRequest<CDSection>
        request.sortDescriptors = [NSSortDescriptor(key: "sectionIndex", ascending: true)]
        return request
    }

    @nonobjc public class func fetchSectionWithRecordName(_ recordName: String, fromMOC moc: NSManagedObjectContext) -> CDSection? {
        let request = CDSection.fetchRequest() as! NSFetchRequest<CDSection>
        request.sortDescriptors = [NSSortDescriptor(key: "sectionIndex", ascending: true)]
        request.predicate = NSPredicate(format: "recordName = %@", recordName)

        do {
          let objects = try moc.fetch(request)

            if let validObject = objects.first {
                return validObject
            } else {
                return CDSection(context: moc)
            }

        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }

    }

   
    @NSManaged public var recordName: String
    @NSManaged public var sectionIndex: Int16
    @NSManaged public var sectionTamil: String

    public var id: String {
        return recordName
    }

    public var payiram: String {
        switch self.sectionIndex {
        case 1: return "இந்திரன் முதலிய இறையவர் பதங்களும்1, அந்தமிலின்பத்தழிவில் வீடும் நெறியறிந்து எய்துதற்குரிய மாந்தர்க்கு உறுதியென உயர்ந்தோரானெடுக்கப்பட்ட பொருள் நான்கு. அவை அறம், பொருள், இன்பம், வீடென்பன.2 அவற்றுள், வீடென்பது சிந்தையுமொழியுஞ் செல்லா நிலைமைத்தாகலின், துறவறமாகிய காரணவகையாற் கூறப்படுவதல்லது, இலக்கணவகையாற் கூறப்படாமையின், நூல்களாற் கூறப்படுவன ஏனைமூன்றுமேயாம்."
        case 3: return "இனி, அப்பொருளைத் துணைக்காரணமாக உடைத்தாய் இம்மையே பயப்பதாய இன்பம் கூறுவான் எடுத்துக்கொண்டார்.ஈண்டு இன்பம் என்றது ஒரு காலத்து ஒரு பொருளான் ஐம்புலனும் நுகர்தற்சிறப்புடைத்தாய காமஇன்பத்தினை.இச்சிறப்புப்பற்றி வடநூலுட் போசராசனும் சுவைபல என்று கூறுவார் கூறுக. யாம் கூறுவது இன்பச்சுவை ஒன்றனையுமே என இதனையே மிகுத்துக் கூறினான்."
        default: return ""
        }
    }

}

// properties in relation to local persistance
extension CDSection {

    public var fileName: String {
        return String(format: "%01d.md", self.sectionIndex)
    }

    // using https://www.browserling.com/tools/url-encode this to encode பால் -> %E0%AE%AA%E0%AE%BE%E0%AE%B2%E0%AF%8D
    public var gitHubURL: URL {
        return URL(string: "https://raw.githubusercontent.com/anbarasu0504/UyarValluvam/master/%E0%AE%AA%E0%AE%BE%E0%AE%B2%E0%AF%8D/\(fileName)")!
    }

}
