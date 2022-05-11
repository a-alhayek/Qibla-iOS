//
//  RestPerformer.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/10/22.
//

import Foundation
import Foundation
import Combine

public enum RestPerformerError: LocalizedError {
    case retryLimitReached
    case apiError(message: String)

    public var localizedDescription: String {
        switch self {
        case .retryLimitReached:
            return "Authentication failed"
        case .apiError(let message):
            return message
        }
    }
}

public protocol RestPerformer {
    func response(req: URLRequest) -> AnyPublisher<(response: HTTPURLResponse, data: Data), RestPerformerError>
}

extension RestPerformer {
    public var session: URLSession {
        let configuration = URLSessionConfiguration.default
        let instance = URLSession(configuration: configuration)
        return instance
    }
}

public final class RestPerformerImp: RestPerformer {
  var accessToken: String?

  public func response(req: URLRequest) -> AnyPublisher<(response: HTTPURLResponse, data: Data), RestPerformerError> {
    var token = "Bearer "
    if let accessToken = accessToken {
      token.append(accessToken)
    }
    let request = req
   // request.addValue(token, forHTTPHeaderField: "Authorization")
    return retryableResponse(request).retry(3).eraseToAnyPublisher()
  }

  private func retryableResponse(_ req: URLRequest) -> AnyPublisher<(response: HTTPURLResponse, data: Data), RestPerformerError> {
    return session.dataTaskPublisher(for: req).tryMap { (data: Data, response: URLResponse) in
      guard let response = response as? HTTPURLResponse else {
        throw RestPerformerError.apiError(message: "failed to convert response to HTTPURLResponse")
      }
      let statusCode = response.statusCode
      guard (200...299).contains(statusCode) else {
        throw RestPerformerError.apiError(message: "failed with status code \(statusCode)")
      }
      return (response, data)
      
    }.mapError { _ in RestPerformerError.apiError(message: "error") }.eraseToAnyPublisher()
  }
}
