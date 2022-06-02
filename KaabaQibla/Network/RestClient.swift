//
//  RestClient.swift
//  KaabaQibla
//
//  Created by ahmad alhayek on 5/10/22.
//

import Foundation
import Combine
import CoreLocation

enum NetworkError: LocalizedError, CustomStringConvertible {
    case statusCode(code: Int)
    case decoding(decodingError: DecodingError)
    case unknown(Error)


    static func map(_ error: Error) -> NetworkError {
        return (error as? NetworkError) ?? .unknown(error)
    }

    var description: String {
        switch self {
        case .statusCode(let code):
            return "failureWithStatusCode \(code)"
        case .decoding(decodingError: let decodingError):
            return decodingError.localizedDescription
        case .unknown(_):
            return "Unkown"
        }
    }
}

final class RestClient {
  private let restPerformer: RestPerformer

  public init(restPerformer: RestPerformer = RestPerformerImp()) {
    self.restPerformer = restPerformer
  }

  public func preform<T: Decodable>(req: RestRequest) -> AnyPublisher<T, NetworkError> {
      return restPerformer.response(req: req.urlRequest).map(\.data)
          .decode(type: T.self, decoder: JSONDecoder()).mapError { error in
              if let decodingError = error as? DecodingError {
                  return NetworkError.decoding(decodingError: decodingError)
              }
              return .unknown(error)
          }.eraseToAnyPublisher()
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

protocol PrayerTimeClient {
    func getPrayerTime(latitude: Double, longtitude: Double) -> AnyPublisher<AladahnTimeResponse, NetworkError>
}

final class PrayerTimeClientImp: PrayerTimeClient {
    let restClient: RestClient

    init(restClient: RestClient = RestClient()) {
        self.restClient = restClient
    }

    func getPrayerTime(latitude: Double, longtitude: Double) -> AnyPublisher<AladahnTimeResponse, NetworkError> {
        restClient.preform(req: PrayerTimeRouter.prayerTimes(lat: latitude, long: longtitude, method: .ISNA))
    }
}
