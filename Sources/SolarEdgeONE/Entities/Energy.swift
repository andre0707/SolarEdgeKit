//
//  Energy.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Unit of an energy value.
    public enum Energy: String, Sendable, CaseIterable {
        case wattHour = "WH"
        case kiloWattHour = "KWH"
        case megaWattHour = "MWH"
        case gigaWattHour = "GWH"
    }
}
