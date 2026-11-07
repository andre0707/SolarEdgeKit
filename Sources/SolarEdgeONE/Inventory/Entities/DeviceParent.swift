//
//  DeviceParent.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// The device another device is connected to.
    ///
    /// Use ``serialNumber`` as the stable key to rebuild the site's topology.
    public struct DeviceParent: Sendable, Hashable {
        /// The serial number of the parent device.
        public let serialNumber: String
        /// The kind of the parent device.
        public let type: DeviceType
        /// The display name of the parent device.
        public let name: String

        public init(serialNumber: String, type: DeviceType, name: String) {
            self.serialNumber = serialNumber
            self.type = type
            self.name = name
        }
    }
}
