//
//  SystemSetup.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// A group of PV modules of one model and direction (`PvModuleSetup`).
    public struct PvModuleSetup: Sendable, Hashable {
        /// The module model, e.g. from ``EstimationService/pvModules(manufacturer:)``.
        public var pvModuleID: PvModule.ID
        /// The number of modules. At least `1`.
        public var pvModuleCount: Int
        /// Which way the modules face.
        public var panelDirection: PanelDirection
        /// How the modules are mounted.
        public var mountType: MountingType

        public init(pvModuleID: PvModule.ID, pvModuleCount: Int, panelDirection: PanelDirection, mountType: MountingType) {
            self.pvModuleID = pvModuleID
            self.pvModuleCount = pvModuleCount
            self.panelDirection = panelDirection
            self.mountType = mountType
        }
    }

    /// Which way PV modules face (`PanelDirection`).
    public struct PanelDirection: Sendable, Hashable {
        /// The azimuth in degrees, `0` to `359`.
        public var azimuth: Double
        /// The tilt in degrees, `0` to `80`.
        public var tilt: Double

        public init(azimuth: Double, tilt: Double) {
            self.azimuth = azimuth
            self.tilt = tilt
        }
    }

    /// Installed batteries of one model (`Batteries`).
    public struct BatterySetup: Sendable, Hashable {
        /// The battery model, e.g. from ``EstimationService/batteries(manufacturer:phase:)``.
        public var batteryID: Battery.ID
        /// The number of batteries. At least `1`.
        public var batteryCount: Int

        public init(batteryID: Battery.ID, batteryCount: Int) {
            self.batteryID = batteryID
            self.batteryCount = batteryCount
        }
    }

    /// Financial assumptions over the system's lifetime (`SystemLifetime`).
    /// `nil` values use the API's defaults.
    public struct SystemLifetime: Sendable, Hashable {
        /// System lifetime in years. API default: `25`.
        public var years: Int?
        /// Cash flow discount rate per year, `0` to `1`. API default: `0`.
        public var discountRate: Double?
        /// Expected electricity price increase per year. API default: `0`.
        public var expectedElectricityPriceIncrease: Double?
        /// Expected production degradation per year, `0` to `1`. API default: `0.004`.
        public var expectedProductionDegradation: Double?

        public init(years: Int? = nil, discountRate: Double? = nil,
                    expectedElectricityPriceIncrease: Double? = nil, expectedProductionDegradation: Double? = nil) {
            self.years = years
            self.discountRate = discountRate
            self.expectedElectricityPriceIncrease = expectedElectricityPriceIncrease
            self.expectedProductionDegradation = expectedProductionDegradation
        }
    }

    /// The models used to generate the electrical design (`ElectricalDesign`).
    /// Discontinued models are not supported.
    public struct ElectricalDesign: Sendable, Hashable {
        /// Inverter model name, e.g. `SE10K`.
        public var inverterModel: String?
        /// Optimizer model name, e.g. `S440`.
        public var optimizerModel: String?

        public init(inverterModel: String? = nil, optimizerModel: String? = nil) {
            self.inverterModel = inverterModel
            self.optimizerModel = optimizerModel
        }
    }

    /// The technology type of the system.
    public enum SystemType: String, Sendable, Hashable, CaseIterable {
        /// `1Phase`.
        case singlePhase = "1Phase"
        /// `3Phase`.
        case threePhase = "3Phase"
    }
}
