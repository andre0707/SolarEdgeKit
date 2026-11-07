//
//  UtilityRate.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Designer {
    /// A utility provider, as returned by
    /// ``EstimationService/utilityProviders(rateType:country:state:)``.
    public struct UtilityProvider: Sendable, Hashable {
        /// The name of the provider. Pass it to
        /// ``EstimationService/utilityRates(utilityNames:rateType:orphanRates:country:state:)``
        /// to get its rates.
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }

    /// A utility rate (tariff), as returned by
    /// ``EstimationService/utilityRates(utilityNames:rateType:orphanRates:country:state:)``
    /// and ``EstimationService/utilityRate(_:)``.
    public struct UtilityRate: Sendable, Hashable, Identifiable {
        /// The Designer ID of a utility rate.
        ///
        /// Integer literals work directly.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
            /// The numeric ID as used by the API.
            public let rawValue: Int
            public init(rawValue: Int) { self.rawValue = rawValue }
            public init(integerLiteral value: Int) { self.rawValue = value }
            public var description: String { String(rawValue) }
        }

        /// Whether a rate applies to energy bought from or sold to the grid.
        /// Also used as a filter; `nil` there means both.
        public enum RateType: String, Sendable, Hashable, CaseIterable {
            /// Paid for energy fed into the grid.
            case export = "EXPORT_RATE"
            /// Charged for energy taken from the grid.
            case `import` = "IMPORT_RATE"
        }

        /// Filters rates by whether they have a utility provider. Export
        /// rates may have none ("orphan" rates). `nil` means all rates.
        public enum OrphanRatesFilter: String, Sendable, Hashable, CaseIterable {
            /// Only rates without a provider.
            case onlyOrphans = "ORPHAN_RATES"
            /// Only rates with a provider.
            case excludeOrphans = "NON_ORPHAN_RATES"
        }

        /// The ID of the rate.
        public let id: ID
        /// The name of the utility provider.
        public let utilityName: String
        /// The name of the rate.
        public let name: String
        /// Whether the rate is for import or export.
        public let rateType: RateType
        /// The day the rate takes effect. Has no time or time zone.
        public let effectiveDate: CalendarDate

        public init(id: ID, utilityName: String, name: String, rateType: RateType, effectiveDate: CalendarDate) {
            self.id = id
            self.utilityName = utilityName
            self.name = name
            self.rateType = rateType
            self.effectiveDate = effectiveDate
        }
    }
}
