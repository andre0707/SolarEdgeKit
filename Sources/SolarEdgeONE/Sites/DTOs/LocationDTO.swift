//
//  LocationDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

struct LocationDTO: Codable {
    let address: String
    let city: String
    let state: String
    let zip: String?
    let country: String
}

extension LocationDTO {
    var entity: Monitoring.Location {
        Monitoring.Location(address: address,
                 city: city,
                 state: state,
                 zip: zip,
                 country: country)
    }
}
