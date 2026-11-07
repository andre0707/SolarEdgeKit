//
//  PvModule.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// A PV module model, as returned by
    /// ``EstimationService/pvModules(manufacturer:)`` and
    /// ``EstimationService/pvModule(_:)``.
    public struct PvModule: Sendable, Hashable, Identifiable {
        /// The Designer ID of a PV module model.
        ///
        /// Integer literals work directly, e.g. `let id: Designer.PvModule.ID = 1234`.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
            /// The numeric ID as used by the API.
            public let rawValue: Int
            public init(rawValue: Int) { self.rawValue = rawValue }
            public init(integerLiteral value: Int) { self.rawValue = value }
            public var description: String { String(rawValue) }
        }

        /// The ID of the PV module model.
        public let id: ID
        /// The name of the manufacturer.
        public let manufacturer: String
        /// The model name.
        public let model: String
        /// The power under standard test conditions. The spec gives no unit.
        public let stcPower: Double

        public init(id: ID, manufacturer: String, model: String, stcPower: Double) {
            self.id = id
            self.manufacturer = manufacturer
            self.model = model
            self.stcPower = stcPower
        }
    }
}
