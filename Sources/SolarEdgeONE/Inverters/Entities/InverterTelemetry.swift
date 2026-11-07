//
//  InverterTelemetry.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Telemetry of one inverter, as returned by the Inverter Telemetry endpoints.
    ///
    /// A metric is `nil` if the requested resolution does not support it:
    /// ``Monitoring/Resolution/quarterHour`` and ``Monitoring/Resolution/hour`` return all metrics,
    /// every other resolution only ``energy`` and ``consumedAcEnergy``.
    public struct InverterTelemetry: Sendable, Hashable {
        /// AC output power. Each value is the average in the bucket that
        /// **starts** at its timestamp.
        public let power: Measurements<Power>?
        /// AC energy produced. Each value is the sum in the bucket that
        /// **starts** at its timestamp.
        public let energy: Measurements<Energy>?
        /// AC input power, e.g. when charging from the grid. Each value is the
        /// average in the bucket that **starts** at its timestamp.
        public let consumedAcPower: Measurements<Power>?
        /// AC input energy. Each value is the sum in the bucket that **starts**
        /// at its timestamp.
        public let consumedAcEnergy: Measurements<Energy>?
        /// AC voltage, averaged across the active phases (L1 only on
        /// single-phase inverters). Each value covers the bucket that **ends**
        /// at its timestamp.
        public let voltage: Measurements<Voltage>?
        /// AC current, derived as power ÷ voltage, not measured. Each value
        /// covers the bucket that **starts** at its timestamp.
        public let current: Measurements<ElectricCurrent>?
        /// AC frequency, averaged across the active phases (L1 only on
        /// single-phase inverters). Each value covers the bucket that **ends**
        /// at its timestamp.
        public let frequency: Measurements<Frequency>?

        public init(power: Measurements<Power>?, energy: Measurements<Energy>?, consumedAcPower: Measurements<Power>?, consumedAcEnergy: Measurements<Energy>?, voltage: Measurements<Voltage>?, current: Measurements<ElectricCurrent>?, frequency: Measurements<Frequency>?) {
            self.power = power
            self.energy = energy
            self.consumedAcPower = consumedAcPower
            self.consumedAcEnergy = consumedAcEnergy
            self.voltage = voltage
            self.current = current
            self.frequency = frequency
        }
    }
}
