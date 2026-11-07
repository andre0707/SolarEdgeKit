//
//  EstimationDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `Estimation`.
struct EstimationDTO: Codable {
    let installedSystem: InstalledSystemDTO
    let projectDesign: ProjectDesignDTO
    let simulationResults: SimulationResultsDTO
    let estimatedMonthlyEnergy: [EstimatedMonthlyEnergyItemDTO]
    let productionAndConsumption: ProductionConsumptionDataDTO
    let productionConsumptionDetails: ProductionConsumptionDetailsDTO
    let storageEnergyBreakdownDetails: StorageEnergyBreakdownDetailsDTO
    let detailedFinancialAnalysis: FinancialAnalysisDTO
    let annualSavings: [AnnualSavingsDTO]
    let storageReportData: StorageReportDataDTO
    let billOfMaterials: BillOfMaterialsEstimationDTO
}

/// The `200` of `GET /report/sites/{siteId}`: `oneOf` `Estimation` or
/// `AutoDesignEstimationResponse`. A body with `siteStillInDesignMessage`
/// is the latter.
enum SiteEstimationDTO: Decodable {
    case estimation(EstimationDTO)
    case stillInDesign(String)

    private enum CodingKeys: String, CodingKey {
        case siteStillInDesignMessage
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let message = try container.decodeIfPresent(String.self, forKey: .siteStillInDesignMessage) {
            self = .stillInDesign(message)
        } else {
            self = .estimation(try EstimationDTO(from: decoder))
        }
    }
}

/// `EstimatedMonthlyEnergy` (named apart from the report's
/// `EstimatedMonthlyEnergyDto`).
struct EstimatedMonthlyEnergyItemDTO: Codable {
    let month: String
    let solarProduction: Double
    let consumption: Double
    let selfConsumption: Double
}

/// `BillOfMaterials` (named apart from the report's `BillOfMaterialsDto`).
struct BillOfMaterialsEstimationDTO: Codable {
    let modules: [EstimationBomItemDTO]
    let inverters: [EstimationBomItemDTO]
    let optimizers: [EstimationBomItemDTO]
    let batteries: [EstimationBomItemDTO]
}

/// `InstalledSystem`.
struct InstalledSystemDTO: Codable {
    let installedPower: Double
    let maxAchievedDcPower: Double
    let actualAchievedOversizing: Double
    let maxActiveAcPower: Double
    let maxAchievedAcPower: Double
    let maxActiveApparentPower: Double
    let annualEnergy: Double
    let nonSeInverterAnnualEnergy: Double
    let maxReactivePower: Double
    let performanceRatio: Double
    let performanceIndex: Double
    let co2EmissionSaved: Double
    let equivalentTreesPlanted: Double
}

/// `ProjectDesign`.
struct ProjectDesignDTO: Codable {
    let pvModules: Int
    let inverters: Int
    let optimizers: Int
    let orientations: Int
    let batteries: Int
}

/// `SimulationResults`.
struct SimulationResultsDTO: Codable {
    let annualEnergyProduction: Double
    let annualEnergyProductionForNonSe: Double
    let co2EmissionSavedTonnes: Double
    let treesPlanted: Int
}

/// `ProductionConsumptionData`.
struct ProductionConsumptionDataDTO: Codable {
    let totalConsumption: Double
    let totalSelfConsumption: Double
    let batterySelfConsumption: Double
    let totalImport: Double
    let totalProduction: Double
    let totalExport: Double
}

/// `ProductionConsumptionDetails`.
struct ProductionConsumptionDetailsDTO: Codable {
    let consumptionFromGridWh: Double
    let consumptionFromGridPercent: Double
    let consumptionFromBatteriesWh: Double
    let consumptionFromBatteriesPercent: Double
    let consumptionFromSolarWh: Double
    let consumptionFromSolarPercent: Double
    let totalConsumption: Double
    let productionToGridWh: Double
    let productionToGridPercent: Double
    let productionToBatteriesWh: Double
    let productionToBatteriesPercent: Double
    let productionToHomeWh: Double
    let productionToHomePercent: Double
    let clippingLossWh: Double
    let clippingLossPercent: Double
    let totalProduction: Double
}

