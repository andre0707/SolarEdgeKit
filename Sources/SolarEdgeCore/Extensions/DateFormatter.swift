//
//  DateFormatter.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

package extension DateFormatter {

    /// Parses an ISO 8601 date-time with `Z` or an offset, with or without
    /// fractional seconds, e.g. `2026-10-08T09:30:00+02:00` or
    /// `2022-11-14T11:30:54.276805300Z`.
    ///
    /// Returns `nil` for anything else, including values without an offset:
    /// guessing a time zone would silently shift the time. Parsers that have
    /// to accept such values (alerts) handle them themselves.
    static func iso8601FormattedDate(from string: String) -> Date? {
        if let date = try? Date.ISO8601FormatStyle().parse(string) {
            return date
        }
        return try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(string)
    }
}
