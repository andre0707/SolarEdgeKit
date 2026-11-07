//
//  InverterLifetimeEnergy.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// One inverter's lifetime energy counter, sampled every 15 minutes, as
    /// returned by Site Inverter Lifetime Energy.
    public struct InverterLifetimeEnergy: Sendable, Hashable {
        /// The inverter's serial number.
        public let serialNumber: String
        /// The unit of all values.
        public let unit: Energy
        /// The counter's readings. Each value is the counter itself at that
        /// time, not a delta. Empty if the inverter reported nothing in the period.
        public let values: [MeasurementValue]

        public init(serialNumber: String, unit: Energy, values: [MeasurementValue]) {
            self.serialNumber = serialNumber
            self.unit = unit
            self.values = values
        }
    }
}