/// `StorageEnergyBreakdownDetails`.
struct StorageEnergyBreakdownDetailsDTO: Codable {
    let fromClippedEnergyWh: Double
    let fromClippedEnergyPercent: Double
    let fromGridWh: Double
    let fromGridPercent: Double
    let fromSolarWh: Double
    let fromSolarPercent: Double
    let totalFromAllSourcesWh: Double
    let toHomeWh: Double
    let toHomePercent: Double
    let toGridWh: Double
    let toGridPercent: Double
    let totalToAllDestinationsWh: Double
}

/// `YearlyCashFlow`.
struct YearlyCashFlowDTO: Codable {
    let year: Int
    let systemPrice: Double
    let returnFromIncentives: Double
    let netBillSavings: Double
    let annualCashFlow: Double
    let cumulativeCashFlow: Double
}

/// `AnnualSavings`.
struct AnnualSavingsDTO: Codable {
    let year: Int
    let currentMonthlyBill: [Double]
    let monthlyBillWithSolarEdge: [Double]
    let monthlyBillWithNonSolarEdge: [Double]
    let netMonthlyBillSavings: [Double]
    let netMonthlyBillSavingsWithoutBattery: [Double]
    let netMonthlyBillSavingsWithoutSmartBattery: [Double]
    let annualBill: Double
    let averageMonthlyBill: Double
    let annualBillWithSolarEdge: Double
    let annualBillWithNonSolarEdge: Double
    let averageMonthlyBillWithSolarEdge: Double
    let annualBillSavings: Double
    let averageMonthlyBillSavings: Double
    let annualBillSavingsWithoutBattery: Double
    let averageMonthlyBillSavingsWithoutBattery: Double
    let annualBillSavingsWithoutSmartBattery: Double
    let averageMonthlyBillSavingsWithoutSmartBattery: Double
}

/// `StorageReportData`.
struct StorageReportDataDTO: Codable {
    let selfConsumptionRatio: Double
    let selfConsumptionFromBatteriesRatio: Double
    let totalStorageCapacity: Double
    let totalBatteryPower: Double
    let backupTimeWithoutPV: Double
    let backupPercentage: Double
    let backupTimeWithPV: Double
}

/// `BomItem` (named apart from the report's `BomItemDto`).
struct EstimationBomItemDTO: Codable {
    let modelId: String
    let itemName: String
    let itemCount: Double
}

/// `FinancialAnalysis`.
struct FinancialAnalysisDTO: Codable {
    let systemPrice: Double
    let returnFromIncentives: Double
    let netPayments: Double
    let totalBillSaving: Double
    let totalBillSavingWithNonSe: Double
    let systemProfit: Double
    let internalReturnRate: Double
    let returnOfInvestment: Double
    let levelizedCostOfEnergy: Double
    let paybackPeriod: Double
    let basePrice: Double
    let electricityPriceEscalation: Double
    let yearlyCashFlowList: [YearlyCashFlowDTO]
}

extension EstimationDTO {
    var entity: Designer.Estimation {
        get throws {
            try Designer.Estimation(
                installedSystem: installedSystem.entity,
                projectDesign: projectDesign.entity,
                simulationResults: simulationResults.entity,
                estimatedMonthlyEnergy: estimatedMonthlyEnergy.map { try $0.entity },
                productionAndConsumption: productionAndConsumption.entity,
                productionConsumptionDetails: productionConsumptionDetails.entity,
                storageEnergyBreakdownDetails: storageEnergyBreakdownDetails.entity,
                detailedFinancialAnalysis: detailedFinancialAnalysis.entity,
                annualSavings: annualSavings.map(\.entity),
                storageReportData: storageReportData.entity,
                billOfMaterials: billOfMaterials.entity
            )
        }
    }
}

