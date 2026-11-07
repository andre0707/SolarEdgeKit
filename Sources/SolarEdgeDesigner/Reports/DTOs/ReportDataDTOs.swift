//
//  ReportDataDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `ReportDataDto`.
struct ReportDataDTO: Codable {
    let siteReport: SiteReportDTO
    let siteDetails: DesignerSiteDetailsDTO
}

/// `SiteReport`.
struct SiteReportDTO: Codable {
    let overview: SystemOverviewDTO
    let simulationResults: SystemDataDTO
    let estimatedMonthlyEnergy: [EstimatedMonthlyEnergyDTO]
    let pvModules: [PvModulesDTO]
    let billOfMaterials: BillOfMaterialsDTO
    let numOfImages: Int
}

/// `SystemOverview`.
struct SystemOverviewDTO: Codable {
    let pvModules: Int
    let inverters: Int
    let optimizers: Int
    let orientations: Int
    let batteries: Int
    let optimizerGeneralType: String
}

/// `SystemDataDto`.
struct SystemDataDTO: Codable {
    let installedPower: Double
    let maxAchievedDcPower: Double
    let actualAchievedOversizing: Double
    let maxActiveAcPower: Int
    let maxAchievedAcPower: Int
    let maxActiveApparentPower: Int
    let annualEnergy: Double
    let nonSeInverterAnnualEnergy: Double
    let annualApparentEnergy: Double
    let annualReactiveEnergy: Double
    let maxReactivePower: Int
    let performanceRatio: Double
    let performanceIndex: Double
    let co2EmissionSaved: Double
    let equivalentTreesPlanted: Double
}

/// `EstimatedMonthlyEnergyDto`.
struct EstimatedMonthlyEnergyDTO: Codable {
    let produced: Double
    let clipped: Double
    let selfConsumed: Double
    let consumed: Double
    let monthInEnglish: String
}

/// `PvModulesDto`.
struct PvModulesDTO: Codable {
    let modulesCount: Int
    let moduleName: String
    let power: Double
    let mountingType: String
    let moduleOrientation: String
    let absoluteAzimuth: Double
    let absoluteTilt: Double
    let userDefined: Bool
}

/// `BillOfMaterialsDto`.
struct BillOfMaterialsDTO: Codable {
    let inverters: [BomItemDTO]
    let optimizers: [BomItemDTO]
    let batteries: [BomItemDTO]
    let modules: [BomItemDTO]
    let custom: [BomItemDTO]
    let rackingSets: [BomItemDTO]
    let caulkingBottles: [BomItemDTO]
    let moduleCovers: [BomItemDTO]
}

/// `BomItemDto`.
struct BomItemDTO: Codable {
    let id: Int
    let type: String
    let modelId: String
    let itemNameKey: String
    let itemName: String
    let itemCount: Double
    let cost: Double
    let notes: String
}

/// `SiteDetails` of the Designer spec (prefixed to keep it apart from the
/// Monitoring `SiteDetailsDTO`).
struct DesignerSiteDetailsDTO: Codable {
    let customerDetails: CustomerDetailsDTO
    let country: String
    let state: String
    let city: String
    let street: String
    let name: String
    let zipCode: String
    let grid: String
    let currency: String
    let id: Int
}

/// `CustomerDetails`.
struct CustomerDetailsDTO: Codable {
    let firstName: String
    let lastName: String
    let company: String
}


/// Maps a raw enum value, or throws naming the field.
private func enumValue<T: RawRepresentable>(_ type: T.Type, _ raw: String, field: String) throws -> T where T.RawValue == String {
    guard let value = T(rawValue: raw) else {
        throw SolarEdgeError.decodingWithMessage(message: "Unknown value for field '\(field)'. Value: \(raw)")
    }
    return value
}

extension ReportDataDTO {
    var entity: Designer.ReportData {
        get throws {
            try Designer.ReportData(siteReport: siteReport.entity, siteDetails: siteDetails.entity)
        }
    }
}

