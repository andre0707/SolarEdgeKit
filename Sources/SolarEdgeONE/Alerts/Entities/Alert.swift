//
//  Alert.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// An equipment or performance alert of a site.
    ///
    /// For error codes and troubleshooting, see SolarEdge's inverter error
    /// code guide in the Knowledge Center.
    public struct Alert: Sendable, Hashable, Identifiable {
        /// The SolarEdge ID of an alert.
        ///
        /// A distinct type, so an alert ID cannot be mixed up with a site ID.
        /// Integer literals work directly.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
            /// The numeric ID as used by the API.
            public let rawValue: Int
            public init(rawValue: Int) { self.rawValue = rawValue }
            public init(integerLiteral value: Int) { self.rawValue = value }
            /// The numeric ID as text.
            public var description: String { String(rawValue) }
        }

        /// The ID of the alert.
        public let id: ID
        /// The site the alert belongs to.
        public let siteID: Site.ID
        /// Alert category as sent by the API, e.g. `EQUIPMENT`.
        public let category: String
        /// Alert type as sent by the API, e.g. `DC Isolation`.
        public let type: String
        /// How severe the alert is, from 1 to 9.
        public let impact: Int
        /// Whether the alert is still open.
        public let status: AlertStatus
        /// When the alert was first triggered.
        public let firstTrigger: Date
        /// When the alert was last triggered.
        public let lastTrigger: Date
        /// When the alert was closed. `nil` while it is open.
        public let closeDate: Date?
        /// Until when the alert is muted. `nil` if it is not muted.
        public let muteExpirationDate: Date?
        /// The device that raised the alert.
        public let component: AlertComponent
        /// Error codes as sent by the API, e.g. `1800x105`.
        public let errorCodes: [String]

        public init(id: ID, siteID: Site.ID, category: String, type: String, impact: Int, status: AlertStatus, firstTrigger: Date, lastTrigger: Date, closeDate: Date?, muteExpirationDate: Date?, component: AlertComponent, errorCodes: [String]) {
            self.id = id
            self.siteID = siteID
            self.category = category
            self.type = type
            self.impact = impact
            self.status = status
            self.firstTrigger = firstTrigger
            self.lastTrigger = lastTrigger
            self.closeDate = closeDate
            self.muteExpirationDate = muteExpirationDate
            self.component = component
            self.errorCodes = errorCodes
        }
    }
}