extension SiteEstimationDTO {
    var entity: Designer.SiteEstimation {
        get throws {
            switch self {
            case .estimation(let estimation): .ready(try estimation.entity)
            case .stillInDesign(let message): .stillInDesign(message: message)
            }
        }
    }
}

extension EstimatedMonthlyEnergyItemDTO {
    var entity: Designer.Estimation.MonthlyEnergy {
        get throws {
            guard let month = Designer.Estimation.Month(rawValue: month) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown value for field 'month'. Value: \(self.month)")
            }
            return Designer.Estimation.MonthlyEnergy(month: month, solarProduction: solarProduction, consumption: consumption, selfConsumption: selfConsumption)
        }
    }
}

extension BillOfMaterialsEstimationDTO {
    var entity: Designer.Estimation.BillOfMaterials {
        Designer.Estimation.BillOfMaterials(modules: modules.map(\.entity), inverters: inverters.map(\.entity),
                                            optimizers: optimizers.map(\.entity), batteries: batteries.map(\.entity))
    }
}

extension InstalledSystemDTO {
    var entity: Designer.Estimation.InstalledSystem {
        Designer.Estimation.InstalledSystem(installedPower: installedPower, maxAchievedDcPower: maxAchievedDcPower, actualAchievedOversizing: actualAchievedOversizing, maxActiveAcPower: maxActiveAcPower, maxAchievedAcPower: maxAchievedAcPower, maxActiveApparentPower: maxActiveApparentPower, annualEnergy: annualEnergy, nonSeInverterAnnualEnergy: nonSeInverterAnnualEnergy, maxReactivePower: maxReactivePower, performanceRatio: performanceRatio, performanceIndex: performanceIndex, co2EmissionSaved: co2EmissionSaved, equivalentTreesPlanted: equivalentTreesPlanted)
    }
}

extension ProjectDesignDTO {
    var entity: Designer.Estimation.ProjectDesign {
        Designer.Estimation.ProjectDesign(pvModules: pvModules, inverters: inverters, optimizers: optimizers, orientations: orientations, batteries: batteries)
    }
}

extension SimulationResultsDTO {
    var entity: Designer.Estimation.SimulationResults {
        Designer.Estimation.SimulationResults(annualEnergyProduction: annualEnergyProduction, annualEnergyProductionForNonSe: annualEnergyProductionForNonSe, co2EmissionSavedTonnes: co2EmissionSavedTonnes, treesPlanted: treesPlanted)
    }
}

extension ProductionConsumptionDataDTO {
    var entity: Designer.Estimation.ProductionAndConsumption {
        Designer.Estimation.ProductionAndConsumption(totalConsumption: totalConsumption, totalSelfConsumption: totalSelfConsumption, batterySelfConsumption: batterySelfConsumption, totalImport: totalImport, totalProduction: totalProduction, totalExport: totalExport)
    }
}

extension ProductionConsumptionDetailsDTO {
    var entity: Designer.Estimation.ProductionConsumptionDetails {
        Designer.Estimation.ProductionConsumptionDetails(consumptionFromGridWh: consumptionFromGridWh, consumptionFromGridPercent: consumptionFromGridPercent, consumptionFromBatteriesWh: consumptionFromBatteriesWh, consumptionFromBatteriesPercent: consumptionFromBatteriesPercent, consumptionFromSolarWh: consumptionFromSolarWh, consumptionFromSolarPercent: consumptionFromSolarPercent, totalConsumption: totalConsumption, productionToGridWh: productionToGridWh, productionToGridPercent: productionToGridPercent, productionToBatteriesWh: productionToBatteriesWh, productionToBatteriesPercent: productionToBatteriesPercent, productionToHomeWh: productionToHomeWh, productionToHomePercent: productionToHomePercent, clippingLossWh: clippingLossWh, clippingLossPercent: clippingLossPercent, totalProduction: totalProduction)
    }
}

