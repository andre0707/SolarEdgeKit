//
//  MeasurementDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct MeasurementDTO: Codable {
    let timestamp: String
    let value: Double?
}


extension MeasurementDTO {
    var entity: Monitoring.MeasurementValue {
        get throws {
            guard let timestamp = DateFormatter.iso8601FormattedDate(from: timestamp) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'timestamp'. Value: \(self.timestamp)")
            }

            return Monitoring.MeasurementValue(timestamp: timestamp, value: value)
        }
    }
}
