//
//  BatteryUpsellResults.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// How the applied batteries are distributed over the inverters
    /// (`BatteryDistribution`).
    public struct BatteryDistribution: Sendable, Hashable {
        /// An inverter replaced to apply the batteries (`ReplacedInverter`).
        public struct ReplacedInverter: Sendable, Hashable {
            /// The ID of the replaced inverter.
            public let inverterID: InverterID
            /// The current inverter model, e.g. `SE17k-RES`.
            public let oldInverterModel: String
            /// The model needed for the batteries, e.g. `SE10K-RWB48 Home Hub`.
            public let newInverterModel: String

            public init(inverterID: InverterID, oldInverterModel: String, newInverterModel: String) {
                self.inverterID = inverterID
                self.oldInverterModel = oldInverterModel
                self.newInverterModel = newInverterModel
            }
        }

        /// The batteries per inverter. The spec gives no schema here; this
        /// follows its example, which keys them by inverter ID.
        public let distribution: [InverterID: BatterySetup]
        /// The inverters replaced to apply the batteries.
        public let replacedInverters: [ReplacedInverter]
        /// The IDs of the affected inverters.
        public let inverterIDs: [InverterID]

        public init(distribution: [InverterID: BatterySetup], replacedInverters: [ReplacedInverter], inverterIDs: [InverterID]) {
            self.distribution = distribution
            self.replacedInverters = replacedInverters
            self.inverterIDs = inverterIDs
        }
    }

    /// The financial difference with and without the applied batteries
    /// (`BatteryUpsellFinancialsResponse`), as returned by
    /// ``BatteryUpsellService/applyWithFinancials(_:to:)``.
    ///
    /// The values have the meaning and units of the same fields in
    /// ``Estimation/FinancialAnalysis``.
    public struct BatteryUpsellFinancials: Sendable, Hashable {
        /// A value without and with the batteries (`BatteryUpsellFinancialDiff`).
        public struct Comparison: Sendable, Hashable {
            /// The value without the batteries.
            public let withoutBatteries: Double
            /// The value with the batteries.
            public let withBatteries: Double

            public init(withoutBatteries: Double, withBatteries: Double) {
                self.withoutBatteries = withoutBatteries
                self.withBatteries = withBatteries
            }
        }

        /// Total bill savings over the system's lifetime.
        public let totalBillSaving: Comparison
        /// Total profit over the system's lifetime.
        public let systemProfit: Comparison
        /// The internal rate of return, in percent.
        public let internalReturnRate: Comparison
        /// The return on investment.
        public let returnOfInvestment: Comparison
        /// The levelized cost of energy.
        public let levelizedCostOfEnergy: Comparison
        /// The payback period in years.
        public let paybackPeriod: Comparison
        /// How the batteries are distributed over the inverters.
        public let batteryDistribution: BatteryDistribution

        public init(totalBillSaving: Comparison, systemProfit: Comparison, internalReturnRate: Comparison,
                    returnOfInvestment: Comparison, levelizedCostOfEnergy: Comparison, paybackPeriod: Comparison,
                    batteryDistribution: BatteryDistribution) {
            self.totalBillSaving = totalBillSaving
            self.systemProfit = systemProfit
            self.internalReturnRate = internalReturnRate
            self.returnOfInvestment = returnOfInvestment
            self.levelizedCostOfEnergy = levelizedCostOfEnergy
            self.paybackPeriod = paybackPeriod
            self.batteryDistribution = batteryDistribution
        }
    }
}
