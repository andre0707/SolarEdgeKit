//
//  UnitSystem.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Unit system for values the API can return in metric or imperial units.
    public enum UnitSystem: String, Sendable, CaseIterable {
        case metric = "METRIC"
        case imperial = "IMPERIAL"
    }
}
