//
//  BatteryTelemetry.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Telemetry of one battery, as returned by the Storage Telemetry endpoints.
    ///
    /// A metric is `nil` if the requested resolution does not support it:
    /// ``Monitoring/Resolution/quarterHour`` and ``Monitoring/Resolution/hour`` return all metrics
    /// (``acGridChargingEnergy`` only at a quarter hour), every other resolution
    /// only the energy metrics. All values are positive, and each covers the
    /// bucket that **starts** at its timestamp.
    public struct BatteryTelemetry: Sendable, Hashable {
        /// Charge power, averaged per bucket.
        public let chargePower: Measurements<Power>?
        /// Discharge power, averaged per bucket.
        public let dischargePower: Measurements<Power>?
        /// Energy charged, summed per bucket.
        public let chargeEnergy: Measurements<Energy>?
        /// Energy discharged, summed per bucket.
        public let dischargeEnergy: Measurements<Energy>?
        /// Energy stored in the battery, averaged per bucket.
        public let remainingEnergy: Measurements<Energy>?
        /// State of charge, 0–100, averaged per bucket: remaining energy as a
        /// share of the energy the full pack can currently hold.
        public let stateOfEnergy: Measurements<Percentage>?
        /// Energy charged from the AC grid. Only at ``Monitoring/Resolution/quarterHour``.
        public let acGridChargingEnergy: Measurements<Energy>?

        public init(chargePower: Measurements<Power>?, dischargePower: Measurements<Power>?, chargeEnergy: Measurements<Energy>?, dischargeEnergy: Measurements<Energy>?, remainingEnergy: Measurements<Energy>?, stateOfEnergy: Measurements<Percentage>?, acGridChargingEnergy: Measurements<Energy>?) {
            self.chargePower = chargePower
            self.dischargePower = dischargePower
            self.chargeEnergy = chargeEnergy
            self.dischargeEnergy = dischargeEnergy
            self.remainingEnergy = remainingEnergy
            self.stateOfEnergy = stateOfEnergy
            self.acGridChargingEnergy = acGridChargingEnergy
        }
    }
}
