//
//  SiteConsumption.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Where the consumed energy came from. All values are in ``unit``.
    public struct SiteConsumption: Sendable, Hashable {
        /// Total consumption in the period.
        public let total: Double?
        /// The unit of all values in this type.
        public let unit: Energy
        /// Consumption covered by solar production.
        public let fromPv: Double?
        /// Consumption covered by the battery.
        public let fromStorage: Double?
        /// Consumption drawn from the grid.
        public let fromGrid: Double?

        public init(total: Double?, unit: Energy, fromPv: Double?, fromStorage: Double?, fromGrid: Double?) {
            self.total = total
            self.unit = unit
            self.fromPv = fromPv
            self.fromStorage = fromStorage
            self.fromGrid = fromGrid
        }
    }
}
