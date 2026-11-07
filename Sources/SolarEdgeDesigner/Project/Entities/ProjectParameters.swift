//
//  ProjectParameters.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The input of ``ProjectService/create(_:)`` (`ProjectParams`).
    ///
    /// The non-optional values are required by the API. Optional values that
    /// are `nil` are not sent, so the API uses its defaults. Values outside
    /// the ranges the spec gives are rejected before any request is sent.
    public struct ProjectParameters: Sendable, Hashable {
        /// The project name, at most 48 characters.
        public var name: String
        /// A custom ID for the project, at most 128 characters. Use it with ``ReportsService/report(forExternalID:)``.
        public var externalID: String?
        /// The email of the project owner. `nil` makes the account administrator the owner.
        public var createdBy: String?
        /// Longitude of the site, `-180` to `180`.
        public var longitude: Double
        /// Latitude of the site, `-90` to `90`.
        public var latitude: Double
        /// The country code of the site, e.g. `DE`.
        public var countryCode: String
        /// The state code of the site.
        public var stateCode: String?
        /// The address of the project.
        public var address: ProjectAddress?
        /// The grid of the site, e.g. from ``EstimationService/gridCodes(country:)``.
        public var gridID: GridCode.ID?
        /// The annual consumption in kWh, at least `0`. Required with ``consumptionProfile``; interchangeable with ``monthlyBill``.
        public var consumption: Double?
        /// The average monthly electricity bill without SolarEdge, at least `0`. Interchangeable with ``consumption``.
        public var monthlyBill: Double?
        /// Hourly distribution of the consumption over a year: exactly 8760 values, none negative, summing up to 1. Give either this or ``consumptionProfileID``.
        public var consumptionProfile: [Double]?
        /// A predefined consumption profile, e.g. from ``EstimationService/consumptionProfiles(country:)``. Give either this or ``consumptionProfile``.
        public var consumptionProfileID: ConsumptionProfile.ID?
        /// Export limit in W, at least `0`.
        public var exportLimit: Double?
        /// Power factor, `0.8` to `1`. API default: `1`.
        public var powerFactor: Double?
        /// PV module groups for automatic layout generation.
        public var pvModuleSetup: [PvModuleSetup]?
        /// A detailed PV layout (`pvLayoutConfig`).
        public var pvLayout: PvLayout?
        /// The DC/AC oversizing ratio, `0` to `2`.
        public var oversizing: Double
        /// The technology type of the system.
        public var systemType: SystemType
        /// Whether backup information should be provided. API default: `true`.
        public var backup: Bool?
        /// The installed batteries.
        public var batteries: [BatterySetup]?
        /// The inverter and optimizer models for the electrical design.
        public var electricalDesign: ElectricalDesign?
        /// Incentives to apply, e.g. from ``EstimationService/incentives(country:state:)``. API default: none.
        public var incentives: [Incentive.ID]?
        /// The import rate.
        public var utilityImportRateID: UtilityRate.ID?
        /// The export rate.
        public var utilityExportRateID: UtilityRate.ID?
        /// Total system price in local currency.
        public var systemPrice: Double?
        /// Price per Wh in local currency (the spec's name says per watt).
        public var pricePerWatt: Double?
        /// Financial assumptions over the system's lifetime.
        public var systemLifetime: SystemLifetime?
        /// Shading factor, `0` to `1`.
        public var shadingFactor: Double?
        /// Whether to use the battery management algorithm (sent as `useBma`).
        /// API default: `false`.
        public var useBatteryManagementAlgorithm: Bool?

        public init(
            name: String,
            externalID: String? = nil,
            createdBy: String? = nil,
            longitude: Double,
            latitude: Double,
            countryCode: String,
            stateCode: String? = nil,
            address: ProjectAddress? = nil,
            gridID: GridCode.ID? = nil,
            consumption: Double? = nil,
            monthlyBill: Double? = nil,
            consumptionProfile: [Double]? = nil,
            consumptionProfileID: ConsumptionProfile.ID? = nil,
            exportLimit: Double? = nil,
            powerFactor: Double? = nil,
            pvModuleSetup: [PvModuleSetup]? = nil,
            pvLayout: PvLayout? = nil,
            oversizing: Double,
            systemType: SystemType,
            backup: Bool? = nil,
            batteries: [BatterySetup]? = nil,
            electricalDesign: ElectricalDesign? = nil,
            incentives: [Incentive.ID]? = nil,
            utilityImportRateID: UtilityRate.ID? = nil,
            utilityExportRateID: UtilityRate.ID? = nil,
            systemPrice: Double? = nil,
            pricePerWatt: Double? = nil,
            systemLifetime: SystemLifetime? = nil,
            shadingFactor: Double? = nil,
            useBatteryManagementAlgorithm: Bool? = nil
        ) {
            self.name = name
            self.externalID = externalID
            self.createdBy = createdBy
            self.longitude = longitude
            self.latitude = latitude
            self.countryCode = countryCode
            self.stateCode = stateCode
            self.address = address
            self.gridID = gridID
            self.consumption = consumption
            self.monthlyBill = monthlyBill
            self.consumptionProfile = consumptionProfile
            self.consumptionProfileID = consumptionProfileID
            self.exportLimit = exportLimit
            self.powerFactor = powerFactor
            self.pvModuleSetup = pvModuleSetup
            self.pvLayout = pvLayout
            self.oversizing = oversizing
            self.systemType = systemType
            self.backup = backup
            self.batteries = batteries
            self.electricalDesign = electricalDesign
            self.incentives = incentives
            self.utilityImportRateID = utilityImportRateID
            self.utilityExportRateID = utilityExportRateID
            self.systemPrice = systemPrice
            self.pricePerWatt = pricePerWatt
            self.systemLifetime = systemLifetime
            self.shadingFactor = shadingFactor
            self.useBatteryManagementAlgorithm = useBatteryManagementAlgorithm
        }
    }

    /// The input of ``ProjectService/update(_:with:)`` (`ProjectUpdateParams`).
    ///
    /// Only the values that are set are sent; `nil` leaves a value as it is.
    /// Setting ``pvModuleSetup``, ``pvLayout`` or ``electricalDesign``, or
    /// ``batteries`` with ``backup`` not `false`, regenerates the electrical
    /// design; then ``oversizing`` and ``systemType`` are required.
    public struct ProjectUpdate: Sendable, Hashable {
        /// The project name, at most 48 characters.
        public var name: String?
        /// A custom ID for the project, at most 128 characters. Use it with ``ReportsService/report(forExternalID:)``.
        public var externalID: String?
        /// The email of the user updating the site. `nil` uses the account administrator.
        public var createdBy: String?
        /// Longitude of the site, `-180` to `180`. Must match the current value if set.
        public var longitude: Double?
        /// Latitude of the site, `-90` to `90`. Must match the current value if set.
        public var latitude: Double?
        /// The country code of the site, e.g. `DE`. Must match the current value if set.
        public var countryCode: String?
        /// The state code of the site. Must match the current value if set.
        public var stateCode: String?
        /// The address of the project.
        public var address: ProjectAddress?
        /// The grid of the site, e.g. from ``EstimationService/gridCodes(country:)``.
        public var gridID: GridCode.ID?
        /// The annual consumption in kWh, at least `0`. Required with ``consumptionProfile``; interchangeable with ``monthlyBill``.
        public var consumption: Double?
        /// The average monthly electricity bill without SolarEdge, at least `0`. Interchangeable with ``consumption``.
        public var monthlyBill: Double?
        /// Hourly distribution of the consumption over a year: exactly 8760 values, none negative, summing up to 1. Give either this or ``consumptionProfileID``.
        public var consumptionProfile: [Double]?
        /// A predefined consumption profile, e.g. from ``EstimationService/consumptionProfiles(country:)``. Give either this or ``consumptionProfile``.
        public var consumptionProfileID: ConsumptionProfile.ID?
        /// Export limit in W, at least `0`.
        public var exportLimit: Double?
        /// Power factor, `0.8` to `1`. API default: `1`.
        public var powerFactor: Double?
        /// PV module groups for automatic layout generation. Setting it regenerates the electrical design, which needs ``oversizing`` and ``systemType``.
        public var pvModuleSetup: [PvModuleSetup]?
        /// A detailed PV layout (`pvLayoutConfig`). Setting it regenerates the electrical design, which needs ``oversizing`` and ``systemType``.
        public var pvLayout: PvLayout?
        /// The DC/AC oversizing ratio, `0` to `2`. Required when the electrical design is regenerated.
        public var oversizing: Double?
        /// The technology type of the system. Required when the electrical design is regenerated.
        public var systemType: SystemType?
        /// Whether backup information should be provided. API default: `true`.
        public var backup: Bool?
        /// The installed batteries. Setting it with ``backup`` not `false` regenerates the electrical design.
        public var batteries: [BatterySetup]?
        /// The inverter and optimizer models for the electrical design. Setting it regenerates the electrical design, which needs ``oversizing`` and ``systemType``.
        public var electricalDesign: ElectricalDesign?
        /// Incentives to apply, e.g. from ``EstimationService/incentives(country:state:)``. API default: none.
        public var incentives: [Incentive.ID]?
        /// The import rate.
        public var utilityImportRateID: UtilityRate.ID?
        /// The export rate.
        public var utilityExportRateID: UtilityRate.ID?
        /// Total system price in local currency.
        public var systemPrice: Double?
        /// Price per Wh in local currency (the spec's name says per watt).
        public var pricePerWatt: Double?
        /// Financial assumptions over the system's lifetime.
        public var systemLifetime: SystemLifetime?
        /// Shading factor, `0` to `1`.
        public var shadingFactor: Double?
        /// Whether to use the battery management algorithm (sent as `useBma`).
        /// API default: `false`.
        public var useBatteryManagementAlgorithm: Bool?

        public init(
            name: String? = nil,
            externalID: String? = nil,
            createdBy: String? = nil,
            longitude: Double? = nil,
            latitude: Double? = nil,
            countryCode: String? = nil,
            stateCode: String? = nil,
            address: ProjectAddress? = nil,
            gridID: GridCode.ID? = nil,
            consumption: Double? = nil,
            monthlyBill: Double? = nil,
            consumptionProfile: [Double]? = nil,
            consumptionProfileID: ConsumptionProfile.ID? = nil,
            exportLimit: Double? = nil,
            powerFactor: Double? = nil,
            pvModuleSetup: [PvModuleSetup]? = nil,
            pvLayout: PvLayout? = nil,
            oversizing: Double? = nil,
            systemType: SystemType? = nil,
            backup: Bool? = nil,
            batteries: [BatterySetup]? = nil,
            electricalDesign: ElectricalDesign? = nil,
            incentives: [Incentive.ID]? = nil,
            utilityImportRateID: UtilityRate.ID? = nil,
            utilityExportRateID: UtilityRate.ID? = nil,
            systemPrice: Double? = nil,
            pricePerWatt: Double? = nil,
            systemLifetime: SystemLifetime? = nil,
            shadingFactor: Double? = nil,
            useBatteryManagementAlgorithm: Bool? = nil
        ) {
            self.name = name
            self.externalID = externalID
            self.createdBy = createdBy
            self.longitude = longitude
            self.latitude = latitude
            self.countryCode = countryCode
            self.stateCode = stateCode
            self.address = address
            self.gridID = gridID
            self.consumption = consumption
            self.monthlyBill = monthlyBill
            self.consumptionProfile = consumptionProfile
            self.consumptionProfileID = consumptionProfileID
            self.exportLimit = exportLimit
            self.powerFactor = powerFactor
            self.pvModuleSetup = pvModuleSetup
            self.pvLayout = pvLayout
            self.oversizing = oversizing
            self.systemType = systemType
            self.backup = backup
            self.batteries = batteries
            self.electricalDesign = electricalDesign
            self.incentives = incentives
            self.utilityImportRateID = utilityImportRateID
            self.utilityExportRateID = utilityExportRateID
            self.systemPrice = systemPrice
            self.pricePerWatt = pricePerWatt
            self.systemLifetime = systemLifetime
            self.shadingFactor = shadingFactor
            self.useBatteryManagementAlgorithm = useBatteryManagementAlgorithm
        }
    }
}

