//
//  QiblaRoutes.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/10/22.
//

import Foundation
import CoreLocation

enum QiblaRoutes: RestRequest {
    case qiblaDirection(coordinate: CLLocationCoordinate2D)

    var baseURL: URL {
        return URL(string: "https://api.aladhan.com")!
    }
    
    var parameters: [URLQueryItem]? {
        nil
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .qiblaDirection:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .qiblaDirection(let coordinate):
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            return "/v1/qibla/\(latitude)/\(longitude)"
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
      //  url.queryItems = parameters
        var request = URLRequest(url: url.url!)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        for (k, v) in headers {
          request.setValue(k, forHTTPHeaderField: v)
        }
        return request
    }
}
