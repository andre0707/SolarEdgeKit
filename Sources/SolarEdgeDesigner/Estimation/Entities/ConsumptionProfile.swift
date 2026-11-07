//
//  ConsumptionProfile.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// A predefined consumption profile, as returned by
    /// ``EstimationService/consumptionProfiles(country:)``.
    public struct ConsumptionProfile: Sendable, Hashable, Identifiable {
        /// The Designer ID of a consumption profile.
        ///
        /// String literals work directly.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
            /// The ID as used by the API.
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
            public init(stringLiteral value: String) { self.rawValue = value }
            public var description: String { rawValue }
        }

        /// The ID of the consumption profile.
        public let id: ID
        /// The name of the consumption profile.
        public let name: String

        public init(id: ID, name: String) {
            self.id = id
            self.name = name
        }
    }
}
