//
//  KaabaHeading.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/10/22.
//

import Foundation

struct KaabaHeading: Decodable {
    let code: Int
    let status: String
    let data: KaabaHeadingData
}

struct KaabaHeadingData: Decodable {
    let latitude: Double
    let longitude: Double
    let direction: Double
}
