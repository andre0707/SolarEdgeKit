//
//  InverterTelemetryDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Every metric is documented as present only if the requested resolution
/// supports it, so all are optional.
struct InverterTelemetryDataDTO: Codable {
    let power: MeasurementsDTO?
    let energy: MeasurementsDTO?
    let consumedAcPower: MeasurementsDTO?
    let consumedAcEnergy: MeasurementsDTO?
    let voltage: MeasurementsDTO?
    let current: MeasurementsDTO?
    let frequency: MeasurementsDTO?
}


extension InverterTelemetryDataDTO {
    var entity: Monitoring.InverterTelemetry {
        get throws {
            Monitoring.InverterTelemetry(power: try power?.entity(unit: Monitoring.Power.self),
                              energy: try energy?.entity(unit: Monitoring.Energy.self),
                              consumedAcPower: try consumedAcPower?.entity(unit: Monitoring.Power.self),
                              consumedAcEnergy: try consumedAcEnergy?.entity(unit: Monitoring.Energy.self),
                              voltage: try voltage?.entity(unit: Monitoring.Voltage.self),
                              current: try current?.entity(unit: Monitoring.ElectricCurrent.self),
                              frequency: try frequency?.entity(unit: Monitoring.Frequency.self))
        }
    }
}
