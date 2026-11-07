//
//  StorageStatusResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `period` and `resolution` are nullable: both are `null` when the
/// batteries have no status data in the period.
struct StorageStatusResponseDTO: Codable {
    let period: PeriodDTO?
    let resolution: String?
    let storage: [String: StorageStatusDTO]
}

/// Documented as present only where the battery has reported it.
struct StorageStatusDTO: Codable {
    let batteryState: BatteryStateDTO?
    let internalTemperature: InternalTemperatureDTO?
}

struct BatteryStateDTO: Codable {
    let values: [StorageStatusMeasurementDTO]
}

struct InternalTemperatureDTO: Codable {
    let unit: String
    let values: [StorageStatusMeasurementDTO]
}


extension StorageStatusResponseDTO {
    var entity: Monitoring.BatteryStatusReport {
        get throws {
            Monitoring.BatteryStatusReport(period: try period?.entity,
                                batteries: try storage.mapValues { try $0.entity })
        }
    }
}

extension StorageStatusDTO {
    var entity: Monitoring.BatteryStatus {
        get throws {
            let temperature = try internalTemperature.map { dto in
                guard let unit = Monitoring.Temperature(rawValue: dto.unit) else {
                    throw SolarEdgeError.decodingWithMessage(message: "Unexpected unit for field 'internalTemperature.unit'. Value: \(dto.unit)")
                }
                return Monitoring.StatusSeries(unit: unit, values: try dto.values.map { try $0.entity })
            }

            return Monitoring.BatteryStatus(batteryState: try batteryState?.values.map { try $0.entity },
                                 internalTemperature: temperature)
        }
    }
}
