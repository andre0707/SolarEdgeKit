//
//  ActivationStatus.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Whether a site's inverter has ever communicated with the Monitoring Platform.
    public enum ActivationStatus: Sendable, Hashable, RawRepresentable {
        /// Indicates that the inverter has communicated with the Monitoring Platform at least once.
        case active
        /// Indicates that the inverter has never communicated with the Monitoring Platform.
        case pending
        /// A value this library does not know yet, as sent by the API.
        case unknown(String)

        /// Never fails: values other than `ACTIVE` and `PENDING` become ``unknown(_:)``.
        public init(rawValue: String) {
            switch rawValue {
                case "ACTIVE":
                    self = .active
                case "PENDING":
                    self = .pending
                default:
                    self = .unknown(rawValue)
            }
        }

        /// The value as sent by the API, e.g. `ACTIVE`.
        public var rawValue: String {
            switch self {
                case .active: "ACTIVE"
                case .pending: "PENDING"
                case .unknown(let value): value
            }
        }
    }
}
