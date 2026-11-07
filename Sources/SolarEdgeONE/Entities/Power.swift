//
//  Power.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Unit of a power value.
    public enum Power: String, Sendable, CaseIterable {
        case watt = "W"
        case kiloWatt = "KW"
        case megaWatt = "MW"
        /// Only returned by the Advanced Monitoring API; the Basic Monitoring
        /// endpoints do not accept it as a `unit` parameter.
        case gigaWatt = "GW"
    }
}
