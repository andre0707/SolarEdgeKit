//
//  EstimationParameters.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Designer {
    /// The input of ``EstimationService/estimate(_:)`` (`EstimationParams`).
    ///
    /// The non-optional values are required by the API. Optional values that
    /// are `nil` are not sent, so the API uses its defaults. Values outside
    /// the ranges the spec gives are rejected before any request is sent.
    public struct EstimationParameters: Sendable, Hashable {
        /// Whether the site is residential or commercial.
        public enum Profile: String, Sendable, Hashable, CaseIterable {
            /// `RESIDENTIAL`.
            case residential = "RESIDENTIAL"
            /// `COMMERCIAL`.
            case commercial = "COMMERCIAL"
        }

        /// Longitude of the site, `-180` to `180`.
        public var longitude: Double
        /// Latitude of the site, `-90` to `90`.
        public var latitude: Double
        /// The country code of the site, e.g. `DE`.
        public var countryCode: String
        /// The state code of the site.
        public var stateCode: String?
        /// The grid of the site, e.g. from ``EstimationService/gridCodes(country:)``.
        public var gridID: GridCode.ID
        /// The annual consumption in kWh. At least `0`.
        public var consumption: Double?
        /// Hourly distribution of the consumption over a year: exactly 8760
        /// values, none negative, summing up to 1.
        public var consumptionProfile: [Double]?
        /// A predefined consumption profile, e.g. from
        /// ``EstimationService/consumptionProfiles(country:)``.
        public var consumptionProfileID: ConsumptionProfile.ID?
        /// Export limit in W. At least `0`.
        public var exportLimit: Double?
        /// Power factor, `0.8` to `1`. API default: `1`.
        public var powerFactor: Double?
        /// The PV module groups.
        public var pvModuleSetup: [PvModuleSetup]
        /// The DC/AC oversizing ratio, `0` to `2`. API default: `1.2`.
        public var oversizing: Double?
        /// The technology type of the system.
        public var systemType: SystemType?
        /// The installed batteries.
        public var batteries: [BatterySetup]?
        /// The import rate, e.g. from
        /// ``EstimationService/utilityRates(utilityNames:rateType:orphanRates:country:state:)``.
        public var utilityImportRateID: UtilityRate.ID
        /// The export rate.
        public var utilityExportRateID: UtilityRate.ID
        /// Total system price in local currency.
        public var systemPrice: Double?
        /// Price per Wh in local currency (the spec's name says per watt).
        public var pricePerWatt: Double?
        /// Financial assumptions over the system's lifetime.
        public var systemLifetime: SystemLifetime?
        /// Shading factor, `0` to `1`.
        public var shadingFactor: Double
        /// Whether to use the battery management algorithm (sent as `useBma`).
        /// API default: `false`.
        public var useBatteryManagementAlgorithm: Bool?
        /// Incentives to apply, e.g. from ``EstimationService/incentives(country:state:)``.
        /// API default: none.
        public var incentives: [Incentive.ID]?
        /// Whether the site is residential or commercial.
        public var profile: Profile?
        /// The models used to generate the electrical design.
        public var electricalDesign: ElectricalDesign?

        public init(
            longitude: Double,
            latitude: Double,
            countryCode: String,
            stateCode: String? = nil,
            gridID: GridCode.ID,
            consumption: Double? = nil,
            consumptionProfile: [Double]? = nil,
            consumptionProfileID: ConsumptionProfile.ID? = nil,
            exportLimit: Double? = nil,
            powerFactor: Double? = nil,
            pvModuleSetup: [PvModuleSetup],
            oversizing: Double? = nil,
            systemType: SystemType? = nil,
            batteries: [BatterySetup]? = nil,
            utilityImportRateID: UtilityRate.ID,
            utilityExportRateID: UtilityRate.ID,
            systemPrice: Double? = nil,
            pricePerWatt: Double? = nil,
            systemLifetime: SystemLifetime? = nil,
            shadingFactor: Double,
            useBatteryManagementAlgorithm: Bool? = nil,
            incentives: [Incentive.ID]? = nil,
            profile: Profile? = nil,
            electricalDesign: ElectricalDesign? = nil
        ) {
            self.longitude = longitude
            self.latitude = latitude
            self.countryCode = countryCode
            self.stateCode = stateCode
            self.gridID = gridID
            self.consumption = consumption
            self.consumptionProfile = consumptionProfile
            self.consumptionProfileID = consumptionProfileID
            self.exportLimit = exportLimit
            self.powerFactor = powerFactor
            self.pvModuleSetup = pvModuleSetup
            self.oversizing = oversizing
            self.systemType = systemType
            self.batteries = batteries
            self.utilityImportRateID = utilityImportRateID
            self.utilityExportRateID = utilityExportRateID
            self.systemPrice = systemPrice
            self.pricePerWatt = pricePerWatt
            self.systemLifetime = systemLifetime
            self.shadingFactor = shadingFactor
            self.useBatteryManagementAlgorithm = useBatteryManagementAlgorithm
            self.incentives = incentives
            self.profile = profile
            self.electricalDesign = electricalDesign
        }
    }
}

extension Designer.EstimationParameters {
    /// Checks the ranges and counts the spec gives.
    func validate() throws {
        try checkRange(longitude, -180...180, "longitude")
        try checkRange(latitude, -90...90, "latitude")
        try validateRequired(countryCode, name: "countryCode")
        try validateRequired(gridID.rawValue, name: "gridId")
        try checkRange(consumption, 0..., "consumption")
        try validateConsumptionProfile(consumptionProfile)
        try checkRange(exportLimit, 0..., "exportLimit")
        try checkRange(powerFactor, 0.8...1, "powerFactor")
        try check(!pvModuleSetup.isEmpty, "'pvModuleSetup' must not be empty")
        try pvModuleSetup.forEach { try $0.validate() }
        try checkRange(oversizing, 0...2, "oversizing")
        try batteries?.forEach { try $0.validate() }
        try systemLifetime?.validate()
        try checkRange(shadingFactor, 0...1, "shadingFactor")
    }
}
