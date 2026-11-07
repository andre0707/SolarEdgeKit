//
//  MeterTelemetryDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Every metric is documented as present only if the requested resolution
/// supports it, so all are optional.
struct MeterTelemetryDataDTO: Codable {
    let productionEnergy: MeterMetricMeasurementsDTO?
    let productionPower: MeterMetricMeasurementsDTO?
    let consumptionEnergy: MeterMetricMeasurementsDTO?
    let consumptionPower: MeterMetricMeasurementsDTO?
    let importEnergy: MeterMetricMeasurementsDTO?
    let importPower: MeterMetricMeasurementsDTO?
    let exportEnergy: MeterMetricMeasurementsDTO?
    let exportPower: MeterMetricMeasurementsDTO?
}


extension MeterTelemetryDataDTO {
    func entity(period: PeriodDTO, resolution: String) throws -> Monitoring.MeterTelemetry {
        func power(_ dto: MeterMetricMeasurementsDTO?) throws -> Monitoring.Measurements<Monitoring.Power>? {
            try dto?.entity(unit: Monitoring.Power.self, period: period, resolution: resolution)
        }
        func energy(_ dto: MeterMetricMeasurementsDTO?) throws -> Monitoring.Measurements<Monitoring.Energy>? {
            try dto?.entity(unit: Monitoring.Energy.self, period: period, resolution: resolution)
        }

        return Monitoring.MeterTelemetry(productionPower: try power(productionPower),
                              productionEnergy: try energy(productionEnergy),
                              consumptionPower: try power(consumptionPower),
                              consumptionEnergy: try energy(consumptionEnergy),
                              importPower: try power(importPower),
                              importEnergy: try energy(importEnergy),
                              exportPower: try power(exportPower),
                              exportEnergy: try energy(exportEnergy))
    }
}
