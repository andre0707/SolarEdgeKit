//
//  MeterDirection.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// What a meter measures, used to filter the lifetime energy endpoints.
    public enum MeterDirection: String, Sendable, Hashable, CaseIterable {
        /// PV production.
        case production = "PRODUCTION"
        /// Site consumption.
        case consumption = "CONSUMPTION"
        /// Energy drawn from the grid. Sent as `PURCHASED`, the API's main name for it.
        case `import` = "PURCHASED"
        /// Energy fed into the grid. Sent as `FEEDIN`, the API's main name for it.
        case export = "FEEDIN"
    }
}
