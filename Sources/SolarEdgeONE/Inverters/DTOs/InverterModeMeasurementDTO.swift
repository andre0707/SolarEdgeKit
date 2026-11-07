//
//  InverterModeMeasurementDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct InverterModeMeasurementDTO: Codable {
    let timestamp: String
    let value: String?
}


extension InverterModeMeasurementDTO {
    var entity: Monitoring.InverterModeValue {
        get throws {
            guard let timestamp = DateFormatter.iso8601FormattedDate(from: timestamp) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'inverterMode.timestamp'. Value: \(self.timestamp)")
            }
            let mode = value.map(Monitoring.InverterMode.init(rawValue:))

            return Monitoring.InverterModeValue(timestamp: timestamp, mode: mode)
        }
    }
}
