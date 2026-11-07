//
//  Temperature.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Unit of a temperature value.
    public enum Temperature: String, Sendable, CaseIterable {
        case celsius = "CELSIUS"
    }
}
