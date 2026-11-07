//
//  DeviceModelsDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `DeviceModels`. The maps are keyed as the API sends them.
struct DeviceModelsDTO: Codable {
    let inverters: [String: InverterModelDTO]
    let optimizers: [String: OptimizerModelDTO]
    let batteries: [String: BatteryModelDTO]
}

/// `InverterModel`.
struct InverterModelDTO: Codable {
    let id: String
    let displayName: String
    let type: String
    let numberOfUnits: Int
    let oversizingLimit: Double
    let batteryOversizingLimit: Double
    let maxAcPower: Double
    let maxApparentPower: Double
    let maxBatteryBackupPower: Double
    let maxIoutPerPhase: Double
    let phase: Int
    let weightedEfficiency: Double
    let cost: Double
    let operatingDcVoltage: Double
    let minDcVoltage: Double
    let maxInputCurrent: Double
    let maxNumOfStrings: Int
    let minNumOfStrings: Int
    let maxModuleDiffPerStringPair: Int
    let technology: String
    let numOfDcInputs: Int
    let maxCableLength: Double
    let evCharging: Bool
    let discontinued: Bool
    let deleted: Bool
    let backupSupport: Bool
    let noBackupSupport: Bool
    let experimental: Bool
    let minCableGland: Double
    let maxCableGland: Double
    let minCrossSection: Double
    let maxCrossSection: Double
    let madeInCountry: String
    let detailedEfficiency: InverterEfficiencyDTO
    let batteryCompatibility: [InverterBatteryCompatibilityDTO]
    let optimizerStringConstraints: [InverterOptimizerStringConstraintDTO]
    let canChargeBatteryFromGrid: Bool
    let isStorageInverter: Bool
}

/// `InverterEfficiency`.
struct InverterEfficiencyDTO: Codable {
    let efficiency01: Double
    let efficiency02: Double
    let efficiency03: Double
    let efficiency04: Double
    let efficiency05: Double
    let efficiency08: Double
    let efficiency1: Double
    let efficiency2: Double
    let efficiency3: Double
    let efficiency4: Double
    let efficiency5: Double
    let efficiency8: Double
    let efficiency10: Double
    let efficiency15: Double
    let efficiency20: Double
    let efficiency25: Double
    let efficiency30: Double
    let efficiency40: Double
    let efficiency50: Double
    let efficiency75: Double
    let efficiency100: Double
    let efficiency110: Double
}

/// `InverterBatteryCompatibility`.
struct InverterBatteryCompatibilityDTO: Codable {
    let batteryModelId: String
    let maxBatteriesPerInverter: Int
}

/// `InverterOptimizerStringConstraint`.
struct InverterOptimizerStringConstraintDTO: Codable {
    let optimizerModelId: String
    let minLength: Int
    let maxLength: Int
    let maxPower: Int
    let numberOfOversizedStrings: Int
    let oversizedStringMaxPower: Int
    let allowedOversizedStringMaxPower: Int
    let oversizedStringMaxMismatch: Int
    let minInverterDcPower: Int
    let minModules: Int
    let maxNonFullOptimizers: Int
    let maxNumOfStrings: Int
    let maxOptimizersDiff: Int
}

/// `OptimizerModel`.
struct OptimizerModelDTO: Codable {
    let id: String
    let type: String
    let embedded: Bool
    let minPower: Double
    let maxPower: Double
    let maxInputCurrent: Double
    let maxOutputCurrent: Double
    let maxInputVoltage: Double
    let maxOutputVoltage: Double
    let cost: Double
    let maxParallelRatio: Int
    let maxSerialRatio: Int
    let maxRatio: Int
    let minRequestedRatio: Int
    let discontinued: Bool
    let deleted: Bool
    let numOfInputs: Int
    let numOfPrimaryInputs: Int
    let editable: Bool
    let onlyEquivalentModulesAllowed: Bool
    let minModuleCellCount: Int
    let mountLocation: String
    let mixingInInverterAllowed: Bool
    let cableLength: Double
    let buckOnly: Bool
    let experimental: Bool
    let madeInCountry: String
    let detailedEfficiency: OptimizerEfficiencyPropertiesDTO
    let name: String
    let dualOptimizer: Bool
    let quadOptimizer: Bool
    let efficiency: Double
    let singleInput: Bool
}

