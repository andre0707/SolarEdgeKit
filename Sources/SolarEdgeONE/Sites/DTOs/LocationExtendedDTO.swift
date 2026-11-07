//
//  LocationExtendedDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

struct LocationExtendedDTO: Codable {
    let address: String
    let address2: String?
    let latitude: Double
    let longitude: Double
    let city: String
    let state: String
    let stateCode: String?
    let zip: String?
    let country: String
    let countryCode: String
    let timezone: String
}

extension LocationExtendedDTO {
    var entity: Monitoring.LocationExtended {
        Monitoring.LocationExtended(address: address,
                         address2: address2,
                         latitude: latitude,
                         longitude: longitude,
                         city: city,
                         state: state,
                         stateCode: stateCode,
                         zip: zip,
                         country: country,
                         countryCode: countryCode,
                         timezone: TimeZone(identifier: timezone))
    }
}
