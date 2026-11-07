//
//  InverterStatus.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Device status of one inverter, as returned by the Inverter Status endpoints.
    ///
    /// Each sample is the **last known value** in its bucket. For specific
    /// inverters, all four metrics are returned with a sample for every bucket
    /// (`nil` values where nothing was reported). For a whole site, a metric is
    /// `nil` if the inverter has not reported it.
    public struct InverterStatus: Sendable, Hashable {
        /// Active power limit set on the inverter, as a percentage (0–100) of
        /// its rated power.
        public let powerLimit: StatusSeries<Percentage>?
        /// Raw operation mode code as reported by the device. A code, not a
        /// quantity, so it has no unit.
        public let operationMode: [MeasurementValue]?
        /// Decoded operating state, e.g. ``Monitoring/InverterMode/mppt`` or ``Monitoring/InverterMode/fault``.
        public let inverterMode: [InverterModeValue]?
        /// Internal temperature of the inverter.
        public let temperature: StatusSeries<Temperature>?

        public init(powerLimit: StatusSeries<Percentage>?, operationMode: [MeasurementValue]?, inverterMode: [InverterModeValue]?, temperature: StatusSeries<Temperature>?) {
            self.powerLimit = powerLimit
            self.operationMode = operationMode
            self.inverterMode = inverterMode
            self.temperature = temperature
        }
    }
}

extension Monitoring {
    /// The result of an Inverter Status request.
    public struct InverterStatusReport: Sendable, Hashable {
        /// The period the samples cover.
        public let period: DateInterval
        public let resolution: IntradayResolution
        /// Status per inverter, keyed by serial number. Unknown serial numbers
        /// are absent; for a whole site, so are inverters that reported nothing.
        public let inverters: [String: InverterStatus]

        public init(period: DateInterval, resolution: IntradayResolution, inverters: [String: InverterStatus]) {
            self.period = period
            self.resolution = resolution
            self.inverters = inverters
        }
    }
}
