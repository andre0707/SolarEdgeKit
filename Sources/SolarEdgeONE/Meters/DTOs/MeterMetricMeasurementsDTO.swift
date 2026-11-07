//
//  MeterMetricMeasurementsDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct MeterMetricMeasurementsDTO: Codable {
    let unit: String
    let values: [MeasurementDTO]
}


extension MeterMetricMeasurementsDTO {
    /// A meter metric carries only its unit and values; the period and
    /// resolution come from the enclosing response.
    func entity<UnitType>(unit _: UnitType.Type, period: PeriodDTO, resolution: String) throws -> Monitoring.Measurements<UnitType> {
        try MeasurementsDTO(period: period, unit: unit, resolution: resolution, values: values)
            .entity(unit: UnitType.self)
    }
}
