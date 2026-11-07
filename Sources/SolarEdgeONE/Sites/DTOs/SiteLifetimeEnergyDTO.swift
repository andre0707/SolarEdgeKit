//
//  SiteLifetimeEnergyDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SiteLifetimeEnergyDTO: Codable {
    let energy: Double
    let unit: String
    let lastUpdateTime: String
}


extension SiteLifetimeEnergyDTO {
    var entity: Monitoring.SiteLifetimeEnergy {
        get throws {
            guard let unit = Monitoring.Energy(rawValue: unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown energy unit for field 'unit'. Value: \(self.unit)")
            }
            guard let lastUpdateTime = DateFormatter.iso8601FormattedDate(from: lastUpdateTime) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'lastUpdateTime'. Value: \(self.lastUpdateTime)")
            }

            return Monitoring.SiteLifetimeEnergy(energy: energy, unit: unit, lastUpdateTime: lastUpdateTime)
        }
    }
}
