//
//  SitePerformance.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A site's performance for a period, as returned by Site Performance.
    public struct SitePerformance: Sendable, Hashable {
        /// The SolarEdge Monitoring ID of the site.
        public let siteID: Site.ID
        /// Energy produced per installed peak power, in kWh/kWp.
        public let specificYield: Double
        /// Actual yield compared with the theoretical yield, e.g. `0.8`.
        public let performanceRatio: Double?

        public init(siteID: Site.ID, specificYield: Double, performanceRatio: Double?) {
            self.siteID = siteID
            self.specificYield = specificYield
            self.performanceRatio = performanceRatio
        }
    }
}
