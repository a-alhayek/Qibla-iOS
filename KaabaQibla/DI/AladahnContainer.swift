//
//  AladahnContainer.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/6/22.
//

import Foundation
import Swinject

let diContainer = Container { container in
    typealias PrayerTimeDB = RealmDatabaseRepository<AladahnPrayerTimeAndDate, String>
    container.register(RestPerformer.self) { _ in
        return RestPerformerImp()
    }

    container.register(RestClient.self) { resolver in
        return RestClient(restPerformer: resolver.resolve(RestPerformer.self)!)
    }

    container.register(PrayerTimeClient.self) { resolver in
        return PrayerTimeClientImp(restClient: resolver.resolve(RestClient.self)!)
    }

    container.register(PrayerTimeDB.self, name: "prayer") { resolver in
        let config = AladahnRealmConfig.prayerTime.configuration(AladahnMigration())
        return PrayerTimeDB(configuration: config, dispatchQueueLabel: "Realm.prayer.repository")
    }
}

