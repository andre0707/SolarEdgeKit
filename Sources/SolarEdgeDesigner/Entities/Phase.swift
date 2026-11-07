//
//  Phase.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// Single- or three-phase electricity.
    public enum Phase: Int, Sendable, Hashable, CaseIterable {
        /// Single-phase.
        case single = 1
        /// Three-phase.
        case three = 3
    }
}
