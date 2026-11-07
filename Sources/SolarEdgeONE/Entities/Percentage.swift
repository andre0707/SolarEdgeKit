//
//  Percentage.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Unit of a percentage value, e.g. a battery's state of energy.
    ///
    /// The spec does not explain how the two differ; its examples use
    /// values from 0 to 100 for ``percentage``.
    public enum Percentage: String, Sendable, CaseIterable {
        case percentage = "PERCENTAGE"
        case percentage100 = "PERCENTAGE_100"
    }
}
