//
//  AladahnContainer.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 6/6/22.
//

import Foundation
import Swinject

let diContainer = Container { container in
    container.register(RestPerformer.self) { _ in
        return RestPerformerImp()
    }

    container.register(RestClient.self) { resolver in
        return RestClient(restPerformer: resolver.resolve(RestPerformer.self)!)
    }

    container.register(PrayerTimeClient.self) { resolver in
        return PrayerTimeClientImp(restClient: resolver.resolve(RestClient.self)!)
    }


    container.register(PrayerTimeManager.self, factory: { resolver in
        let prayerClient = resolver.resolve(PrayerTimeClient.self)!
        return PrayerTimeManagerIM(prayerClient: prayerClient)
    })
}

