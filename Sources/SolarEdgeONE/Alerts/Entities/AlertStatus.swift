//
//  AlertStatus.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Whether an alert is still active.
    public enum AlertStatus: Sendable, Hashable, CaseIterable, RawRepresentable {
        /// The alert is active.
        case open
        /// The alert is resolved.
        case closed
        /// A value this version of the package does not know yet, as the
        /// API sent it. New values are added on the server over time.
        case unknown(String)

        /// The known values, without ``unknown(_:)``.
        public static let allCases: [AlertStatus] = [.open, .closed]

        /// The case for an API value, or ``unknown(_:)``. Never `nil`.
        public init(rawValue: String) {
            self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
        }

        /// The value as the API sends it.
        public var rawValue: String {
            switch self {
            case .open: "OPEN"
            case .closed: "CLOSED"
            case .unknown(let rawValue): rawValue
            }
        }
    }
}