extension Designer.ProjectParameters {
    /// The same values as an update, which has the same fields with all
    /// of them optional. Used to share the validation and the request body.
    var asUpdate: Designer.ProjectUpdate {
        Designer.ProjectUpdate(
            name: name,
            externalID: externalID,
            createdBy: createdBy,
            longitude: longitude,
            latitude: latitude,
            countryCode: countryCode,
            stateCode: stateCode,
            address: address,
            gridID: gridID,
            consumption: consumption,
            monthlyBill: monthlyBill,
            consumptionProfile: consumptionProfile,
            consumptionProfileID: consumptionProfileID,
            exportLimit: exportLimit,
            powerFactor: powerFactor,
            pvModuleSetup: pvModuleSetup,
            pvLayout: pvLayout,
            oversizing: oversizing,
            systemType: systemType,
            backup: backup,
            batteries: batteries,
            electricalDesign: electricalDesign,
            incentives: incentives,
            utilityImportRateID: utilityImportRateID,
            utilityExportRateID: utilityExportRateID,
            systemPrice: systemPrice,
            pricePerWatt: pricePerWatt,
            systemLifetime: systemLifetime,
            shadingFactor: shadingFactor,
            useBatteryManagementAlgorithm: useBatteryManagementAlgorithm
        )
    }

