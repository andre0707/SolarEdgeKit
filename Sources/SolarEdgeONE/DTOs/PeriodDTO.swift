//
//  PeriodDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct PeriodDTO: Codable {
    let from: String
    let to: String
}


extension PeriodDTO {
    var entity: DateInterval {
        get throws {
            guard let start = DateFormatter.iso8601FormattedDate(from: from) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'period.from'. Value: \(from)")
            }
            guard let end = DateFormatter.iso8601FormattedDate(from: to) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'period.to'. Value: \(to)")
            }
            // DateInterval traps if the end is before the start.
            guard start <= end else {
                throw SolarEdgeError.decodingWithMessage(message: "Field 'period.to' is before 'period.from'. Values: \(from), \(to)")
            }

            return DateInterval(start: start, end: end)
        }
    }
}
