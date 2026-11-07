//
//  AlertPage.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// One page of alerts.
    public struct AlertPage: Sendable, Hashable {
        /// The alerts on this page. Empty if there are none.
        public let alerts: [Alert]
        /// 1-based page number that was requested.
        public let page: Int
        /// Page size that was requested.
        public let pageSize: Int

        /// `true` when the page is full, so another page may follow.
        /// The API does not return a total count for alerts.
        public var mayHaveMore: Bool { alerts.count >= pageSize }

        public init(alerts: [Alert], page: Int, pageSize: Int) {
            self.alerts = alerts
            self.page = page
            self.pageSize = pageSize
        }
    }
}
