//
//  InverterMode.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// An inverter's decoded operating state.
    public enum InverterMode: Sendable, Hashable, CaseIterable, RawRepresentable {
        case off
        case sleeping
        case starting
        /// Producing normally (maximum power point tracking).
        case mppt
        case throttled
        case shuttingDown
        case fault
        case standby
        case lockedStandby
        case lockedFireFighters
        case locked
        case lockedCommTimeout
        case lockedInvTrip
        case lockedInvArcDetected
        case lockedInvBackupOverConsumption
        case lockedDG
        /// The raw value keeps the spec's spelling, `BALNCER`.
        case lockedPhaseBalancer
        case lockedPreCommissioning
        case lockedInternal
        /// A value this version of the package does not know yet, as the
        /// API sent it. New values are added on the server over time.
        case unknown(String)

        /// The known values, without ``unknown(_:)``.
        public static let allCases: [InverterMode] = [.off, .sleeping, .starting, .mppt, .throttled, .shuttingDown, .fault, .standby, .lockedStandby, .lockedFireFighters, .locked, .lockedCommTimeout, .lockedInvTrip, .lockedInvArcDetected, .lockedInvBackupOverConsumption, .lockedDG, .lockedPhaseBalancer, .lockedPreCommissioning, .lockedInternal]

        /// The case for an API value, or ``unknown(_:)``. Never `nil`.
        public init(rawValue: String) {
            self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
        }

        /// The value as the API sends it.
        public var rawValue: String {
            switch self {
            case .off: "OFF"
            case .sleeping: "SLEEPING"
            case .starting: "STARTING"
            case .mppt: "MPPT"
            case .throttled: "THROTTLED"
            case .shuttingDown: "SHUTTING_DOWN"
            case .fault: "FAULT"
            case .standby: "STANDBY"
            case .lockedStandby: "LOCKED_STANDBY"
            case .lockedFireFighters: "LOCKED_FIRE_FIGHTERS"
            case .locked: "LOCKED"
            case .lockedCommTimeout: "LOCKED_COMM_TIMEOUT"
            case .lockedInvTrip: "LOCKED_INV_TRIP"
            case .lockedInvArcDetected: "LOCKED_INV_ARC_DETECTED"
            case .lockedInvBackupOverConsumption: "LOCKED_INV_BACKUP_OVER_CONSUMPTION"
            case .lockedDG: "LOCKED_DG"
            case .lockedPhaseBalancer: "LOCKED_PHASE_BALNCER"
            case .lockedPreCommissioning: "LOCKED_PRE_COMMISSIONING"
            case .lockedInternal: "LOCKED_INTERNAL"
            case .unknown(let rawValue): rawValue
            }
        }
    }
}

extension Monitoring {
    /// One inverter-mode sample.
    public struct InverterModeValue: Sendable, Hashable {
        /// Start of the bucket this sample covers.
        public let timestamp: Date
        /// The last known mode in the bucket. `nil` if there is no sample.
        public let mode: InverterMode?

        public init(timestamp: Date, mode: InverterMode?) {
            self.timestamp = timestamp
            self.mode = mode
        }
    }
}
