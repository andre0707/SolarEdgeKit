//
//  Location.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A site's location as returned by Site Details.
    ///
    /// Site List returns fewer fields; see ``Monitoring/Location``.
    public struct LocationExtended: Sendable, Hashable {
        /// Street address, e.g. `2888 Main St`.
        public let address: String
        /// Second address line, if the API sent one.
        public let address2: String?
        /// Latitude of the site.
        public let latitude: Double
        /// Longitude of the site.
        public let longitude: Double
        /// City of the site.
        public let city: String
        /// State or region name as sent by the API, e.g. `Wisconsin`.
        public let state: String
        /// State or region code, if the API sent one.
        public let stateCode: String?
        /// Postal code, if the API sent one.
        public let zip: String?
        /// Country name as sent by the API, e.g. `United States`.
        public let country: String
        /// Country code as sent by the API.
        public let countryCode: String
        /// The site's time zone, e.g. for ``CalendarDate/startOfDay(in:)``.
        /// `nil` if the API sent an identifier `TimeZone` does not know.
        public let timezone: TimeZone?
        
        public init(address: String, address2: String?, latitude: Double, longitude: Double, city: String, state: String, stateCode: String?, zip: String?, country: String, countryCode: String, timezone: TimeZone?) {
            self.address = address
            self.address2 = address2
            self.latitude = latitude
            self.longitude = longitude
            self.city = city
            self.state = state
            self.stateCode = stateCode
            self.zip = zip
            self.country = country
            self.countryCode = countryCode
            self.timezone = timezone
        }
    }
}
