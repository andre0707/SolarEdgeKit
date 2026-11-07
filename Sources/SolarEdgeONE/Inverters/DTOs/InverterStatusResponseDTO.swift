//
//  InverterStatusResponseDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct InverterStatusResponseDTO: Codable {
    let period: PeriodDTO
    let resolution: String
    let inverters: [String: InverterStatusDataDTO]
}


extension InverterStatusResponseDTO {
    var entity: Monitoring.InverterStatusReport {
        get throws {
            guard let resolution = Monitoring.IntradayResolution(rawValue: resolution) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unexpected resolution for field 'resolution'. Value: \(self.resolution)")
            }

            return Monitoring.InverterStatusReport(period: try period.entity,
                                        resolution: resolution,
                                        inverters: try inverters.mapValues { try $0.entity })
        }
    }
}
