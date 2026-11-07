//
//  SitePage.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// One page of the site list.
    public struct SitePage: Sendable, Hashable {
        /// The sites on this page. Empty if no site matches.
        public let sites: [Site]
        /// 1-based page number that was requested.
        public let page: Int
        /// Page size that was requested.
        public let pageSize: Int
        /// Total number of sites matching the filter, across all pages.
        /// `nil` if the API sent no usable count (a negative value).
        public let totalCount: Int?

        /// `true` when another page may follow.
        ///
        /// Uses ``totalCount`` when it is known; otherwise assumes another page
        /// while this one is full.
        public var mayHaveMore: Bool {
            if let totalCount { return page * pageSize < totalCount }
            return sites.count >= pageSize
        }

        public init(sites: [Site], page: Int, pageSize: Int, totalCount: Int? = nil) {
            self.sites = sites
            self.page = page
            self.pageSize = pageSize
            self.totalCount = totalCount
        }
    }
}
