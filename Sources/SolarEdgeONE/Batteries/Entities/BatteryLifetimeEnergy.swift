//
//  BatteryLifetimeEnergy.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// One battery's lifetime charge and discharge counters, sampled every 15
    /// minutes, as returned by the Storage Lifetime Energy endpoints.
    ///
    /// Each value is the counter itself at that time, not a delta.
    public struct BatteryLifetimeEnergy: Sendable, Hashable {
        /// The battery's serial number.
        public let serialNumber: String
        /// The unit of all values.
        public let unit: Energy
        /// Counter of all energy ever charged.
        public let charged: [MeasurementValue]
        /// Counter of all energy ever discharged.
        public let discharged: [MeasurementValue]

        public init(serialNumber: String, unit: Energy, charged: [MeasurementValue], discharged: [MeasurementValue]) {
            self.serialNumber = serialNumber
            self.unit = unit
            self.charged = charged
            self.discharged = discharged
        }
    }
}
