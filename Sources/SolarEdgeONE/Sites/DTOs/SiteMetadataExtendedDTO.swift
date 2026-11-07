//
//  SiteMetadataExtendedDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SiteMetadataExtendedDTO: Codable {
    let siteId: Int
    let name: String
    let accountId: Int
    let peakPower: Double
    let installationDate: String
    let lastUpdateTime: String
    let location: LocationExtendedDTO
    let activationStatus: String
    let note: String
}


extension SiteMetadataExtendedDTO {
    var entity: Monitoring.SiteDetails {
        get throws {
            guard let installationDate = CalendarDate(isoString: installationDate) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'installationDate'. Value: \(self.installationDate)")
            }
            guard let lastUpdateTime = DateFormatter.iso8601FormattedDate(from: lastUpdateTime) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'lastUpdateTime'. Value: \(self.lastUpdateTime)")
            }

            return Monitoring.SiteDetails(id: .init(rawValue: siteId),
                               name: name,
                               accountID: accountId,
                               peakPower: peakPower,
                               installationDate: installationDate,
                               lastUpdateTime: lastUpdateTime,
                               location: location.entity,
                               activationStatus: Monitoring.ActivationStatus(rawValue: activationStatus),
                               note: note)
        }
    }
}
