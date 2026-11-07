//
//  MeterLifetimeEnergy.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// One meter's lifetime energy counters, sampled every 15 minutes, as
    /// returned by the Meter Lifetime Energy endpoints.
    ///
    /// A meter can measure several directions, e.g. a grid meter both import
    /// and export. Each value is the counter itself at that time, not a delta.
    /// A list is empty if the meter does not measure that direction or
    /// reported nothing in the period.
    public struct MeterLifetimeEnergy: Sendable, Hashable {
        /// The meter's serial number.
        public let serialNumber: String
        /// The unit of all values.
        public let unit: Energy
        /// PV production counter.
        public let productionEnergy: [MeasurementValue]
        /// Consumption counter.
        public let consumptionEnergy: [MeasurementValue]
        /// Counter of energy drawn from the grid.
        public let importEnergy: [MeasurementValue]
        /// Counter of energy fed into the grid.
        public let exportEnergy: [MeasurementValue]

        public init(serialNumber: String, unit: Energy, productionEnergy: [MeasurementValue], consumptionEnergy: [MeasurementValue], importEnergy: [MeasurementValue], exportEnergy: [MeasurementValue]) {
            self.serialNumber = serialNumber
            self.unit = unit
            self.productionEnergy = productionEnergy
            self.consumptionEnergy = consumptionEnergy
            self.importEnergy = importEnergy
            self.exportEnergy = exportEnergy
        }
    }
}
