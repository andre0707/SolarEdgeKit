//
//  EstimationLookupDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `Battery`.
struct BatteryDTO: Codable {
    let id: String
    let capacity: Int
    let displayName: String
}

/// `ConsumptionProfile`.
struct ConsumptionProfileDTO: Codable {
    let id: String
    let name: String
}

/// `GridCode`.
struct GridCodeDTO: Codable {
    let id: String
    let name: String
    let onePhaseVoltage: Int
    let threePhaseVoltage: Int
}

/// `PvModule`.
struct PvModuleDTO: Codable {
    let id: Int
    let manufacturer: String
    let model: String
    let stcPower: Double
}

/// `UtilityProvider`.
struct UtilityProviderDTO: Codable {
    let name: String
}

/// `UtilityRate`.
struct UtilityRateDTO: Codable {
    let id: Int
    let utilityName: String
    let name: String
    let rateType: String
    let effectiveDate: String
}

/// `Incentive`.
struct IncentiveDTO: Codable {
    let id: Int
    let name: String
    let summary: String
}


extension BatteryDTO {
    var entity: Designer.Battery {
        Designer.Battery(id: .init(rawValue: id), capacity: capacity, displayName: displayName)
    }
}

extension ConsumptionProfileDTO {
    var entity: Designer.ConsumptionProfile {
        Designer.ConsumptionProfile(id: .init(rawValue: id), name: name)
    }
}

extension GridCodeDTO {
    var entity: Designer.GridCode {
        Designer.GridCode(id: .init(rawValue: id), name: name, onePhaseVoltage: onePhaseVoltage, threePhaseVoltage: threePhaseVoltage)
    }
}

extension PvModuleDTO {
    var entity: Designer.PvModule {
        Designer.PvModule(id: .init(rawValue: id), manufacturer: manufacturer, model: model, stcPower: stcPower)
    }
}

extension UtilityProviderDTO {
    var entity: Designer.UtilityProvider {
        Designer.UtilityProvider(name: name)
    }
}

extension UtilityRateDTO {
    var entity: Designer.UtilityRate {
        get throws {
            guard let type = Designer.UtilityRate.RateType(rawValue: rateType) else {
                throw SolarEdgeError.decodingWithMessage(message: "Unknown rate type for field 'rateType'. Value: \(rateType)")
            }
            guard let date = CalendarDate(isoString: effectiveDate) else {
                throw SolarEdgeError.decodingWithMessage(message: "Invalid date for field 'effectiveDate'. Value: \(effectiveDate)")
            }

            return Designer.UtilityRate(id: .init(rawValue: id), utilityName: utilityName, name: name, rateType: type, effectiveDate: date)
        }
    }
}

extension IncentiveDTO {
    var entity: Designer.Incentive {
        Designer.Incentive(id: .init(rawValue: id), name: name, summary: summary)
    }
}
