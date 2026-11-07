//
//  AlertDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct AlertDTO: Codable {
    let alertId: Int
    let siteId: Int
    let category: String
    let type: String
    let impact: Int
    let status: String
    let firstTrigger: String
    let lastTrigger: String
    let closeDate: String?
    let muteExpirationDate: String?
    let component: AlertComponentDTO
    let errorCodes: [String]
}


extension AlertDTO {
    var entity: Monitoring.Alert {
        get throws {
            let status = Monitoring.AlertStatus(rawValue: status)

            return Monitoring.Alert(id: .init(rawValue: alertId),
                         siteID: .init(rawValue: siteId),
                         category: category,
                         type: type,
                         impact: impact,
                         status: status,
                         firstTrigger: try Self.date(firstTrigger, field: "firstTrigger"),
                         lastTrigger: try Self.date(lastTrigger, field: "lastTrigger"),
                         closeDate: try closeDate.map { try Self.date($0, field: "closeDate") },
                         muteExpirationDate: try muteExpirationDate.map { try Self.date($0, field: "muteExpirationDate") },
                         component: component.entity,
                         errorCodes: errorCodes)
        }
    }

    /// The spec declares these as ISO 8601 with an offset, but its examples
    /// look like `2026-09-28 23:07:18`. Both are accepted, with a space or a
    /// `T`; a value without an offset is read as UTC, which is an assumption
    /// until a real response shows otherwise.
    private static func date(_ string: String, field: String) throws -> Date {
        if let date = DateFormatter.iso8601FormattedDate(from: string) {
            return date
        }

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd'T'HH:mm:ss"] {
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }
        throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field '\(field)'. Value: \(string)")
    }
}
