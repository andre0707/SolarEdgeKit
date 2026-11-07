//
//  CommunicationType.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// How a device communicates with the Monitoring Platform. A device
    /// inherits the communication type of the inverter it is connected to.
    public enum CommunicationType: Sendable, Hashable, CaseIterable, RawRepresentable {
        case wifi
        case zigbee
        case ethernet
        case cdma
        case gsm
        case lte
        case rs485
        case rs232
        /// A value this version of the package does not know yet, as the
        /// API sent it. New values are added on the server over time. The API's
        /// own `UNKNOWN` also lands here, as `.unknown("UNKNOWN")`.
        case unknown(String)

        /// The known values, without ``unknown(_:)``.
        public static let allCases: [CommunicationType] = [.wifi, .zigbee, .ethernet, .cdma, .gsm, .lte, .rs485, .rs232]

        /// The case for an API value, or ``unknown(_:)``. Never `nil`.
        public init(rawValue: String) {
            self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
        }

        /// The value as the API sends it.
        public var rawValue: String {
            switch self {
            case .wifi: "WIFI"
            case .zigbee: "ZIGBEE"
            case .ethernet: "ETHERNET"
            case .cdma: "CDMA"
            case .gsm: "GSM"
            case .lte: "LTE"
            case .rs485: "RS485"
            case .rs232: "RS232"
            case .unknown(let rawValue): rawValue
            }
        }
    }
}
