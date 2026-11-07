//
//  SiteDetails.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The general details of a Designer site, part of ``ReportData``.
    ///
    /// Not the Monitoring API's `Monitoring.SiteDetails`.
    public struct SiteDetails: Sendable, Hashable, Identifiable {
        /// The customer a site is designed for.
        public struct Customer: Sendable, Hashable {
            /// The customer's first name.
            public let firstName: String
            /// The customer's last name.
            public let lastName: String
            /// The customer's company.
            public let company: String

            public init(firstName: String, lastName: String, company: String) {
                self.firstName = firstName
                self.lastName = lastName
                self.company = company
            }
        }

        /// The ID of the site.
        public let id: SiteID
        /// The name of the site.
        public let name: String
        /// The customer.
        public let customerDetails: Customer
        /// The country.
        public let country: String
        /// The state.
        public let state: String
        /// The city.
        public let city: String
        /// The street.
        public let street: String
        /// The ZIP code.
        public let zipCode: String
        /// The grid.
        public let grid: String
        /// The currency.
        public let currency: String

        public init(id: SiteID, name: String, customerDetails: Customer, country: String, state: String, city: String,
                    street: String, zipCode: String, grid: String, currency: String) {
            self.id = id
            self.name = name
            self.customerDetails = customerDetails
            self.country = country
            self.state = state
            self.city = city
            self.street = street
            self.zipCode = zipCode
            self.grid = grid
            self.currency = currency
        }
    }
}
