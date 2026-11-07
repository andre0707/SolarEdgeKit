//
//  SiteLifetimeEnergy.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A site's lifetime production energy, as returned by Site Lifetime Energy.
    public struct SiteLifetimeEnergy: Sendable, Hashable {
        /// The counter's value, in ``unit``.
        public let energy: Double
        /// The unit of ``energy``.
        public let unit: Energy
        /// When the counter was last updated.
        public let lastUpdateTime: Date

        public init(energy: Double, unit: Energy, lastUpdateTime: Date) {
            self.energy = energy
            self.unit = unit
            self.lastUpdateTime = lastUpdateTime
        }
    }
}
