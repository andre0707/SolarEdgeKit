//
//  StorageTelemetryDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Every metric is documented as present only if the requested resolution
/// supports it, so all are optional.
struct StorageTelemetryDataDTO: Codable {
    let chargePower: StorageMetricMeasurementsDTO?
    let dischargePower: StorageMetricMeasurementsDTO?
    let chargeEnergy: StorageMetricMeasurementsDTO?
    let dischargeEnergy: StorageMetricMeasurementsDTO?
    let remainingEnergy: StorageMetricMeasurementsDTO?
    let stateOfEnergy: StorageMetricMeasurementsDTO?
    let acGridChargingEnergy: StorageMetricMeasurementsDTO?
}


extension StorageTelemetryDataDTO {
    func entity(period: PeriodDTO, resolution: String) throws -> Monitoring.BatteryTelemetry {
        func series<UnitType>(_ dto: StorageMetricMeasurementsDTO?, _ unit: UnitType.Type) throws -> Monitoring.Measurements<UnitType>? {
            try dto?.entity(unit: unit, period: period, resolution: resolution)
        }

        return Monitoring.BatteryTelemetry(chargePower: try series(chargePower, Monitoring.Power.self),
                                dischargePower: try series(dischargePower, Monitoring.Power.self),
                                chargeEnergy: try series(chargeEnergy, Monitoring.Energy.self),
                                dischargeEnergy: try series(dischargeEnergy, Monitoring.Energy.self),
                                remainingEnergy: try series(remainingEnergy, Monitoring.Energy.self),
                                stateOfEnergy: try series(stateOfEnergy, Monitoring.Percentage.self),
                                acGridChargingEnergy: try series(acGridChargingEnergy, Monitoring.Energy.self))
    }
}
