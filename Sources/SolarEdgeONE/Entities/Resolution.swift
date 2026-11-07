//
//  Resolution.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Bucket size of a time series.
    public enum Resolution: String, Sendable, CaseIterable {
        case quarterHour = "QUARTER_HOUR"
        case hour = "HOUR"
        case day = "DAY"
        case week = "WEEK"
        case month = "MONTH"
        case year = "YEAR"
        case total = "TOTAL"
    }
}
