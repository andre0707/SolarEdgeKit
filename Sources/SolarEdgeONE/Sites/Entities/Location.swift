//
//  Location.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A site's location as returned by Site List.
    ///
    /// Site Details returns more fields; see ``Monitoring/LocationExtended``.
    public struct Location: Sendable, Hashable {
        /// Street address, e.g. `2888 Main St`.
        public let address: String
        /// City of the site.
        public let city: String
        /// State or region name as sent by the API, e.g. `Wisconsin`.
        public let state: String
        /// Postal code, if the API sent one.
        public let zip: String?
        /// Country name as sent by the API, e.g. `United States`.
        public let country: String
        
        public init(address: String, city: String, state: String, zip: String?, country: String) {
            self.address = address
            self.city = city
            self.state = state
            self.zip = zip
            self.country = country
        }
    }
}