extension SiteReportDTO {
    var entity: Designer.SiteReport {
        get throws {
            try Designer.SiteReport(
                overview: overview.entity,
                simulationResults: simulationResults.entity,
                estimatedMonthlyEnergy: estimatedMonthlyEnergy.map(\.entity),
                pvModules: pvModules.map { try $0.entity },
                billOfMaterials: billOfMaterials.entity,
                numOfImages: numOfImages
            )
        }
    }
}

extension SystemOverviewDTO {
    var entity: Designer.SiteReport.Overview {
        get throws {
            try Designer.SiteReport.Overview(
                pvModules: pvModules, inverters: inverters, optimizers: optimizers, orientations: orientations, batteries: batteries,
                optimizerGeneralType: enumValue(Designer.OptimizerModel.OptimizerType.self, optimizerGeneralType, field: "optimizerGeneralType")
            )
        }
    }
}

extension SystemDataDTO {
    var entity: Designer.SiteReport.SimulationResults {
        Designer.SiteReport.SimulationResults(
            installedPower: installedPower, maxAchievedDcPower: maxAchievedDcPower, actualAchievedOversizing: actualAchievedOversizing,
            maxActiveAcPower: maxActiveAcPower, maxAchievedAcPower: maxAchievedAcPower, maxActiveApparentPower: maxActiveApparentPower,
            annualEnergy: annualEnergy, nonSeInverterAnnualEnergy: nonSeInverterAnnualEnergy, annualApparentEnergy: annualApparentEnergy,
            annualReactiveEnergy: annualReactiveEnergy, maxReactivePower: maxReactivePower, performanceRatio: performanceRatio,
            performanceIndex: performanceIndex, co2EmissionSaved: co2EmissionSaved, equivalentTreesPlanted: equivalentTreesPlanted
        )
    }
}

extension EstimatedMonthlyEnergyDTO {
    var entity: Designer.SiteReport.MonthlyEnergy {
        Designer.SiteReport.MonthlyEnergy(produced: produced, clipped: clipped, selfConsumed: selfConsumed, consumed: consumed, monthInEnglish: monthInEnglish)
    }
}

extension PvModulesDTO {
    var entity: Designer.SiteReport.PvModuleGroup {
        get throws {
            try Designer.SiteReport.PvModuleGroup(
                modulesCount: modulesCount, moduleName: moduleName, power: power,
                mountingType: enumValue(Designer.MountingType.self, mountingType, field: "mountingType"),
                moduleOrientation: enumValue(Designer.ModuleOrientation.self, moduleOrientation, field: "moduleOrientation"),
                absoluteAzimuth: absoluteAzimuth, absoluteTilt: absoluteTilt, userDefined: userDefined
            )
        }
    }
}

extension BillOfMaterialsDTO {
    var entity: Designer.SiteReport.BillOfMaterials {
        get throws {
            try Designer.SiteReport.BillOfMaterials(
                inverters: inverters.map { try $0.entity },
                optimizers: optimizers.map { try $0.entity },
                batteries: batteries.map { try $0.entity },
                modules: modules.map { try $0.entity },
                custom: custom.map { try $0.entity },
                rackingSets: rackingSets.map { try $0.entity },
                caulkingBottles: caulkingBottles.map { try $0.entity },
                moduleCovers: moduleCovers.map { try $0.entity }
            )
        }
    }
}

extension BomItemDTO {
    var entity: Designer.SiteReport.BillOfMaterials.Item {
        get throws {
            try Designer.SiteReport.BillOfMaterials.Item(
                id: id, type: enumValue(Designer.SiteReport.BillOfMaterials.Item.ItemType.self, type, field: "type"),
                modelId: modelId, itemNameKey: itemNameKey, itemName: itemName, itemCount: itemCount, cost: cost, notes: notes
            )
        }
    }
}

extension DesignerSiteDetailsDTO {
    var entity: Designer.SiteDetails {
        Designer.SiteDetails(
            id: .init(rawValue: id), name: name,
            customerDetails: Designer.SiteDetails.Customer(firstName: customerDetails.firstName, lastName: customerDetails.lastName, company: customerDetails.company),
            country: country, state: state, city: city, street: street, zipCode: zipCode, grid: grid, currency: currency
        )
    }
}
