//
//  MonitoringLayoutID.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The ID of a layout in the SolarEdge Monitoring platform, which battery
    /// upsell imports into Designer; see ``BatteryUpsellTarget/monitoringLayout(_:design:)``.
    ///
    /// A distinct type, so it cannot be mixed up with a Designer site ID.
    /// The spec does not say whether it equals the Monitoring site ID.
    /// Integer literals work directly.
    public struct MonitoringLayoutID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
        /// The numeric ID as used by the API.
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        public init(integerLiteral value: Int) { self.rawValue = value }
        /// The numeric ID as text.
        public var description: String { String(rawValue) }
    }
}
