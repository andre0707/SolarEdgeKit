//
//  Incentive.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// An incentive, as returned by
    /// ``EstimationService/incentives(country:state:)`` and
    /// ``EstimationService/incentive(_:)``.
    public struct Incentive: Sendable, Hashable, Identifiable {
        /// The Designer ID of an incentive.
        ///
        /// Integer literals work directly.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
            /// The numeric ID as used by the API.
            public let rawValue: Int
            public init(rawValue: Int) { self.rawValue = rawValue }
            public init(integerLiteral value: Int) { self.rawValue = value }
            public var description: String { String(rawValue) }
        }

        /// The ID of the incentive.
        public let id: ID
        /// The name of the incentive.
        public let name: String
        /// A short summary of the incentive.
        public let summary: String

        public init(id: ID, name: String, summary: String) {
            self.id = id
            self.name = name
            self.summary = summary
        }
    }
}
