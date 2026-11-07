//
//  SiteDetails.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Monitoring {
    /// The full metadata record of one site, as returned by Site Details.
    public struct SiteDetails: Sendable, Hashable, Identifiable {
        /// The SolarEdge Monitoring ID of the site.
        public let id: Site.ID
        /// Name of the site.
        public let name: String
        /// The account that owns the site.
        public let accountID: Int
        /// Installed PV peak power in kWp.
        public let peakPower: Double
        /// The day the site was installed. Has no time or time zone; see
        /// ``CalendarDate/startOfDay(in:)`` to get a `Date`.
        public let installationDate: CalendarDate
        /// The last time the site received a communication from the inverter.
        public let lastUpdateTime: Date
        /// Address, coordinates and time zone of the site.
        public let location: LocationExtended
        /// Whether the site's inverter has ever communicated with the Monitoring Platform.
        public let activationStatus: ActivationStatus
        /// Free-text note stored with the site, e.g. `Created via API, triggered from CRM`.
        public let note: String

        public init(id: Site.ID, name: String, accountID: Int, peakPower: Double, installationDate: CalendarDate, lastUpdateTime: Date, location: LocationExtended, activationStatus: ActivationStatus, note: String) {
            self.id = id
            self.name = name
            self.accountID = accountID
            self.peakPower = peakPower
            self.installationDate = installationDate
            self.lastUpdateTime = lastUpdateTime
            self.location = location
            self.activationStatus = activationStatus
            self.note = note
        }
    }
}
