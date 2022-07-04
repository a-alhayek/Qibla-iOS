//
//  RealmDatabaseRepository.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/6/22.
//

import Foundation
import RealmSwift

class RealmDatabaseRepository {
    open class func makeRealm() async throws -> Realm {
        let configuration = AladahnRealmConfig.prayerTime.configuration(AladahnMigration())
        return try await Realm(configuration: configuration)
    }
}
