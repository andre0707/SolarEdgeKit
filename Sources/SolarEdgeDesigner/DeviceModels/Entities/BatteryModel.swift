//
//  BatteryModel.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// A battery model, as returned by
    /// ``DeviceModelsService/models(for:countryCode:stateCode:sector:)``.
    ///
    /// The spec documents neither meaning nor units of these values beyond
    /// those in the names; names and types mirror it.
    public struct BatteryModel: Sendable, Hashable {
        /// The values of `connectionType`.
        public enum ConnectionType: Sendable, Hashable, CaseIterable, RawRepresentable {
            /// `SERIAL`.
            case serial
            /// `PARALLEL`.
            case parallel
            /// A value this version of the package does not know yet, as the
            /// API sent it. New values are added on the server over time.
            case unknown(String)

            /// The known values, without ``unknown(_:)``.
            public static let allCases: [ConnectionType] = [.serial, .parallel]

            /// The case for an API value, or ``unknown(_:)``. Never `nil`.
            public init(rawValue: String) {
                self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
            }

            /// The value as the API sends it.
            public var rawValue: String {
                switch self {
                case .serial: "SERIAL"
                case .parallel: "PARALLEL"
                case .unknown(let rawValue): rawValue
                }
            }
        }

        /// ID.
        public let id: String
        /// Display name.
        public let displayName: String
        /// Usable capacity Wh.
        public let usableCapacityWh: Int
        /// Minimum state energy.
        public let minStateEnergy: Double
        /// Nameplate capacity Wh.
        public let nameplateCapacityWh: Int
        /// Maximum input power W.
        public let maxInputPowerW: Int
        /// Maximum output power W.
        public let maxOutputPowerW: Int
        /// Charge efficiency.
        public let chargeEfficiency: Double
        /// Discharge efficiency.
        public let dischargeEfficiency: Double
        /// Discontinued.
        public let discontinued: Bool
        /// Deleted.
        public let deleted: Bool
        /// Maximum inverters with batteries per site.
        public let maxInvertersWithBatteriesPerSite: Int
        /// Phase.
        public let phase: Int
        /// Manufacturer ID.
        public let manufacturerId: String
        /// Connection type.
        public let connectionType: ConnectionType
        /// Experimental.
        public let experimental: Bool
        /// Made in country.
        public let madeInCountry: String

        public init(id: String, displayName: String, usableCapacityWh: Int, minStateEnergy: Double, nameplateCapacityWh: Int, maxInputPowerW: Int, maxOutputPowerW: Int, chargeEfficiency: Double, dischargeEfficiency: Double, discontinued: Bool, deleted: Bool, maxInvertersWithBatteriesPerSite: Int, phase: Int, manufacturerId: String, connectionType: ConnectionType, experimental: Bool, madeInCountry: String) {
            self.id = id
            self.displayName = displayName
            self.usableCapacityWh = usableCapacityWh
            self.minStateEnergy = minStateEnergy
            self.nameplateCapacityWh = nameplateCapacityWh
            self.maxInputPowerW = maxInputPowerW
            self.maxOutputPowerW = maxOutputPowerW
            self.chargeEfficiency = chargeEfficiency
            self.dischargeEfficiency = dischargeEfficiency
            self.discontinued = discontinued
            self.deleted = deleted
            self.maxInvertersWithBatteriesPerSite = maxInvertersWithBatteriesPerSite
            self.phase = phase
            self.manufacturerId = manufacturerId
            self.connectionType = connectionType
            self.experimental = experimental
            self.madeInCountry = madeInCountry
        }
    }
}
