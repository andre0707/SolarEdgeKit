//
//  MeterTelemetryResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct MeterTelemetryResponseDTO: Codable {
    let period: PeriodDTO
    let resolution: String
    /// Keyed by meter serial number.
    let meters: [String: MeterTelemetryDataDTO]
}


extension MeterTelemetryResponseDTO {
    var entity: [String: Monitoring.MeterTelemetry] {
        get throws {
            try meters.mapValues { try $0.entity(period: period, resolution: resolution) }
        }
    }
}
