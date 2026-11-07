//
//  InverterModel.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// An inverter model, as returned by
    /// ``DeviceModelsService/models(for:countryCode:stateCode:sector:)``.
    ///
    /// Its constraints are the design rules for the optimizers and
    /// batteries connected to it. The spec documents neither meaning nor
    /// units of these values; names and types mirror it.
    public struct InverterModel: Sendable, Hashable {
        /// The values of `type`.
        public enum InverterType: Sendable, Hashable, CaseIterable, RawRepresentable {
            /// `SYNERGY`.
            case synergy
            /// `SYNERGY_4BOX`.
            case synergy4box
            /// A value this version of the package does not know yet, as the
            /// API sent it. New values are added on the server over time.
            case unknown(String)

            /// The known values, without ``unknown(_:)``.
            public static let allCases: [InverterType] = [.synergy, .synergy4box]

            /// The case for an API value, or ``unknown(_:)``. Never `nil`.
            public init(rawValue: String) {
                self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
            }

            /// The value as the API sends it.
            public var rawValue: String {
                switch self {
                case .synergy: "SYNERGY"
                case .synergy4box: "SYNERGY_4BOX"
                case .unknown(let rawValue): rawValue
                }
            }
        }

        /// `InverterEfficiency`. The spec documents neither meaning nor units of
        /// these values.
        public struct Efficiency: Sendable, Hashable {
            /// Efficiency 01.
            public let efficiency01: Double
            /// Efficiency 02.
            public let efficiency02: Double
            /// Efficiency 03.
            public let efficiency03: Double
            /// Efficiency 04.
            public let efficiency04: Double
            /// Efficiency 05.
            public let efficiency05: Double
            /// Efficiency 08.
            public let efficiency08: Double
            /// Efficiency 1.
            public let efficiency1: Double
            /// Efficiency 2.
            public let efficiency2: Double
            /// Efficiency 3.
            public let efficiency3: Double
            /// Efficiency 4.
            public let efficiency4: Double
            /// Efficiency 5.
            public let efficiency5: Double
            /// Efficiency 8.
            public let efficiency8: Double
            /// Efficiency 10.
            public let efficiency10: Double
            /// Efficiency 15.
            public let efficiency15: Double
            /// Efficiency 20.
            public let efficiency20: Double
            /// Efficiency 25.
            public let efficiency25: Double
            /// Efficiency 30.
            public let efficiency30: Double
            /// Efficiency 40.
            public let efficiency40: Double
            /// Efficiency 50.
            public let efficiency50: Double
            /// Efficiency 75.
            public let efficiency75: Double
            /// Efficiency 100.
            public let efficiency100: Double
            /// Efficiency 110.
            public let efficiency110: Double

            public init(efficiency01: Double, efficiency02: Double, efficiency03: Double, efficiency04: Double, efficiency05: Double, efficiency08: Double, efficiency1: Double, efficiency2: Double, efficiency3: Double, efficiency4: Double, efficiency5: Double, efficiency8: Double, efficiency10: Double, efficiency15: Double, efficiency20: Double, efficiency25: Double, efficiency30: Double, efficiency40: Double, efficiency50: Double, efficiency75: Double, efficiency100: Double, efficiency110: Double) {
                self.efficiency01 = efficiency01
                self.efficiency02 = efficiency02
                self.efficiency03 = efficiency03
                self.efficiency04 = efficiency04
                self.efficiency05 = efficiency05
                self.efficiency08 = efficiency08
                self.efficiency1 = efficiency1
                self.efficiency2 = efficiency2
                self.efficiency3 = efficiency3
                self.efficiency4 = efficiency4
                self.efficiency5 = efficiency5
                self.efficiency8 = efficiency8
                self.efficiency10 = efficiency10
                self.efficiency15 = efficiency15
                self.efficiency20 = efficiency20
                self.efficiency25 = efficiency25
                self.efficiency30 = efficiency30
                self.efficiency40 = efficiency40
                self.efficiency50 = efficiency50
                self.efficiency75 = efficiency75
                self.efficiency100 = efficiency100
                self.efficiency110 = efficiency110
            }
        }

        /// `InverterBatteryCompatibility`. The spec documents neither meaning nor units of
        /// these values.
        public struct BatteryCompatibility: Sendable, Hashable {
            /// Battery model ID.
            public let batteryModelId: String
            /// Maximum batteries per inverter.
            public let maxBatteriesPerInverter: Int

            public init(batteryModelId: String, maxBatteriesPerInverter: Int) {
                self.batteryModelId = batteryModelId
                self.maxBatteriesPerInverter = maxBatteriesPerInverter
            }
        }

        /// `InverterOptimizerStringConstraint`. The spec documents neither meaning nor units of
        /// these values.
        public struct OptimizerStringConstraint: Sendable, Hashable {
            /// Optimizer model ID.
            public let optimizerModelId: String
            /// Minimum length.
            public let minLength: Int
            /// Maximum length.
            public let maxLength: Int
            /// Maximum power.
            public let maxPower: Int
            /// Number of oversized strings.
            public let numberOfOversizedStrings: Int
            /// Oversized string maximum power.
            public let oversizedStringMaxPower: Int
            /// Allowed oversized string maximum power.
            public let allowedOversizedStringMaxPower: Int
            /// Oversized string maximum mismatch.
            public let oversizedStringMaxMismatch: Int
            /// Minimum inverter DC power.
            public let minInverterDcPower: Int
            /// Minimum modules.
            public let minModules: Int
            /// Maximum non full optimizers.
            public let maxNonFullOptimizers: Int
            /// Maximum number of strings.
            public let maxNumOfStrings: Int
            /// Maximum optimizers diff.
            public let maxOptimizersDiff: Int

            public init(optimizerModelId: String, minLength: Int, maxLength: Int, maxPower: Int, numberOfOversizedStrings: Int, oversizedStringMaxPower: Int, allowedOversizedStringMaxPower: Int, oversizedStringMaxMismatch: Int, minInverterDcPower: Int, minModules: Int, maxNonFullOptimizers: Int, maxNumOfStrings: Int, maxOptimizersDiff: Int) {
                self.optimizerModelId = optimizerModelId
                self.minLength = minLength
                self.maxLength = maxLength
                self.maxPower = maxPower
                self.numberOfOversizedStrings = numberOfOversizedStrings
                self.oversizedStringMaxPower = oversizedStringMaxPower
                self.allowedOversizedStringMaxPower = allowedOversizedStringMaxPower
                self.oversizedStringMaxMismatch = oversizedStringMaxMismatch
                self.minInverterDcPower = minInverterDcPower
                self.minModules = minModules
                self.maxNonFullOptimizers = maxNonFullOptimizers
                self.maxNumOfStrings = maxNumOfStrings
                self.maxOptimizersDiff = maxOptimizersDiff
            }
        }

        /// ID.
        public let id: String
        /// Display name.
        public let displayName: String
        /// Type.
        public let type: InverterType
        /// Number of units.
        public let numberOfUnits: Int
        /// Oversizing limit.
        public let oversizingLimit: Double
        /// Battery oversizing limit.
        public let batteryOversizingLimit: Double
        /// Maximum AC power.
        public let maxAcPower: Double
        /// Maximum apparent power.
        public let maxApparentPower: Double
        /// Maximum battery backup power.
        public let maxBatteryBackupPower: Double
        /// Maximum output current per phase.
        public let maxIoutPerPhase: Double
        /// Phase.
        public let phase: Int
        /// Weighted efficiency.
        public let weightedEfficiency: Double
        /// Cost.
        public let cost: Double
        /// Operating DC voltage.
        public let operatingDcVoltage: Double
        /// Minimum DC voltage.
        public let minDcVoltage: Double
        /// Maximum input current.
        public let maxInputCurrent: Double
        /// Maximum number of strings.
        public let maxNumOfStrings: Int
        /// Minimum number of strings.
        public let minNumOfStrings: Int
        /// Maximum module diff per string pair.
        public let maxModuleDiffPerStringPair: Int
        /// Technology.
        public let technology: String
        /// Number of DC inputs.
        public let numOfDcInputs: Int
        /// Maximum cable length.
        public let maxCableLength: Double
        /// EV charging.
        public let evCharging: Bool
        /// Discontinued.
        public let discontinued: Bool
        /// Deleted.
        public let deleted: Bool
        /// Backup support.
        public let backupSupport: Bool
        /// No backup support.
        public let noBackupSupport: Bool
        /// Experimental.
        public let experimental: Bool
        /// Minimum cable gland.
        public let minCableGland: Double
        /// Maximum cable gland.
        public let maxCableGland: Double
        /// Minimum cross section.
        public let minCrossSection: Double
        /// Maximum cross section.
        public let maxCrossSection: Double
        /// Made in country.
        public let madeInCountry: String
        /// Detailed efficiency.
        public let detailedEfficiency: Efficiency
        /// Battery compatibility.
        public let batteryCompatibility: [BatteryCompatibility]
        /// Optimizer string constraints.
        public let optimizerStringConstraints: [OptimizerStringConstraint]
        /// Can charge battery from grid.
        public let canChargeBatteryFromGrid: Bool
        /// Is storage inverter.
        public let isStorageInverter: Bool

        public init(id: String, displayName: String, type: InverterType, numberOfUnits: Int, oversizingLimit: Double, batteryOversizingLimit: Double, maxAcPower: Double, maxApparentPower: Double, maxBatteryBackupPower: Double, maxIoutPerPhase: Double, phase: Int, weightedEfficiency: Double, cost: Double, operatingDcVoltage: Double, minDcVoltage: Double, maxInputCurrent: Double, maxNumOfStrings: Int, minNumOfStrings: Int, maxModuleDiffPerStringPair: Int, technology: String, numOfDcInputs: Int, maxCableLength: Double, evCharging: Bool, discontinued: Bool, deleted: Bool, backupSupport: Bool, noBackupSupport: Bool, experimental: Bool, minCableGland: Double, maxCableGland: Double, minCrossSection: Double, maxCrossSection: Double, madeInCountry: String, detailedEfficiency: Efficiency, batteryCompatibility: [BatteryCompatibility], optimizerStringConstraints: [OptimizerStringConstraint], canChargeBatteryFromGrid: Bool, isStorageInverter: Bool) {
            self.id = id
            self.displayName = displayName
            self.type = type
            self.numberOfUnits = numberOfUnits
            self.oversizingLimit = oversizingLimit
            self.batteryOversizingLimit = batteryOversizingLimit
            self.maxAcPower = maxAcPower
            self.maxApparentPower = maxApparentPower
            self.maxBatteryBackupPower = maxBatteryBackupPower
            self.maxIoutPerPhase = maxIoutPerPhase
            self.phase = phase
            self.weightedEfficiency = weightedEfficiency
            self.cost = cost
            self.operatingDcVoltage = operatingDcVoltage
            self.minDcVoltage = minDcVoltage
            self.maxInputCurrent = maxInputCurrent
            self.maxNumOfStrings = maxNumOfStrings
            self.minNumOfStrings = minNumOfStrings
            self.maxModuleDiffPerStringPair = maxModuleDiffPerStringPair
            self.technology = technology
            self.numOfDcInputs = numOfDcInputs
            self.maxCableLength = maxCableLength
            self.evCharging = evCharging
            self.discontinued = discontinued
            self.deleted = deleted
            self.backupSupport = backupSupport
            self.noBackupSupport = noBackupSupport
            self.experimental = experimental
            self.minCableGland = minCableGland
            self.maxCableGland = maxCableGland
            self.minCrossSection = minCrossSection
            self.maxCrossSection = maxCrossSection
            self.madeInCountry = madeInCountry
            self.detailedEfficiency = detailedEfficiency
            self.batteryCompatibility = batteryCompatibility
            self.optimizerStringConstraints = optimizerStringConstraints
            self.canChargeBatteryFromGrid = canChargeBatteryFromGrid
            self.isStorageInverter = isStorageInverter
        }
    }
}
