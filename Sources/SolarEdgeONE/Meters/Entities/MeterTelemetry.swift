//
//  MeterTelemetry.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Telemetry of one meter, as returned by the Meter Telemetry endpoints.
    ///
    /// A metric is `nil` if the requested resolution does not support it, or
    /// the meter does not measure it: ``Monitoring/Resolution/quarterHour`` and
    /// ``Monitoring/Resolution/hour`` return all metrics, every other resolution only the
    /// energy metrics. Power values are averages and energy values sums, each
    /// in the bucket that **starts** at its timestamp.
    public struct MeterTelemetry: Sendable, Hashable {
        /// PV production power.
        public let productionPower: Measurements<Power>?
        /// PV production energy.
        public let productionEnergy: Measurements<Energy>?
        /// Site consumption power.
        public let consumptionPower: Measurements<Power>?
        /// Site consumption energy.
        public let consumptionEnergy: Measurements<Energy>?
        /// Power drawn from the grid.
        public let importPower: Measurements<Power>?
        /// Energy drawn from the grid.
        public let importEnergy: Measurements<Energy>?
        /// Power fed into the grid.
        public let exportPower: Measurements<Power>?
        /// Energy fed into the grid.
        public let exportEnergy: Measurements<Energy>?

        public init(productionPower: Measurements<Power>?, productionEnergy: Measurements<Energy>?, consumptionPower: Measurements<Power>?, consumptionEnergy: Measurements<Energy>?, importPower: Measurements<Power>?, importEnergy: Measurements<Energy>?, exportPower: Measurements<Power>?, exportEnergy: Measurements<Energy>?) {
            self.productionPower = productionPower
            self.productionEnergy = productionEnergy
            self.consumptionPower = consumptionPower
            self.consumptionEnergy = consumptionEnergy
            self.importPower = importPower
            self.importEnergy = importEnergy
            self.exportPower = exportPower
            self.exportEnergy = exportEnergy
        }
    }
}