    /// Checks the ranges and counts the spec gives.
    func validate() throws {
        try validateRequired(name, name: "name")
        try validateRequired(countryCode, name: "countryCode")
        try asUpdate.validate()
    }
}

extension Designer.ProjectUpdate {
    /// Whether these values make the API regenerate the electrical design.
    var regeneratesElectricalDesign: Bool {
        pvModuleSetup != nil || pvLayout != nil || electricalDesign != nil || (batteries != nil && backup != false)
    }

    /// Checks the ranges and counts the spec gives.
    func validate() throws {
        if let name { try validateRequired(name, name: "name") }
        try checkLength(name, max: 48, "name")
        try checkLength(externalID, max: 128, "externalId")
        try checkRange(longitude, -180...180, "longitude")
        try checkRange(latitude, -90...90, "latitude")
        if let gridID { try validateRequired(gridID.rawValue, name: "gridId") }
        try checkRange(consumption, 0..., "consumption")
        try checkRange(monthlyBill, 0..., "monthlyBill")
        try validateConsumptionProfile(consumptionProfile)
        try check(consumptionProfile == nil || consumption != nil, "'consumption' is required with a custom 'consumptionProfile'")
        try checkRange(exportLimit, 0..., "exportLimit")
        try checkRange(powerFactor, 0.8...1, "powerFactor")
        try pvModuleSetup?.forEach { try $0.validate() }
        try pvLayout?.validate()
        try checkRange(oversizing, 0...2, "oversizing")
        try batteries?.forEach { try $0.validate() }
        try systemLifetime?.validate()
        try checkRange(shadingFactor, 0...1, "shadingFactor")
        if regeneratesElectricalDesign {
            try check(oversizing != nil && systemType != nil,
                      "'oversizing' and 'systemType' are required when the electrical design is regenerated")
        }
    }
}
