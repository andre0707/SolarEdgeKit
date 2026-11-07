//
//  InverterStatusDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Site Inverter Status documents that a metric is present only where the
/// inverter has reported it, so all four are optional.
struct InverterStatusDataDTO: Codable {
    let powerLimit: PowerLimitDTO?
    let operationMode: OperationModeDTO?
    let inverterMode: InverterModeDTO?
    let temperature: InverterTemperatureDTO?
}

struct PowerLimitDTO: Codable {
    let unit: String
    let values: [InverterStatusMeasurementDTO]
}

struct OperationModeDTO: Codable {
    let values: [InverterStatusMeasurementDTO]
}

struct InverterModeDTO: Codable {
    let values: [InverterModeMeasurementDTO]
}

struct InverterTemperatureDTO: Codable {
    let unit: String
    let values: [InverterStatusMeasurementDTO]
}


extension InverterStatusDataDTO {
    var entity: Monitoring.InverterStatus {
        get throws {
            Monitoring.InverterStatus(powerLimit: try powerLimit.map { try Monitoring.StatusSeries(unit: $0.unit, values: $0.values, field: "powerLimit") },
                           operationMode: try operationMode?.values.map { try $0.entity },
                           inverterMode: try inverterMode?.values.map { try $0.entity },
                           temperature: try temperature.map { try Monitoring.StatusSeries(unit: $0.unit, values: $0.values, field: "temperature") })
        }
    }
}

private extension Monitoring.StatusSeries {
    init(unit: String, values: [InverterStatusMeasurementDTO], field: String) throws {
        guard let unit = UnitType(rawValue: unit) else {
            throw SolarEdgeError.decodingWithMessage(message: "Unexpected unit for field '\(field).unit'. Value: \(unit)")
        }
        self.init(unit: unit, values: try values.map { try $0.entity })
    }
}
