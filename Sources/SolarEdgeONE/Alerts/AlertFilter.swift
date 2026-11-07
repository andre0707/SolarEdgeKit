//
//  AlertFilter.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// Narrows down fleet alerts. All set fields must match.
    public struct AlertFilter: Sendable, Hashable {
        /// Only alerts of sites in this group.
        public var group: UUID?
        /// Only alerts of this type, e.g. `DC Isolation`.
        public var type: String?
        /// Only alerts of sites in this state, by abbreviation, e.g. `CA`.
        public var state: String?
        /// Only alerts of sites in this city.
        public var city: String?

        public init(group: UUID? = nil, type: String? = nil, state: String? = nil, city: String? = nil) {
            self.group = group
            self.type = type
            self.state = state
            self.city = city
        }
    }
}
