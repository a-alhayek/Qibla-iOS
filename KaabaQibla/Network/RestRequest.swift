//
//  RestRequest.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/10/22.
//

import Foundation

protocol RestRequest {
  var urlRequest: URLRequest { get }
  var baseURL: URL { get }
  var parameters: [URLQueryItem]? { get }
  var httpMethod: HttpMethod { get }
  var path: String { get }
  var body: Data? { get }
  var headers: [String: String] { get }
}

public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}
