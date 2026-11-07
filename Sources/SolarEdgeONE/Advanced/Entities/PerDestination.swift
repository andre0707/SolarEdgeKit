//
//  PerDestination.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A site's PV production split by where it went, and its consumption split
    /// by where it came from, as returned by Power and Energy Per Destination.
    ///
    /// `UnitType` is ``Monitoring/Power`` for power per destination and ``Monitoring/Energy`` for
    /// energy per destination. Each value covers the bucket that **starts** at
    /// its timestamp.
    public struct PerDestination<UnitType>: Sendable, Hashable
    where UnitType: RawRepresentable & Sendable & Hashable, UnitType.RawValue == String {
        /// A series of values in one unit.
        public struct Series<Value: Sendable & Hashable>: Sendable, Hashable {
            /// The unit of all values.
            public let unit: UnitType
            public let values: [Value]

            public init(unit: UnitType, values: [Value]) {
                self.unit = unit
                self.values = values
            }
        }

        /// The SolarEdge Monitoring ID of the site.
        public let siteID: Site.ID
        /// Where the PV production went.
        public let production: Series<ProductionBreakdown>
        /// Where the consumed energy came from.
        public let consumption: Series<ConsumptionBreakdown>

        public init(siteID: Site.ID, production: Series<ProductionBreakdown>, consumption: Series<ConsumptionBreakdown>) {
            self.siteID = siteID
            self.production = production
            self.consumption = consumption
        }
    }
}

extension Monitoring {
    /// One bucket of PV production, split by destination.
    public struct ProductionBreakdown: Sendable, Hashable {
        /// Start of the bucket.
        public let timestamp: Date
        /// Total PV production.
        public let total: Double
        /// Production used directly on site.
        public let toSelfConsumption: Double
        /// Production used to charge the battery.
        public let toStorage: Double
        /// Production fed into the grid.
        public let toGrid: Double

        public init(timestamp: Date, total: Double, toSelfConsumption: Double, toStorage: Double, toGrid: Double) {
            self.timestamp = timestamp
            self.total = total
            self.toSelfConsumption = toSelfConsumption
            self.toStorage = toStorage
            self.toGrid = toGrid
        }
    }
}

extension Monitoring {
    /// One bucket of consumption, split by source.
    public struct ConsumptionBreakdown: Sendable, Hashable {
        /// Start of the bucket.
        public let timestamp: Date
        /// Total consumption.
        public let total: Double
        /// Consumption covered by PV production.
        public let fromPv: Double
        /// Consumption covered by the battery.
        public let fromStorage: Double
        /// Consumption drawn from the grid.
        public let fromGrid: Double

        public init(timestamp: Date, total: Double, fromPv: Double, fromStorage: Double, fromGrid: Double) {
            self.timestamp = timestamp
            self.total = total
            self.fromPv = fromPv
            self.fromStorage = fromStorage
            self.fromGrid = fromGrid
        }
    }
}
