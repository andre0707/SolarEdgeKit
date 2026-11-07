//
//  SiteFilter.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Narrows down `SitesService.list`. All set fields must match.
    public struct SiteFilter: Sendable, Hashable {
        /// Filter by site name (substring)
        public var name: String?
        /// Filter only for sites in this city
        public var city: String?
        /// State abbreviation, e.g. `CA`.
        public var state: String?
        /// Filter only for sites included within this group
        public var group: UUID?

        public init(name: String? = nil, city: String? = nil, state: String? = nil, group: UUID? = nil) {
            self.name = name
            self.city = city
            self.state = state
            self.group = group
        }
    }
}
