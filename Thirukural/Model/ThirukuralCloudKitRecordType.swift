//
//  RecordType.swift
//  Thirukural
//
//  Created by Anbarasu S on 28/03/20.
//  Copyright © 2020 Uyar Valluvam. All rights reserved.
//

import Foundation
import CloudKit

enum ThirukuralCloudKitRecordType: String {
    case CKSection
    case CKSubSection
    case CKChapter
    case CKCouplet
    case CKCoupletAudio
    case CKCoupletVideo
    case CKFavourites

    var recordName: String {
        switch self {
        case .CKSection: return "Section"
        case .CKSubSection: return "SubSection"
        case .CKChapter: return "Chapter"
        case .CKCouplet: return "Couplet"
        case .CKCoupletAudio: return "CoupletAudio"
        case .CKCoupletVideo: return "CoupletVideo"
        case .CKFavourites: return "Favourites"
        }
    }

    var tamilName: String {
        switch self {
        case .CKSection: return "பால்"
        case .CKSubSection: return "இயல்"
        case .CKChapter: return "அதிகாரம்"
        case .CKCouplet: return "குறள்"
        case .CKCoupletAudio: return ""
        case .CKCoupletVideo: return ""
        case .CKFavourites: return ""
        }
    }

    var zoneID: CKRecordZone.ID? {
        switch self {
        case .CKFavourites: return CKRecordZone.ID(zoneName: "\(self.recordName)Zone", ownerName: CKCurrentUserDefaultName)
        default: return nil
        }
    }

    var zone: CKRecordZone {
        switch self {
        case .CKFavourites: return CKRecordZone(zoneID: self.zoneID!)
        default: return CKRecordZone.default()
        }
    }

    var database: CKDatabase {
        switch self {
        case .CKFavourites: return CKContainer.default().privateCloudDatabase
        default: return CKContainer.default().publicCloudDatabase
        }
    }

    var subscription: CKSubscription {

        let subscriptionID = "\(self.recordName)Subscription"

        var subscription: CKSubscription!

        switch self {
        case .CKFavourites:
              subscription = CKRecordZoneSubscription(zoneID: self.zoneID!, subscriptionID: subscriptionID)
        default:
            let options = CKQuerySubscription.Options.firesOnRecordCreation
                .union(CKQuerySubscription.Options.firesOnRecordDeletion)
                .union(CKQuerySubscription.Options.firesOnRecordUpdate)

            let predicate = NSPredicate(value: true)
            subscription = CKQuerySubscription(recordType: self.recordName, predicate: predicate, subscriptionID: subscriptionID, options: options)
            break
        }

        subscription.notificationInfo = CKSubscription.NotificationInfo()
        subscription.notificationInfo?.alertBody = ""
        subscription.notificationInfo?.shouldSendContentAvailable = true

        return subscription
    }

    var subscriptionUserDefaultsKey: String {
        return "isReallySubscribedTo\(self.recordName)"
    }

    var maxCount: Int {
        switch self {
        case .CKSection: return 3
        case .CKSubSection: return 10
        case .CKChapter: return 133
        case .CKCouplet: return 1330
        case .CKCoupletAudio: return 1330
        case .CKCoupletVideo: return 0
        case .CKFavourites: return 0
        }
    }

}

