//
//  ElectricCurrent.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Unit of an electric current value.
    public enum ElectricCurrent: String, Sendable, CaseIterable {
        case ampere = "AMPERE"
    }
}
