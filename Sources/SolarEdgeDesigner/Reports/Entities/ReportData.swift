//
//  ReportData.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The ID of a Designer site.
    ///
    /// Not the same as a Monitoring site ID (`Monitoring.Site.ID`): Designer and
    /// Monitoring number their sites separately. Integer literals work
    /// directly, e.g. `let id: Designer.SiteID = 1371991379163700`.
    public struct SiteID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
        /// The numeric ID as used by the API.
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
        public init(integerLiteral value: Int) { self.rawValue = value }
        /// The numeric ID as text.
        public var description: String { String(rawValue) }
    }

    /// The report of a site marked as done, and the site's details, as
    /// returned by ``ReportsService/report(for:)`` and
    /// ``ReportsService/report(forExternalID:)``.
    ///
    /// The report is the one generated on the site's summary and reports page.
    public struct ReportData: Sendable, Hashable {
        /// The report.
        public let siteReport: SiteReport
        /// The site's customer and address.
        public let siteDetails: SiteDetails

        public init(siteReport: SiteReport, siteDetails: SiteDetails) {
            self.siteReport = siteReport
            self.siteDetails = siteDetails
        }
    }
}
