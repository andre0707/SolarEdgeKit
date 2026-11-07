//
//  IntradayResolution.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// The bucket sizes shorter than a day.
    ///
    /// Used by the endpoints that only support these two: power, voltage,
    /// current, frequency, battery state of energy, and inverter status.
    public enum IntradayResolution: String, Sendable, CaseIterable {
        case quarterHour = "QUARTER_HOUR"
        case hour = "HOUR"
    }
}

extension Monitoring.IntradayResolution {
    /// The same bucket size as a general ``Monitoring/Resolution``.
    var resolution: Monitoring.Resolution {
        switch self {
            case .quarterHour: .quarterHour
            case .hour: .hour
        }
    }
}