/// `OptimizerEfficiencyProperties`.
struct OptimizerEfficiencyPropertiesDTO: Codable {
    let efficiency5: Double
    let efficiency10: Double
    let efficiency20: Double
    let efficiency30: Double
    let efficiency50: Double
    let efficiency100: Double
    let boost5: Double
    let boost10: Double
    let boost20: Double
    let boost30: Double
    let boost50: Double
    let boost100: Double
    let boostRatio: Double
    let buck5: Double
    let buck10: Double
    let buck20: Double
    let buck30: Double
    let buck50: Double
    let buck100: Double
    let buckRatio: Double
    let lowPower0: Double
    let lowPower3: Double
    let lowPower4: Double
    let lowPower6: Double
    let lowPower8: Double
    let lowPower10: Double
    let lowPower15: Double
    let lowPower20: Double
    let lowPower25: Double
    let lowPower30: Double
    let lowPower35: Double
    let lowPower40: Double
}

/// `BatteryModel`.
struct BatteryModelDTO: Codable {
    let id: String
    let displayName: String
    let usableCapacityWh: Int
    let minStateEnergy: Double
    let nameplateCapacityWh: Int
    let maxInputPowerW: Int
    let maxOutputPowerW: Int
    let chargeEfficiency: Double
    let dischargeEfficiency: Double
    let discontinued: Bool
    let deleted: Bool
    let maxInvertersWithBatteriesPerSite: Int
    let phase: Int
    let manufacturerId: String
    let connectionType: String
    let experimental: Bool
    let madeInCountry: String
}


extension DeviceModelsDTO {
    var entity: Designer.DeviceModels {
        get throws {
            try Designer.DeviceModels(
                inverters: inverters.mapValues { try $0.entity },
                optimizers: optimizers.mapValues { try $0.entity },
                batteries: batteries.mapValues { try $0.entity }
            )
        }
    }
}

extension InverterEfficiencyDTO {
    var entity: Designer.InverterModel.Efficiency {
        Designer.InverterModel.Efficiency(efficiency01: efficiency01, efficiency02: efficiency02, efficiency03: efficiency03, efficiency04: efficiency04, efficiency05: efficiency05, efficiency08: efficiency08, efficiency1: efficiency1, efficiency2: efficiency2, efficiency3: efficiency3, efficiency4: efficiency4, efficiency5: efficiency5, efficiency8: efficiency8, efficiency10: efficiency10, efficiency15: efficiency15, efficiency20: efficiency20, efficiency25: efficiency25, efficiency30: efficiency30, efficiency40: efficiency40, efficiency50: efficiency50, efficiency75: efficiency75, efficiency100: efficiency100, efficiency110: efficiency110)
    }
}

extension InverterBatteryCompatibilityDTO {
    var entity: Designer.InverterModel.BatteryCompatibility {
        Designer.InverterModel.BatteryCompatibility(batteryModelId: batteryModelId, maxBatteriesPerInverter: maxBatteriesPerInverter)
    }
}

extension InverterOptimizerStringConstraintDTO {
    var entity: Designer.InverterModel.OptimizerStringConstraint {
        Designer.InverterModel.OptimizerStringConstraint(optimizerModelId: optimizerModelId, minLength: minLength, maxLength: maxLength, maxPower: maxPower, numberOfOversizedStrings: numberOfOversizedStrings, oversizedStringMaxPower: oversizedStringMaxPower, allowedOversizedStringMaxPower: allowedOversizedStringMaxPower, oversizedStringMaxMismatch: oversizedStringMaxMismatch, minInverterDcPower: minInverterDcPower, minModules: minModules, maxNonFullOptimizers: maxNonFullOptimizers, maxNumOfStrings: maxNumOfStrings, maxOptimizersDiff: maxOptimizersDiff)
    }
}

extension InverterModelDTO {
    var entity: Designer.InverterModel {
        get throws {
            let typeValue = Designer.InverterModel.InverterType(rawValue: type)
            return Designer.InverterModel(
                id: id,
                displayName: displayName,
                type: typeValue,
                numberOfUnits: numberOfUnits,
                oversizingLimit: oversizingLimit,
                batteryOversizingLimit: batteryOversizingLimit,
                maxAcPower: maxAcPower,
                maxApparentPower: maxApparentPower,
                maxBatteryBackupPower: maxBatteryBackupPower,
                maxIoutPerPhase: maxIoutPerPhase,
                phase: phase,
                weightedEfficiency: weightedEfficiency,
                cost: cost,
                operatingDcVoltage: operatingDcVoltage,
                minDcVoltage: minDcVoltage,
                maxInputCurrent: maxInputCurrent,
                maxNumOfStrings: maxNumOfStrings,
                minNumOfStrings: minNumOfStrings,
                maxModuleDiffPerStringPair: maxModuleDiffPerStringPair,
                technology: technology,
                numOfDcInputs: numOfDcInputs,
                maxCableLength: maxCableLength,
                evCharging: evCharging,
                discontinued: discontinued,
                deleted: deleted,
                backupSupport: backupSupport,
                noBackupSupport: noBackupSupport,
                experimental: experimental,
                minCableGland: minCableGland,
                maxCableGland: maxCableGland,
                minCrossSection: minCrossSection,
                maxCrossSection: maxCrossSection,
                madeInCountry: madeInCountry,
                detailedEfficiency: detailedEfficiency.entity,
                batteryCompatibility: batteryCompatibility.map(\.entity),
                optimizerStringConstraints: optimizerStringConstraints.map(\.entity),
                canChargeBatteryFromGrid: canChargeBatteryFromGrid,
                isStorageInverter: isStorageInverter
            )
        }
    }
}

