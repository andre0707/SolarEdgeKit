//
//  AlertComponent.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// The device that raised an alert.
    public struct AlertComponent: Sendable, Hashable {
        /// Name of the device, e.g. `Inverter 2`.
        public let name: String
        /// Serial number of the device.
        public let serialNumber: String

        public init(name: String, serialNumber: String) {
            self.name = name
            self.serialNumber = serialNumber
        }
    }
}
