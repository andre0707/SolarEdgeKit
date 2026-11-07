//
//  SiteExternalProductionEnergy.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A site's lifetime production energy split by source, as returned by
    /// Site External Production Energy. Both values are in ``unit``.
    public struct SiteExternalProductionEnergy: Sendable, Hashable {
        /// The site's solar production.
        public let energyIncludingExternalSources: Double
        /// Production not accounted for by an external-production meter.
        /// Equal to ``energyIncludingExternalSources`` on sites without one.
        public let energyExcludingExternalSources: Double
        /// The unit of both values.
        public let unit: Energy

        public init(energyIncludingExternalSources: Double, energyExcludingExternalSources: Double, unit: Energy) {
            self.energyIncludingExternalSources = energyIncludingExternalSources
            self.energyExcludingExternalSources = energyExcludingExternalSources
            self.unit = unit
        }
    }
}
