//
//  DesignID.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The ID of a design of a Designer site. A site can have several
    /// designs; one of them is its default design.
    ///
    /// Integer literals work directly, e.g. `let id: Designer.DesignID = 7`.
    public struct DesignID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
        /// The numeric ID as used by the API.
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        public init(integerLiteral value: Int) { self.rawValue = value }
        /// The numeric ID as text.
        public var description: String { String(rawValue) }
    }
}
