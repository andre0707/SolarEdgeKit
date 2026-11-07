//
//  ProjectSite.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The address of a project (`ProjectAddress`). `nil` values are not sent.
    public struct ProjectAddress: Sendable, Hashable {
        /// The street.
        public var street: String?
        /// The city.
        public var city: String?
        /// The ZIP code.
        public var zipCode: String?

        public init(street: String? = nil, city: String? = nil, zipCode: String? = nil) {
            self.street = street
            self.city = city
            self.zipCode = zipCode
        }
    }

    /// The site of a created or updated project (`PublicApiResponse`), as
    /// returned by ``ProjectService``.
    public struct ProjectSite: Sendable, Hashable {
        /// The Designer site ID, e.g. for ``ReportsService/report(for:)``.
        public let siteID: SiteID
        /// The site in Designer's web app.
        public let siteURL: URL

        public init(siteID: SiteID, siteURL: URL) {
            self.siteID = siteID
            self.siteURL = siteURL
        }
    }
}
