//
//  Voltage.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Unit of a voltage value.
    public enum Voltage: String, Sendable, CaseIterable {
        case volt = "VOLT"
    }
}
