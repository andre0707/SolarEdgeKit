//
//  PowerFlow.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// The latest power-flow sample of a site, as returned by Site Power Flow:
    /// the power on the PV, load, storage and grid nodes and its direction.
    ///
    /// Without a live session the sample can be up to 5 minutes old; check
    /// ``updatedAt`` before using the values, and ``isLive`` to see whether a
    /// session started with ``AdvancedService/startLivePowerFlow(for:)`` is running.
    public struct PowerFlow: Sendable, Hashable {
        /// When the sample was taken. `nil` if the API sent none.
        public let updatedAt: Date?
        /// The sampling interval in seconds: `300` without a live session, a
        /// few seconds while one is running.
        public let refreshRate: Int
        /// The unit of all `power` values in this sample.
        public let unit: Power
        /// The PV array.
        public let pv: PowerFlowNode
        /// The site's consumption.
        public let load: PowerFlowNode
        /// The battery.
        public let storage: PowerFlowStorage
        /// The grid connection.
        public let grid: PowerFlowGrid

        /// `true` while a live session is running, i.e. the sampling interval is
        /// shorter than the standard 5 minutes.
        public var isLive: Bool { refreshRate < 300 }

        public init(updatedAt: Date?, refreshRate: Int, unit: Power, pv: PowerFlowNode, load: PowerFlowNode, storage: PowerFlowStorage, grid: PowerFlowGrid) {
            self.updatedAt = updatedAt
            self.refreshRate = refreshRate
            self.unit = unit
            self.pv = pv
            self.load = load
            self.storage = storage
            self.grid = grid
        }
    }
}

extension Monitoring {
    /// A node of the power flow: PV or load.
    public struct PowerFlowNode: Sendable, Hashable {
        /// Whether the node is currently producing or consuming power.
        public let active: Bool
        /// Current power, in the sample's unit. `nil` if not reported.
        public let power: Double?

        public init(active: Bool, power: Double?) {
            self.active = active
            self.power = power
        }
    }
}

extension Monitoring {
    /// The battery node of the power flow.
    public struct PowerFlowStorage: Sendable, Hashable {
        /// Whether the battery is charging or discharging.
        public enum Status: Sendable, Hashable, CaseIterable, RawRepresentable {
            case charge
            case discharge
            case idle
            /// A value this version of the package does not know yet, as the
            /// API sent it. New values are added on the server over time.
            case unknown(String)

            /// The known values, without ``unknown(_:)``.
            public static let allCases: [Status] = [.charge, .discharge, .idle]

            /// The case for an API value, or ``unknown(_:)``. Never `nil`.
            public init(rawValue: String) {
                self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
            }

            /// The value as the API sends it.
            public var rawValue: String {
                switch self {
                case .charge: "CHARGE"
                case .discharge: "DISCHARGE"
                case .idle: "IDLE"
                case .unknown(let rawValue): rawValue
                }
            }
        }

        /// Whether the battery is currently active.
        public let active: Bool
        /// Current charge or discharge power, in the sample's unit. `nil` if not reported.
        public let power: Double?
        /// The direction of the power. `nil` if not reported.
        public let status: Status?
        /// Current charge level in percent. `nil` if not reported.
        public let chargeLevel: Int?

        public init(active: Bool, power: Double?, status: Status?, chargeLevel: Int?) {
            self.active = active
            self.power = power
            self.status = status
            self.chargeLevel = chargeLevel
        }
    }
}

extension Monitoring {
    /// The grid node of the power flow.
    public struct PowerFlowGrid: Sendable, Hashable {
        /// Whether power is drawn from or fed into the grid.
        public enum Status: Sendable, Hashable, CaseIterable, RawRepresentable {
            case `import`
            case export
            case idle
            case gridOutage
            /// A value this version of the package does not know yet, as the
            /// API sent it. New values are added on the server over time.
            case unknown(String)

            /// The known values, without ``unknown(_:)``.
            public static let allCases: [Status] = [.`import`, .export, .idle, .gridOutage]

            /// The case for an API value, or ``unknown(_:)``. Never `nil`.
            public init(rawValue: String) {
                self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
            }

            /// The value as the API sends it.
            public var rawValue: String {
                switch self {
                case .import: "IMPORT"
                case .export: "EXPORT"
                case .idle: "IDLE"
                case .gridOutage: "GRID_OUTAGE"
                case .unknown(let rawValue): rawValue
                }
            }
        }

        /// Whether the grid connection is currently active.
        public let active: Bool
        /// Current import or export power, in the sample's unit. `nil` if not reported.
        public let power: Double?
        /// The direction of the power, or a grid outage. `nil` if not reported.
        public let status: Status?

        public init(active: Bool, power: Double?, status: Status?) {
            self.active = active
            self.power = power
            self.status = status
        }
    }
}
