//
//  PrayerTimeRouter.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/19/22.
//

import Foundation

enum PrayerTimeRouter: RestRequest {
    case prayerTimes(lat: Double, long: Double, method: PrayerTimeMehod)
    
    var baseURL: URL {
        API.Aladhan.url
    }
    
    var parameters: [URLQueryItem]? {
        switch self {
        case .prayerTimes(let lat, let long, let method):
            return [URLQueryItem(name: "latitude", value: String(lat)),
                    URLQueryItem.init(name: "longitude", value: String(long)),
                    URLQueryItem.init(name: "method", value: String(method.rawValue))]
        }
    }

    var httpMethod: HttpMethod {
        switch self {
        case .prayerTimes:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .prayerTimes:
            let aladhanDateFormmater = AladhanDateFormatter()
            let aladhanDate = aladhanDateFormmater.getAladhanString(from: Date())
            return "/v1/timings/\(aladhanDate)"
        }
    }
    
    var body: Data? {
        nil
    }
    
    var headers: [String : String] {
        [:]
    }
    
    var urlRequest: URLRequest {
        var url = URLComponents.init(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)!
        url.queryItems = parameters
        var request = URLRequest(url: url.url!)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        for (k, v) in headers {
          request.setValue(k, forHTTPHeaderField: v)
        }
        return request
    }
}
