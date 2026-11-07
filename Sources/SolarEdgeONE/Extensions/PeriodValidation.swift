//
//  PeriodValidation.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Monitoring.Resolution {
    /// The longest period the API accepts for this resolution, or `nil`
    /// if there is no limit.
    ///
    /// The API states "1 month", "1 year" and "3 years" without saying how
    /// they are counted, so those use the longest possible length (31 days,
    /// 366 days, 3 × 366 days). Only clearly invalid periods are rejected
    /// here; the server decides the borderline cases.
    var maximumSpan: TimeInterval? {
        let hour: TimeInterval = 3600
        let day = 24 * hour
        return switch self {
            case .quarterHour: 12 * hour
            case .hour: 24 * hour
            case .day: 31 * day
            case .week: 366 * day
            case .month: 3 * 366 * day
            case .year, .total: nil
        }
    }
}

/// Throws ``SolarEdgeError/invalidRequest(_:)`` if `to` is before `from`,
/// or the period is longer than `resolution` allows. Saves a request (and a
/// credit) that the API would reject anyway.
///
/// Without `to`, the API ends the period now, so `now` is checked instead.
/// Without `from`, the API starts at midnight in the site's time zone,
/// which is not known here, so nothing is checked.
func validatePeriod(from: Date?, to: Date?, resolution: Monitoring.Resolution, now: Date = Date()) throws {
    guard let from else { return }
    let end = to ?? now

    guard from <= end else {
        if to == nil {
            throw SolarEdgeError.invalidRequest("'from' (\(from.formatted(.iso8601))) is in the future")
        }
        throw SolarEdgeError.invalidRequest("'to' (\(end.formatted(.iso8601))) is before 'from' (\(from.formatted(.iso8601)))")
    }
    if let maximumSpan = resolution.maximumSpan, end.timeIntervalSince(from) > maximumSpan {
        throw SolarEdgeError.invalidRequest("The period is too long for \(resolution.rawValue)")
    }
}

/// The lifetime energy endpoints need both dates, `from` before `to`, and
/// at most one week.
func validateLifetimePeriod(from: Date, to: Date) throws {
    guard from < to else {
        throw SolarEdgeError.invalidRequest("'from' must be before 'to'")
    }
    guard to.timeIntervalSince(from) <= 7 * 24 * 3600 else {
        throw SolarEdgeError.invalidRequest("The period may be at most one week")
    }
}

/// The `unit` query value for power endpoints, which accept W, KW and MW
/// but not GW.
func powerUnitQueryValue(_ unit: Monitoring.Power) throws -> String {
    guard unit != .gigaWatt else {
        throw SolarEdgeError.invalidRequest("This endpoint does not support \(unit.rawValue); use W, KW or MW")
    }
    return unit.rawValue
}

/// The `unit` query value for device energy endpoints, which accept WH,
/// KWH and MWH but not GWH.
func energyUnitQueryValue(_ unit: Monitoring.Energy) throws -> String {
    guard unit != .gigaWattHour else {
        throw SolarEdgeError.invalidRequest("This endpoint does not support \(unit.rawValue); use WH, KWH or MWH")
    }
    return unit.rawValue
}
