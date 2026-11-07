//
//  MeasurementsDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct MeasurementsDTO: Codable {
    let period: PeriodDTO
    let unit: String
    let resolution: String
    let values: [MeasurementDTO]
}


extension MeasurementsDTO {
    /// Maps to an entity whose unit must be one of `UnitType`'s cases,
    /// e.g. ``Monitoring/Power`` for a power endpoint.
    func entity<UnitType>(unit _: UnitType.Type) throws -> Monitoring.Measurements<UnitType> {
        guard let unit = UnitType(rawValue: unit) else {
            throw SolarEdgeError.decodingWithMessage(message: "Unexpected unit for field 'unit'. Value: \(self.unit)")
        }
        guard let resolution = Monitoring.Resolution(rawValue: resolution) else {
            throw SolarEdgeError.decodingWithMessage(message: "Unknown resolution for field 'resolution'. Value: \(self.resolution)")
        }

        return Monitoring.Measurements(period: try period.entity,
                            unit: unit,
                            resolution: resolution,
                            values: try values.map { try $0.entity })
    }
}
