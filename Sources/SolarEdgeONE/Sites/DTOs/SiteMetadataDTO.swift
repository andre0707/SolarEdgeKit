//
//  SiteMetadataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SiteMetadataDTO: Codable {
    let siteId: Int
    let name: String
    let peakPower: Double
    let installationDate: String
    let location: LocationDTO
    let activationStatus: String
    let note: String
}


extension SiteMetadataDTO {
    var entity: Monitoring.Site {
        get throws {
            guard let installationDate = CalendarDate(isoString: installationDate) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'installationDate'. Value: \(self.installationDate)")
            }
            
            return Monitoring.Site(id: .init(rawValue: siteId),
                 name: name,
                 peakPower: peakPower,
                 installationDate: installationDate,
                 location: location.entity,
                 activationStatus: Monitoring.ActivationStatus(rawValue: activationStatus),
                 note: note)
        }
    }
}