extension OptimizerEfficiencyPropertiesDTO {
    var entity: Designer.OptimizerModel.Efficiency {
        Designer.OptimizerModel.Efficiency(efficiency5: efficiency5, efficiency10: efficiency10, efficiency20: efficiency20, efficiency30: efficiency30, efficiency50: efficiency50, efficiency100: efficiency100, boost5: boost5, boost10: boost10, boost20: boost20, boost30: boost30, boost50: boost50, boost100: boost100, boostRatio: boostRatio, buck5: buck5, buck10: buck10, buck20: buck20, buck30: buck30, buck50: buck50, buck100: buck100, buckRatio: buckRatio, lowPower0: lowPower0, lowPower3: lowPower3, lowPower4: lowPower4, lowPower6: lowPower6, lowPower8: lowPower8, lowPower10: lowPower10, lowPower15: lowPower15, lowPower20: lowPower20, lowPower25: lowPower25, lowPower30: lowPower30, lowPower35: lowPower35, lowPower40: lowPower40)
    }
}

extension OptimizerModelDTO {
    var entity: Designer.OptimizerModel {
        get throws {
            let typeValue = Designer.OptimizerModel.OptimizerType(rawValue: type)
            let mountLocationValue = Designer.OptimizerModel.MountLocation(rawValue: mountLocation)
            return Designer.OptimizerModel(
                id: id,
                type: typeValue,
                embedded: embedded,
                minPower: minPower,
                maxPower: maxPower,
                maxInputCurrent: maxInputCurrent,
                maxOutputCurrent: maxOutputCurrent,
                maxInputVoltage: maxInputVoltage,
                maxOutputVoltage: maxOutputVoltage,
                cost: cost,
                maxParallelRatio: maxParallelRatio,
                maxSerialRatio: maxSerialRatio,
                maxRatio: maxRatio,
                minRequestedRatio: minRequestedRatio,
                discontinued: discontinued,
                deleted: deleted,
                numOfInputs: numOfInputs,
                numOfPrimaryInputs: numOfPrimaryInputs,
                editable: editable,
                onlyEquivalentModulesAllowed: onlyEquivalentModulesAllowed,
                minModuleCellCount: minModuleCellCount,
                mountLocation: mountLocationValue,
                mixingInInverterAllowed: mixingInInverterAllowed,
                cableLength: cableLength,
                buckOnly: buckOnly,
                experimental: experimental,
                madeInCountry: madeInCountry,
                detailedEfficiency: detailedEfficiency.entity,
                name: name,
                dualOptimizer: dualOptimizer,
                quadOptimizer: quadOptimizer,
                efficiency: efficiency,
                singleInput: singleInput
            )
        }
    }
}

extension BatteryModelDTO {
    var entity: Designer.BatteryModel {
        get throws {
            let connectionTypeValue = Designer.BatteryModel.ConnectionType(rawValue: connectionType)
            return Designer.BatteryModel(
                id: id,
                displayName: displayName,
                usableCapacityWh: usableCapacityWh,
                minStateEnergy: minStateEnergy,
                nameplateCapacityWh: nameplateCapacityWh,
                maxInputPowerW: maxInputPowerW,
                maxOutputPowerW: maxOutputPowerW,
                chargeEfficiency: chargeEfficiency,
                dischargeEfficiency: dischargeEfficiency,
                discontinued: discontinued,
                deleted: deleted,
                maxInvertersWithBatteriesPerSite: maxInvertersWithBatteriesPerSite,
                phase: phase,
                manufacturerId: manufacturerId,
                connectionType: connectionTypeValue,
                experimental: experimental,
                madeInCountry: madeInCountry
            )
        }
    }
}
