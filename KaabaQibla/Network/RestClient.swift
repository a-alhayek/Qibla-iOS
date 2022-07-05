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
    case apiError(message: String)
    case unknown(Error)


    static func map(_ error: Error) -> NetworkError {
        return (error as? NetworkError) ?? .unknown(error)
    }

    var description: String {
        switch self {
        case .statusCode(let code):
            return "failure With Status Code \(code)"
        case .decoding(decodingError: let decodingError):
            return decodingError.errorDescription ?? decodingError.localizedDescription
        case .unknown(let error):
            return error.localizedDescription
        case .apiError(let messgae):
            return messgae
        }
    }

    var errorDescription: String? {
        return description
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
              if let error = error as? RestPerformerError {
                  return .apiError(message: error.localizedDescription)
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
    func getPrayerTime(latitude: Double, longtitude: Double, method: PrayerTimeMehod, date: String) -> AnyPublisher<AladahnTimeResponse, NetworkError>
}

final class PrayerTimeClientImp: PrayerTimeClient {
    let restClient: RestClient

    init(restClient: RestClient = RestClient()) {
        self.restClient = restClient
    }

    func getPrayerTime(latitude: Double, longtitude: Double, method: PrayerTimeMehod, date: String) -> AnyPublisher<AladahnTimeResponse, NetworkError> {
        restClient.preform(req: PrayerTimeRouter.prayerTimes(lat: latitude, long: longtitude, method: method, date: date))
    }

    func getPrayerTimeByMonth(latitude: Double, longtitude: Double, method: PrayerTimeMehod) -> AnyPublisher<AladahnCalenderResponse, NetworkError> {
        let date = Date()
        let dateFormmater = AladhanDateFormatter()
        let year = dateFormmater.getYear(from: date)
        let month = dateFormmater.getMonth(from: date)
        return restClient.preform(req: PrayerTimeRouter.prayerTimesByMonth(lat: latitude, long: longtitude, method: method,
                                                                    month: month, year: year))
    }
}
