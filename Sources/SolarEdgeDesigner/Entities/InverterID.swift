//
//  InverterID.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The ID of an inverter in a Designer site, as returned by battery
    /// upsell.
    ///
    /// Integer literals work directly, e.g. `let id: Designer.InverterID = 123456789123456780`.
    public struct InverterID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
        /// The numeric ID as used by the API.
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        public init(integerLiteral value: Int) { self.rawValue = value }
        /// The numeric ID as text.
        public var description: String { String(rawValue) }
    }
}
