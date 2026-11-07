//
//  Measurements.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A time series as returned by the measurement endpoints.
    ///
    /// `UnitType` is the kind of unit the endpoint returns, e.g. ``Monitoring/Power`` for
    /// power endpoints or ``Monitoring/Energy`` for energy endpoints.
    public struct Measurements<UnitType>: Sendable, Hashable
    where UnitType: RawRepresentable & Sendable & Hashable, UnitType.RawValue == String {
        /// The period the values cover.
        public let period: DateInterval
        public let unit: UnitType
        public let resolution: Resolution
        public let values: [MeasurementValue]

        public init(period: DateInterval, unit: UnitType, resolution: Resolution, values: [MeasurementValue]) {
            self.period = period
            self.unit = unit
            self.resolution = resolution
            self.values = values
        }
    }
}

extension Monitoring {
    /// One value of a time series.
    public struct MeasurementValue: Sendable, Hashable {
        /// Start of the bucket this value covers.
        public let timestamp: Date
        /// `nil` if there is no data for this bucket.
        public let value: Double?

        public init(timestamp: Date, value: Double?) {
            self.timestamp = timestamp
            self.value = value
        }
    }
}
