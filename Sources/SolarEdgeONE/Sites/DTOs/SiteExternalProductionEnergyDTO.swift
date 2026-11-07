//
//  SiteExternalProductionEnergyDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct SiteExternalProductionEnergyDTO: Codable {
    let energyIncludingExternalSources: Double
    let energyExcludingExternalSources: Double
    let unit: String
}


extension SiteExternalProductionEnergyDTO {
    var entity: Monitoring.SiteExternalProductionEnergy {
        get throws {
            guard let unit = Monitoring.Energy(rawValue: unit) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown energy unit for field 'unit'. Value: \(self.unit)")
            }

            return Monitoring.SiteExternalProductionEnergy(energyIncludingExternalSources: energyIncludingExternalSources,
                                                energyExcludingExternalSources: energyExcludingExternalSources,
                                                unit: unit)
        }
    }
}
