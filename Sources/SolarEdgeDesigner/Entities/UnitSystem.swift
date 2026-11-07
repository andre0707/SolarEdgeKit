//
//  UnitSystem.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// Imperial or metric units, e.g. for the pages behind sharable links.
    ///
    /// The Designer API defaults to ``imperial``.
    public enum UnitSystem: String, Sendable, Hashable, CaseIterable {
        /// Imperial units.
        case imperial = "IMPERIAL"
        /// Metric units.
        case metric = "METRIC"
    }
}
