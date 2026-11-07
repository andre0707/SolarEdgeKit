//
//  SiteOverview.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A site's production and consumption for a period, as returned by Site Overview.
    public struct SiteOverview: Sendable, Hashable {
        /// The SolarEdge Monitoring ID of the site.
        public let siteID: Site.ID
        /// Where the solar production went.
        public let production: SiteProduction
        /// Where the consumed energy came from.
        public let consumption: SiteConsumption

        public init(siteID: Site.ID, production: SiteProduction, consumption: SiteConsumption) {
            self.siteID = siteID
            self.production = production
            self.consumption = consumption
        }
    }
}