extension StorageEnergyBreakdownDetailsDTO {
    var entity: Designer.Estimation.StorageEnergyBreakdown {
        Designer.Estimation.StorageEnergyBreakdown(fromClippedEnergyWh: fromClippedEnergyWh, fromClippedEnergyPercent: fromClippedEnergyPercent, fromGridWh: fromGridWh, fromGridPercent: fromGridPercent, fromSolarWh: fromSolarWh, fromSolarPercent: fromSolarPercent, totalFromAllSourcesWh: totalFromAllSourcesWh, toHomeWh: toHomeWh, toHomePercent: toHomePercent, toGridWh: toGridWh, toGridPercent: toGridPercent, totalToAllDestinationsWh: totalToAllDestinationsWh)
    }
}

extension YearlyCashFlowDTO {
    var entity: Designer.Estimation.YearlyCashFlow {
        Designer.Estimation.YearlyCashFlow(year: year, systemPrice: systemPrice, returnFromIncentives: returnFromIncentives, netBillSavings: netBillSavings, annualCashFlow: annualCashFlow, cumulativeCashFlow: cumulativeCashFlow)
    }
}

extension AnnualSavingsDTO {
    var entity: Designer.Estimation.AnnualSavings {
        Designer.Estimation.AnnualSavings(year: year, currentMonthlyBill: currentMonthlyBill, monthlyBillWithSolarEdge: monthlyBillWithSolarEdge, monthlyBillWithNonSolarEdge: monthlyBillWithNonSolarEdge, netMonthlyBillSavings: netMonthlyBillSavings, netMonthlyBillSavingsWithoutBattery: netMonthlyBillSavingsWithoutBattery, netMonthlyBillSavingsWithoutSmartBattery: netMonthlyBillSavingsWithoutSmartBattery, annualBill: annualBill, averageMonthlyBill: averageMonthlyBill, annualBillWithSolarEdge: annualBillWithSolarEdge, annualBillWithNonSolarEdge: annualBillWithNonSolarEdge, averageMonthlyBillWithSolarEdge: averageMonthlyBillWithSolarEdge, annualBillSavings: annualBillSavings, averageMonthlyBillSavings: averageMonthlyBillSavings, annualBillSavingsWithoutBattery: annualBillSavingsWithoutBattery, averageMonthlyBillSavingsWithoutBattery: averageMonthlyBillSavingsWithoutBattery, annualBillSavingsWithoutSmartBattery: annualBillSavingsWithoutSmartBattery, averageMonthlyBillSavingsWithoutSmartBattery: averageMonthlyBillSavingsWithoutSmartBattery)
    }
}

extension StorageReportDataDTO {
    var entity: Designer.Estimation.StorageReportData {
        Designer.Estimation.StorageReportData(selfConsumptionRatio: selfConsumptionRatio, selfConsumptionFromBatteriesRatio: selfConsumptionFromBatteriesRatio, totalStorageCapacity: totalStorageCapacity, totalBatteryPower: totalBatteryPower, backupTimeWithoutPV: backupTimeWithoutPV, backupPercentage: backupPercentage, backupTimeWithPV: backupTimeWithPV)
    }
}

extension EstimationBomItemDTO {
    var entity: Designer.Estimation.BillOfMaterialsItem {
        Designer.Estimation.BillOfMaterialsItem(modelId: modelId, itemName: itemName, itemCount: itemCount)
    }
}

extension FinancialAnalysisDTO {
    var entity: Designer.Estimation.FinancialAnalysis {
        Designer.Estimation.FinancialAnalysis(systemPrice: systemPrice, returnFromIncentives: returnFromIncentives, netPayments: netPayments, totalBillSaving: totalBillSaving, totalBillSavingWithNonSe: totalBillSavingWithNonSe, systemProfit: systemProfit, internalReturnRate: internalReturnRate, returnOfInvestment: returnOfInvestment, levelizedCostOfEnergy: levelizedCostOfEnergy, paybackPeriod: paybackPeriod, basePrice: basePrice, electricityPriceEscalation: electricityPriceEscalation, yearlyCashFlowList: yearlyCashFlowList.map(\.entity))
    }
}
