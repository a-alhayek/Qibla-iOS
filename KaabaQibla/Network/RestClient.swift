//
//  RestClient.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/10/22.
//

import Foundation
import Combine
import CoreLocation

enum NetworkError: Error {
  case statusCode
  case decoding
  case unknown(Error)

  static func map(_ error: Error) -> NetworkError {
    return (error as? NetworkError) ?? .unknown(error)
  }
}

final class RestClient {
  private let restPerformer: RestPerformer

  public init(restPerformer: RestPerformer = RestPerformerImp()) {
    self.restPerformer = restPerformer
  }

  public func preform<T: Decodable>(req: RestRequest) -> AnyPublisher<T, NetworkError> {
      return restPerformer.response(req: req.urlRequest).map(\.data)
          .decode(type: T.self, decoder: JSONDecoder()).mapError { NetworkError.map($0) }.eraseToAnyPublisher()
  }
}

protocol QiblaClient {
    func getQibla(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<KaabaHeading, NetworkError>
}

final class QiblaClientImp: QiblaClient {
    let restClient: RestClient

    init(restClient: RestClient = RestClient()) {
        self.restClient = restClient
    }
  
    func getQibla(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<KaabaHeading, NetworkError> {
      restClient.preform(req: QiblaRoutes.qiblaDirection(coordinate: coordinate)).eraseToAnyPublisher()
  }
  
}
