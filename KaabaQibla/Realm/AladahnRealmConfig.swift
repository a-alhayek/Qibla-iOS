//
//  AladahnRealmConfig.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/6/22.
//

import Foundation
import RealmSwift
import Realm
public struct RealmConstants {
    static let realmSchemaVersion: UInt64 = 0
}

enum AladahnRealmConfig: String {
    case prayerTime
    
    func configuration(_ migration: RealmMigration) -> Realm.Configuration {
        Realm.Configuration.init(fileURL: realmFileURL,
                                 schemaVersion: RealmConstants.realmSchemaVersion,
                                 migrationBlock: migration.migrationBlock,
                                 deleteRealmIfMigrationNeeded: migration.deleteRealmIfMigrationNeeded, objectTypes: migration.objectTypes)
    }

    private var realmFileURL: URL? {
        if let path = self.basePath {
            return path.appendingPathComponent("\(self.rawValue).realm")
        }
        return nil
    }

    private var basePath: URL? {
        let fileManager = FileManager.default
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

public protocol RealmMigration {
    var objectTypes: [Object.Type]? { get }
    var migrationBlock: MigrationBlock? { get }
    var deleteRealmIfMigrationNeeded: Bool { get }
}

class AladahnMigration: RealmMigration {
    let objectTypes: [Object.Type]? = [AladahnDate.self,
                                       PrayerDate.self,
                                       PrayerTime.self,
                                       AladahnPrayerTimeAndDate.self,
                                       PrayerMethod.self,
                                       Month.self,
                                       Weekday.self,
                                       GBName.self
                                       ]
    
    var migrationBlock: MigrationBlock?
    
    let deleteRealmIfMigrationNeeded: Bool = true
    
}
