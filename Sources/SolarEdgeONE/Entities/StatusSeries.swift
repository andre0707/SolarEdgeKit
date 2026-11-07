//
//  StatusSeries.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A series of device-state samples, e.g. an inverter's power limit.
    ///
    /// Unlike ``Monitoring/Measurements``, each value is the **last known value** in its
    /// bucket, not an average or sum, and the series carries no period of its own.
    public struct StatusSeries<UnitType>: Sendable, Hashable
    where UnitType: RawRepresentable & Sendable & Hashable, UnitType.RawValue == String {
        public let unit: UnitType
        /// One sample per bucket. `value` is `nil` for a bucket without a sample.
        public let values: [MeasurementValue]

        public init(unit: UnitType, values: [MeasurementValue]) {
            self.unit = unit
            self.values = values
        }
    }
}
