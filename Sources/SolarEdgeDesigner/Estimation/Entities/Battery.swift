//
//  Battery.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// A battery model offered for estimations, as returned by
    /// ``EstimationService/batteries(manufacturer:phase:)``.
    public struct Battery: Sendable, Hashable, Identifiable {
        /// The Designer ID of a battery model.
        ///
        /// String literals work directly, e.g. `let id: Designer.Battery.ID = "…"`.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
            /// The ID as used by the API.
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
            public init(stringLiteral value: String) { self.rawValue = value }
            public var description: String { rawValue }
        }

        /// The ID of the battery model.
        public let id: ID
        /// The capacity of the battery in Wh.
        public let capacity: Int
        /// The display name of the battery.
        public let displayName: String

        public init(id: ID, capacity: Int, displayName: String) {
            self.id = id
            self.capacity = capacity
            self.displayName = displayName
        }
    }
}
