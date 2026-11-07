//
//  StorageTelemetryResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct StorageTelemetryResponseDTO: Codable {
    let period: PeriodDTO
    let resolution: String
    /// Keyed by battery serial number.
    let storage: [String: StorageTelemetryDataDTO]
}


extension StorageTelemetryResponseDTO {
    var entity: [String: Monitoring.BatteryTelemetry] {
        get throws {
            try storage.mapValues { try $0.entity(period: period, resolution: resolution) }
        }
    }
}
