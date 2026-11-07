//
//  EnvironmentalBenefits.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Environmental benefits of a site's lifetime production.
    public struct EnvironmentalBenefits: Sendable, Hashable {
        /// Avoided CO₂ emissions, in the unit system given by ``unit``.
        public let co2Emissions: Double
        /// Equivalent distance driven by an electric vehicle, in the unit system given by ``unit``.
        public let evMiles: Double
        /// The unit system of the values above.
        public let unit: UnitSystem

        public init(co2Emissions: Double, evMiles: Double, unit: UnitSystem) {
            self.co2Emissions = co2Emissions
            self.evMiles = evMiles
            self.unit = unit
        }
    }
}
