//
//  BatteryStatus.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Status of one battery, as returned by the Storage Status endpoints.
    ///
    /// Each sample is the last known value in its bucket. A metric is `nil` if
    /// the battery has not reported it.
    public struct BatteryStatus: Sendable, Hashable {
        /// Raw state code as reported by the device. There is no public mapping
        /// of codes to named states yet, so treat it as opaque.
        public let batteryState: [MeasurementValue]?
        /// Internal temperature of the battery.
        public let internalTemperature: StatusSeries<Temperature>?

        public init(batteryState: [MeasurementValue]?, internalTemperature: StatusSeries<Temperature>?) {
            self.batteryState = batteryState
            self.internalTemperature = internalTemperature
        }
    }
}

extension Monitoring {
    /// The result of a Storage Status request.
    public struct BatteryStatusReport: Sendable, Hashable {
        /// The period the samples cover. `nil` if none of the batteries has
        /// status data in the period.
        public let period: DateInterval?
        /// Status per battery, keyed by serial number. Batteries that are
        /// unknown, not batteries, or reported nothing are absent.
        public let batteries: [String: BatteryStatus]

        public init(period: DateInterval?, batteries: [String: BatteryStatus]) {
            self.period = period
            self.batteries = batteries
        }
    }
}
