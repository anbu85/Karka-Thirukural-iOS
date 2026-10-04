//
//  Chapter+CoreDataProperties.swift
//  Thirukural
//
//  Created by Anbarasu S on 28/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftUI



extension CDChapter: Identifiable {

    @nonobjc public class func allObjectsFetchRequest() -> NSFetchRequest<CDChapter> {
        let request = CDChapter.fetchRequest() as! NSFetchRequest<CDChapter>
        request.sortDescriptors = [NSSortDescriptor(key: "chapterIndex", ascending: true)]
        return request
    }

    @nonobjc public class func fetchChapterWithRecordname(_ recordName: String, fromMOC moc:NSManagedObjectContext) -> CDChapter? {
        let request = CDChapter.fetchRequest() as! NSFetchRequest<CDChapter>
        request.sortDescriptors = [NSSortDescriptor(key: "chapterIndex", ascending: true)]
        request.predicate = NSPredicate(format: "recordName = %@", recordName)

        do {
          let objects = try moc.fetch(request)

            if let validObject = objects.first {
                return validObject
            } else {
                return CDChapter(context: moc)
            }

        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }

    }

    @NSManaged public var recordName: String
    @NSManaged public var chapterTamil: String
    @NSManaged public var chapterIndex: Int16
    @NSManaged public var parentSubSection: String

    public var id: String {
        return recordName
    }

    public var payiram: String {
        switch self.chapterIndex {
        case 1:
            return "அஃதாவது,கவி தான் வழிபடுகடவுளையாதல் எடுத்துக்கொண்டபொருட்கு ஏற்புடைக்கடவுளையாதல் வாழ்த்துதல். அவற்றுள், இவ்வாழ்த்து ஏற்புடைக்கடவுளையெனவறிக. என்னை? சத்துவமுதலிய குணங்களான் மூன்றாகிய உறுதிப்பொருட்கு அவற்றான் மூவராகிய முதற்கடவுளோடு இயைபுண்டாகலான்,அம்மூன்றுபொருளையுங் கூறலுற்றார்க்கு அம்மூவரையும் வாழ்த்துதல் முறைமையாகலின்,இவ்வாழ்த்து அம்மூவர்க்கும் பொதுப்படக் கூறினாரெனவுணர்க"
        case 2:
            return "அஃதாவது, அக்கடவுளதாணையான் உலகமும், அதற்குறுதியாகிய அறம்,பொருளின்பங்களும், நடத்துதற்கேதுவாகிய மழையினது சிறப்புக் கூறுதல். அதிகாரமுறைமையும் இதனானே விளங்கும்."
        case 3:
            return "அஃதாவது , முற்றத்துறந்த முனிவரது பெருமை கூறுதல். அவ்அறமுதற் பொருள்களை உலகிற்கு உள்ளவாறுணர்த்துவார் அவராகலின் , இது வான்சிறப்பின்பின் வைக்கப்பட்டது."
        case 4:
            return "அஃதாவது அம்முனிவரானுணர்த்தப்பட்ட அம்மூன்றனுள் ஏனைப்பொருளுமின்பமும் போலாது, அறன், இம்மை, மறுமை, வீடென்னும் மூன்றனையும் பயத்தலான், அவற்றின் வலியுடைத்தென்பது கூறுதல். அதிகாரமுறைமையும் இதனானே விளங்கும். 'சிறப்புடை மரபின் பொருளுமின்பமு மறத்து வழிபடூஉந் தோற்றம் போல' (புறநானுறு 31) என்றார் பிறரும்."
        case 5:
            return "அஃதாவது, இல்லாளோடு கூடி வாழ்தலினது சிறப்பு. இன்னிலை அறஞ்செய்தற்குரிய இருவகைநிலையுள் முதலாதலின், இஃதறன்வலியுறுத்தலின்பின் வைக்கப்பட்டது"
        case 6:
            return "அஃதாவது, அவ்வில்வாழ்க்கைக்குத் துணையாகிய இல்லாளது நன்மை. அதிகாரமுறைமையும் இதனானே விளங்கும்."

        default:
            return ""
        }
    }

}

// properties in relation to local persistance
extension CDChapter {

    public var imageName: String {
        let imageName = String(format: "b%03d", self.chapterIndex)
        if let _ = UIImage(named: imageName) {
            return imageName
        } else {
            return "defaultBackground"
        }
    }

    public var fileName: String {
        return String(format: "%03d.md", self.chapterIndex)
    }

    public var gitHubURL: URL {
        return URL(string: "https://raw.githubusercontent.com/anbarasu0504/UyarValluvam/master/%E0%AE%85%E0%AE%A4%E0%AE%BF%E0%AE%95%E0%AE%BE%E0%AE%B0%E0%AE%AE%E0%AF%8D/\(fileName)")!
    }

}
