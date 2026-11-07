//
//  SiteConfiguration.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Whether Weather Guard storm mode is on for a site, as returned by Weather
    /// Guard Configuration.
    public struct WeatherGuard: Sendable, Hashable {
        /// `true` while storm mode is enabled.
        public let isEnabled: Bool

        public init(isEnabled: Bool) {
            self.isEnabled = isEnabled
        }
    }
}

extension Monitoring {
    /// A site's battery backup reserve, as returned by Battery Backup Reserve
    /// Configuration: the minimum state of charge the battery keeps for a grid
    /// outage.
    public struct BatteryBackupReserve: Sendable, Hashable {
        /// Whether the backup reserve is in use.
        public enum Status: Sendable, Hashable, CaseIterable, RawRepresentable {
            case enabled
            case disabled
            /// A value this version of the package does not know yet, as the
            /// API sent it. New values are added on the server over time.
            case unknown(String)

            /// The known values, without ``unknown(_:)``.
            public static let allCases: [Status] = [.enabled, .disabled]

            /// The case for an API value, or ``unknown(_:)``. Never `nil`.
            public init(rawValue: String) {
                self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
            }

            /// The value as the API sends it.
            public var rawValue: String {
                switch self {
                case .enabled: "ENABLED"
                case .disabled: "DISABLED"
                case .unknown(let rawValue): rawValue
                }
            }
        }

        /// The reserved state of charge in percent. `nil` if the API sent none.
        public let percentage: Double?
        /// Whether the backup reserve is in use.
        public let status: Status

        public init(percentage: Double?, status: Status) {
            self.percentage = percentage
            self.status = status
        }
    }
}
