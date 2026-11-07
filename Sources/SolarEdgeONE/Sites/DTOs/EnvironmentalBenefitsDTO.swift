//
//  EnvironmentalBenefitsDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

struct EnvironmentalBenefitsDTO: Codable {
    let co2Emissions: Double
    let evMiles: Double
    let unit: String
}

extension EnvironmentalBenefitsDTO {
    var entity: Monitoring.EnvironmentalBenefits {
        Monitoring.EnvironmentalBenefits(co2Emissions: co2Emissions,
                              evMiles: evMiles,
                              unit: Monitoring.UnitSystem(rawValue: unit) ?? .metric)
    }
}
