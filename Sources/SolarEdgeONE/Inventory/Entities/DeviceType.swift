//
//  DeviceType.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// The kind of a device at a site.
    public enum DeviceType: Sendable, Hashable, CaseIterable, RawRepresentable {
        case inverter
        case battery
        case batteryModule
        /// A power optimizer.
        case optimizer
        case meter
        case evCharger
        /// Backup interface.
        case bui
        case gateway
        /// A value this version of the package does not know yet, as the
        /// API sent it. New values are added on the server over time.
        case unknown(String)

        /// The known values, without ``unknown(_:)``.
        public static let allCases: [DeviceType] = [.inverter, .battery, .batteryModule, .optimizer, .meter, .evCharger, .bui, .gateway]

        /// The case for an API value, or ``unknown(_:)``. Never `nil`.
        public init(rawValue: String) {
            self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
        }

        /// The value as the API sends it.
        public var rawValue: String {
            switch self {
            case .inverter: "INVERTER"
            case .battery: "BATTERY"
            case .batteryModule: "BATTERY_MODULE"
            case .optimizer: "OPTIMIZER"
            case .meter: "METER"
            case .evCharger: "EV_CHARGER"
            case .bui: "BUI"
            case .gateway: "GATEWAY"
            case .unknown(let rawValue): rawValue
            }
        }
    }
}
