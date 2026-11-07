//
//  CalendarDate.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

/// A calendar day without a time or time zone, e.g. `2026-03-10`.
///
/// The API returns some values (such as a site's installation date) as plain
/// dates. Converting them to `Date` would require guessing a time zone, so
/// the library keeps them as-is and lets the caller decide.
public struct CalendarDate: Sendable, Hashable, Comparable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    /// `nil` for a day that does not exist, e.g. February 30, or February 29
    /// outside leap years.
    public init?(year: Int, month: Int, day: Int) {
        guard (1...12).contains(month), (1...Self.numberOfDays(inMonth: month, year: year)).contains(day) else { return nil }
        self.year = year
        self.month = month
        self.day = day
    }

    /// Parses `YYYY-MM-DD`. A time part after the date (`T...` or ` ...`),
    /// as in `2026-03-10T00:00:00Z`, is ignored.
    public init?(isoString: String) {
        // Only a date-time separator may follow the date: rejects "2026-03-1012".
        if let separator = isoString.dropFirst(10).first,
           !["T", "t", " "].contains(separator) {
            return nil
        }

        let parts = isoString.prefix(10).split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3,
              parts[0].count == 4, parts[1].count == 2, parts[2].count == 2,
              // ASCII digits only: `Int` would also accept "+026" or "-001".
              parts.allSatisfy({ $0.utf8.allSatisfy { (0x30...0x39).contains($0) } }),
              let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2])
        else { return nil }
        self.init(year: year, month: month, day: day)
    }

    /// Days in a month of the proleptic Gregorian calendar.
    private static func numberOfDays(inMonth month: Int, year: Int) -> Int {
        switch month {
        case 2:
            let isLeapYear = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return isLeapYear ? 29 : 28
        case 4, 6, 9, 11:
            return 30
        default:
            return 31
        }
    }

    /// Start of this day in the given time zone (for example the site's).
    public func startOfDay(in timeZone: TimeZone) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(from: DateComponents(year: year, month: month, day: day))
    }

    public var description: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    public static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
