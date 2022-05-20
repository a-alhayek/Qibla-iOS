//
//  API.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/19/22.
//

import Foundation

enum API {
    case Aladhan

    var url: URL {
        switch self {
        case .Aladhan:
            return URL(string: "https://api.aladhan.com")!
        }
    }
}
