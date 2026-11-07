//
//  GridCode.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// A grid of a country, as returned by
    /// ``EstimationService/gridCodes(country:)``.
    ///
    /// Its ``id`` selects the grid for
    /// ``DeviceModelsService/models(for:countryCode:stateCode:sector:)``.
    public struct GridCode: Sendable, Hashable, Identifiable {
        /// The Designer ID of a grid.
        ///
        /// String literals work directly.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
            /// The ID as used by the API.
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
            public init(stringLiteral value: String) { self.rawValue = value }
            public var description: String { rawValue }
        }

        /// The ID of the grid.
        public let id: ID
        /// The name of the grid.
        public let name: String
        /// The single-phase voltage of the grid, if supported.
        public let onePhaseVoltage: Int
        /// The three-phase voltage of the grid, if supported.
        public let threePhaseVoltage: Int

        public init(id: ID, name: String, onePhaseVoltage: Int, threePhaseVoltage: Int) {
            self.id = id
            self.name = name
            self.onePhaseVoltage = onePhaseVoltage
            self.threePhaseVoltage = threePhaseVoltage
        }
    }
}
