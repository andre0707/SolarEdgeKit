//
//  SiteProduction.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Where the solar production went. All values are in ``unit``.
    public struct SiteProduction: Sendable, Hashable {
        /// Total solar production in the period.
        public let total: Double
        /// The unit of all values in this type.
        public let unit: Energy
        /// Production used directly on site.
        public let toSelfConsumption: Double?
        /// Production used to charge the battery.
        public let toStorage: Double?
        /// Production fed into the grid.
        public let toGrid: Double?

        public init(total: Double, unit: Energy, toSelfConsumption: Double?, toStorage: Double?, toGrid: Double?) {
            self.total = total
            self.unit = unit
            self.toSelfConsumption = toSelfConsumption
            self.toStorage = toStorage
            self.toGrid = toGrid
        }
    }
}
