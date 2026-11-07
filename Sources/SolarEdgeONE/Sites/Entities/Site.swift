//
//  Site.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Monitoring {
    /// A site as returned by Site List.
    ///
    /// Site Details returns more fields; see ``Monitoring/SiteDetails``.
    public struct Site: Sendable, Hashable, Identifiable {
        /// The SolarEdge Monitoring ID of a site.
        ///
        /// A distinct type, so a site ID cannot be mixed up with other numbers.
        /// Integer literals work directly, e.g. `let id: Site.ID = 93082`.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByIntegerLiteral, CustomStringConvertible {
            /// The numeric ID as used by the API.
            public let rawValue: Int
            public init(rawValue: Int) { self.rawValue = rawValue }
            public init(integerLiteral value: Int) { self.rawValue = value }
            /// The numeric ID as text, e.g. `93082`.
            public var description: String { String(rawValue) }
        }
        
        
        
        /// The SolarEdge Monitoring ID of the site.
        public let id: ID
        /// Name of the site.
        public let name: String
        /// Installed PV peak power in kWp.
        public let peakPower: Double
        /// The day the site was installed. Has no time or time zone; see
        /// ``CalendarDate/startOfDay(in:)`` to get a `Date`.
        public let installationDate: CalendarDate
        /// Address of the site.
        public let location: Location
        /// Whether the site's inverter has ever communicated with the Monitoring Platform.
        public let activationStatus: ActivationStatus
        /// Free-text note stored with the site, e.g. `Created via API, triggered from CRM`.
        public let note: String
        
        public init(id: ID, name: String, peakPower: Double, installationDate: CalendarDate, location: Location, activationStatus: ActivationStatus, note: String) {
            self.id = id
            self.name = name
            self.peakPower = peakPower
            self.installationDate = installationDate
            self.location = location
            self.activationStatus = activationStatus
            self.note = note
        }
    }
}
