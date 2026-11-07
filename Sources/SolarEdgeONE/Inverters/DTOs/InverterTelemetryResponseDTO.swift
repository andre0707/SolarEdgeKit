//
//  InverterTelemetryResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct InverterTelemetryResponseDTO: Codable {
    /// Keyed by inverter serial number.
    let inverters: [String: InverterTelemetryDataDTO]
}


extension InverterTelemetryResponseDTO {
    var entity: [String: Monitoring.InverterTelemetry] {
        get throws {
            try inverters.mapValues { try $0.entity }
        }
    }
}
