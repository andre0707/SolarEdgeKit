//
//  BatteryUpsellDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `BatteryDetails`.
struct BatteryDetailsDTO: Codable, Hashable {
    let model: String
    let quantity: Int
}

/// `BatteryUpsellRequest`. `nil` values are left out.
struct BatteryUpsellRequestDTO: Encodable, Hashable {
    let batteries: [BatteryDetailsDTO]
    let createdBy: String?
    let allowInverterChange: Bool?
}

/// `BatteryUpsellFinancialsRequest`. `nil` values are left out.
struct BatteryUpsellFinancialsRequestDTO: Encodable, Hashable {
    let batteries: [BatteryDetailsDTO]
    let createdBy: String?
    let allowInverterChange: Bool?
    let utilityImportRateId: Int?
    let utilityExportRateId: Int?
    let consumption: Double?
    let consumptionProfile: [Double]?
    let consumptionProfileId: String?
    let systemPrice: Double?
    let pricePerWatt: Double?
}

/// `BatteryUpsellResponse`.
struct BatteryUpsellResponseDTO: Codable {
    let batteryDistribution: BatteryDistributionDTO
}

/// `BatteryDistribution`. `distribution` has no schema in the spec; its
/// example maps inverter IDs to `BatteryDetails`.
struct BatteryDistributionDTO: Codable {
    let distribution: [String: BatteryDetailsDTO]
    let replacedInverters: [ReplacedInverterDTO]
    let inverterIds: [Int]
}

/// `ReplacedInverter`.
struct ReplacedInverterDTO: Codable {
    let inverterId: Int
    let oldInverterModel: String
    let newInverterModel: String
}

/// `BatteryUpsellFinancialsResponse`.
struct BatteryUpsellFinancialsResponseDTO: Codable {
    let totalBillSaving: BatteryUpsellFinancialDiffDTO
    let systemProfit: BatteryUpsellFinancialDiffDTO
    let internalReturnRate: BatteryUpsellFinancialDiffDTO
    let returnOfInvestment: BatteryUpsellFinancialDiffDTO
    let levelizedCostOfEnergy: BatteryUpsellFinancialDiffDTO
    let paybackPeriod: BatteryUpsellFinancialDiffDTO
    let batteryDistribution: BatteryDistributionDTO
}

/// `BatteryUpsellFinancialDiff`.
struct BatteryUpsellFinancialDiffDTO: Codable {
    let withoutBatteries: Double
    let withBatteries: Double
}


extension BatteryDetailsDTO {
    init(_ battery: Designer.BatterySetup) {
        self.init(model: battery.batteryID.rawValue, quantity: battery.batteryCount)
    }

    var entity: Designer.BatterySetup {
        Designer.BatterySetup(batteryID: .init(rawValue: model), batteryCount: quantity)
    }
}

extension BatteryUpsellRequestDTO {
    init(_ parameters: Designer.BatteryUpsellParameters) {
        self.init(batteries: parameters.batteries.map(BatteryDetailsDTO.init),
                  createdBy: parameters.createdBy, allowInverterChange: parameters.allowInverterChange)
    }
}

extension BatteryUpsellFinancialsRequestDTO {
    init(_ parameters: Designer.BatteryUpsellFinancialsParameters) {
        self.init(
            batteries: parameters.batteries.map(BatteryDetailsDTO.init),
            createdBy: parameters.createdBy,
            allowInverterChange: parameters.allowInverterChange,
            utilityImportRateId: parameters.utilityImportRateID?.rawValue,
            utilityExportRateId: parameters.utilityExportRateID?.rawValue,
            consumption: parameters.consumption,
            consumptionProfile: parameters.consumptionProfile,
            consumptionProfileId: parameters.consumptionProfileID?.rawValue,
            systemPrice: parameters.systemPrice,
            pricePerWatt: parameters.pricePerWatt
        )
    }
}

extension BatteryDistributionDTO {
    /// The API sends the inverter IDs of `distribution` as JSON object keys,
    /// i.e. as text; a key that is not a number throws.
    var entity: Designer.BatteryDistribution {
        get throws {
            var batteries: [Designer.InverterID: Designer.BatterySetup] = [:]
            for (key, value) in distribution {
                guard let id = Int(key) else {
                    throw SolarEdgeError.decodingWithMessage(message: "Inverter ID in field 'distribution' is not a number. Value: \(key)")
                }
                batteries[Designer.InverterID(rawValue: id)] = value.entity
            }

            return Designer.BatteryDistribution(
                distribution: batteries,
                replacedInverters: replacedInverters.map {
                    Designer.BatteryDistribution.ReplacedInverter(inverterID: .init(rawValue: $0.inverterId), oldInverterModel: $0.oldInverterModel,
                                                                  newInverterModel: $0.newInverterModel)
                },
                inverterIDs: inverterIds.map(Designer.InverterID.init(rawValue:))
            )
        }
    }
}

extension BatteryUpsellFinancialDiffDTO {
    var entity: Designer.BatteryUpsellFinancials.Comparison {
        Designer.BatteryUpsellFinancials.Comparison(withoutBatteries: withoutBatteries, withBatteries: withBatteries)
    }
}

extension BatteryUpsellFinancialsResponseDTO {
    var entity: Designer.BatteryUpsellFinancials {
        get throws {
            try Designer.BatteryUpsellFinancials(
                totalBillSaving: totalBillSaving.entity,
                systemProfit: systemProfit.entity,
                internalReturnRate: internalReturnRate.entity,
                returnOfInvestment: returnOfInvestment.entity,
                levelizedCostOfEnergy: levelizedCostOfEnergy.entity,
                paybackPeriod: paybackPeriod.entity,
                batteryDistribution: batteryDistribution.entity
            )
        }
    }
}
