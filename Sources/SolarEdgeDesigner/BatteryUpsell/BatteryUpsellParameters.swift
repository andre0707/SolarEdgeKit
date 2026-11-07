//
//  BatteryUpsellParameters.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Designer {
    /// Where batteries are applied by ``BatteryUpsellService``.
    public enum BatteryUpsellTarget: Sendable, Hashable {
        /// A design of an existing Designer site.
        case designerSite(SiteID, design: DesignID)
        /// A layout imported from Monitoring into Designer, and a design.
        /// The financials then need more values; see
        /// ``BatteryUpsellFinancialsParameters``.
        case monitoringLayout(MonitoringLayoutID, design: DesignID)
    }

    /// The input of ``BatteryUpsellService/apply(_:to:)``
    /// (`BatteryUpsellRequest`).
    public struct BatteryUpsellParameters: Sendable, Hashable {
        /// The batteries to apply. Must not be empty. Sent as `model` and
        /// `quantity` (`BatteryDetails`).
        public var batteries: [BatterySetup]
        /// The email of the owner of a site imported from Monitoring. `nil`
        /// makes the account administrator the owner.
        public var createdBy: String?
        /// Whether inverters may be replaced to apply the batteries. API
        /// default: `true`.
        public var allowInverterChange: Bool?

        public init(batteries: [BatterySetup], createdBy: String? = nil, allowInverterChange: Bool? = nil) {
            self.batteries = batteries
            self.createdBy = createdBy
            self.allowInverterChange = allowInverterChange
        }
    }

    /// The input of ``BatteryUpsellService/applyWithFinancials(_:to:)``
    /// (`BatteryUpsellFinancialsRequest`).
    ///
    /// For a Designer site, the optional values override the site's own.
    /// For a Monitoring layout, the import and export rates, ``consumption``,
    /// a consumption profile (``consumptionProfile`` or
    /// ``consumptionProfileID``), and a price (``systemPrice`` or
    /// ``pricePerWatt``) are required; this is checked before sending.
    public struct BatteryUpsellFinancialsParameters: Sendable, Hashable {
        /// The batteries to apply. Must not be empty.
        public var batteries: [BatterySetup]
        /// The email of the owner of a site imported from Monitoring. `nil`
        /// makes the account administrator the owner.
        public var createdBy: String?
        /// Whether inverters may be replaced to apply the batteries. API
        /// default: `true`.
        public var allowInverterChange: Bool?
        /// The import rate.
        public var utilityImportRateID: UtilityRate.ID?
        /// The export rate.
        public var utilityExportRateID: UtilityRate.ID?
        /// The annual consumption in kWh, at least `0`.
        public var consumption: Double?
        /// Hourly distribution of the consumption over a year: exactly 8760
        /// values, none negative, summing up to 1.
        public var consumptionProfile: [Double]?
        /// A predefined consumption profile.
        public var consumptionProfileID: ConsumptionProfile.ID?
        /// Total system price in local currency.
        public var systemPrice: Double?
        /// Price per Wh in local currency (the spec's name says per watt).
        public var pricePerWatt: Double?

        public init(batteries: [BatterySetup], createdBy: String? = nil, allowInverterChange: Bool? = nil,
                    utilityImportRateID: UtilityRate.ID? = nil, utilityExportRateID: UtilityRate.ID? = nil,
                    consumption: Double? = nil, consumptionProfile: [Double]? = nil,
                    consumptionProfileID: ConsumptionProfile.ID? = nil, systemPrice: Double? = nil, pricePerWatt: Double? = nil) {
            self.batteries = batteries
            self.createdBy = createdBy
            self.allowInverterChange = allowInverterChange
            self.utilityImportRateID = utilityImportRateID
            self.utilityExportRateID = utilityExportRateID
            self.consumption = consumption
            self.consumptionProfile = consumptionProfile
            self.consumptionProfileID = consumptionProfileID
            self.systemPrice = systemPrice
            self.pricePerWatt = pricePerWatt
        }
    }
}

/// The batteries list must not be empty, and each entry must be valid.
private func validateUpsellBatteries(_ batteries: [Designer.BatterySetup]) throws {
    try check(!batteries.isEmpty, "'batteries' must not be empty")
    try batteries.forEach { try $0.validate() }
}

extension Designer.BatteryUpsellParameters {
    func validate() throws {
        try validateUpsellBatteries(batteries)
    }
}

extension Designer.BatteryUpsellFinancialsParameters {
    /// Checks the ranges, and the values a Monitoring layout requires.
    func validate(for target: Designer.BatteryUpsellTarget) throws {
        try validateUpsellBatteries(batteries)
        try checkRange(consumption, 0..., "consumption")
        try validateConsumptionProfile(consumptionProfile)

        if case .monitoringLayout = target {
            try check(utilityImportRateID != nil, "'utilityImportRateId' is required for a Monitoring layout")
            try check(utilityExportRateID != nil, "'utilityExportRateId' is required for a Monitoring layout")
            try check(consumption != nil, "'consumption' is required for a Monitoring layout")
            try check(consumptionProfile != nil || consumptionProfileID != nil,
                      "'consumptionProfile' or 'consumptionProfileId' is required for a Monitoring layout")
            try check(systemPrice != nil || pricePerWatt != nil, "'systemPrice' or 'pricePerWatt' is required for a Monitoring layout")
        }
    }
}
