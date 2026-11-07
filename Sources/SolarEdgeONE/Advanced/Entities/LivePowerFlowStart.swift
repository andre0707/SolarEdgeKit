//
//  LivePowerFlowStart.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// What Start Live Power Flow answered, if it sent a body.
    public struct LivePowerFlowStart: Sendable, Hashable {
        /// Confirmation status of the activation, as sent by the API.
        public let status: String
        /// The sampling interval in seconds of the new live session.
        public let refreshRate: Int

        public init(status: String, refreshRate: Int) {
            self.status = status
            self.refreshRate = refreshRate
        }
    }
}
