//
//  MountingType.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// How PV modules are mounted.
    public enum MountingType: String, Sendable, Hashable, CaseIterable {
        /// `FLUSH_MOUNT`.
        case flushMount = "FLUSH_MOUNT"
        /// `TILTED`.
        case tilted = "TILTED"
        /// `DUAL_TILT`.
        case dualTilt = "DUAL_TILT"
    }
}
