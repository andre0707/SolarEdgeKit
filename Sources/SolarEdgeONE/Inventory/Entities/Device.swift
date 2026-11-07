//
//  Device.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Monitoring {
    /// A device installed at a site, as returned by Site Inventory and Device Info.
    public struct Device: Sendable, Hashable {
        /// The kind of device.
        public let type: DeviceType
        /// The physical serial number of the device. Use it for the
        /// per-device telemetry and measurement endpoints.
        public let serialNumber: String
        /// The device manufacturer.
        public let manufacturer: String
        /// Model name as sent by the API.
        public let model: String
        /// Part number, if the API sent one.
        public let partNumber: String?
        /// Power model as sent by the API.
        public let powerModel: String
        /// When the device was added to the site.
        public let createdAt: Date
        /// Firmware version, if the API sent one.
        public let firmwareVersion: String?
        /// Full firmware version string, e.g. `4.25.15.1.100.2059.2.100.1751`.
        /// `nil` when not reported, for example for meters and batteries.
        public let firmware: String?
        /// Serial number of the device this one is connected to, usually an
        /// inverter or a gateway. `nil` for top-level devices.
        public let connectedTo: String?
        /// Display name of the device this one is connected to. `nil` for
        /// top-level devices. Same as `parent?.name`; prefer ``parent``.
        public let connectedToName: String?
        /// The device this one is connected to. `nil` for top-level devices,
        /// for example a gateway or a standalone or leader inverter.
        public let parent: DeviceParent?
        /// Whether the device is active.
        public let active: Bool
        /// Output or capacity of the device. Only set for batteries and inverters.
        public let nameplate: Double?
        /// The display name of the device.
        public let name: String
        /// What the meter measures, e.g. `FeedIn`. Only set for meters.
        public let meterType: String?
        /// Whether the meter is physical or virtual (calculated), e.g. `physical`.
        /// Only set for meters.
        public let form: String?
        /// How the device communicates, if known.
        public let communicationType: CommunicationType?
        /// Number of power optimizers connected to this inverter, if known.
        public let connectedOptimizers: Int?

        public init(type: DeviceType, serialNumber: String, manufacturer: String, model: String, partNumber: String?, powerModel: String, createdAt: Date, firmwareVersion: String?, firmware: String?, connectedTo: String?, connectedToName: String?, parent: DeviceParent?, active: Bool, nameplate: Double?, name: String, meterType: String?, form: String?, communicationType: CommunicationType?, connectedOptimizers: Int?) {
            self.type = type
            self.serialNumber = serialNumber
            self.manufacturer = manufacturer
            self.model = model
            self.partNumber = partNumber
            self.powerModel = powerModel
            self.createdAt = createdAt
            self.firmwareVersion = firmwareVersion
            self.firmware = firmware
            self.connectedTo = connectedTo
            self.connectedToName = connectedToName
            self.parent = parent
            self.active = active
            self.nameplate = nameplate
            self.name = name
            self.meterType = meterType
            self.form = form
            self.communicationType = communicationType
            self.connectedOptimizers = connectedOptimizers
        }
    }
}
