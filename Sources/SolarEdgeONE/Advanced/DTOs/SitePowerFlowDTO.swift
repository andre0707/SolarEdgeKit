//
//  SitePowerFlowDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `SitePowerFlow`.
struct SitePowerFlowDTO: Codable {
    let updatedAt: String?
    let refreshRate: Int
    /// `W` or `kW`, with a lowercase k unlike the other endpoints.
    let unit: String
    let pv: EnergyElementDTO
    let load: EnergyElementDTO
    let storage: StorageFlowDTO
    let grid: GridFlowDTO
}

/// `EnergyElement`.
struct EnergyElementDTO: Codable {
    let active: Bool
    let power: Double?
}

/// The inline `storage` object of `SitePowerFlow`.
struct StorageFlowDTO: Codable {
    let active: Bool
    let power: Double?
    let status: String?
    let chargeLevel: Int?
}

/// The inline `grid` object of `SitePowerFlow`.
struct GridFlowDTO: Codable {
    let active: Bool
    let power: Double?
    let status: String?
}


extension SitePowerFlowDTO {
    var entity: Monitoring.PowerFlow {
        get throws {
            let updatedAt = try updatedAt.map {
                guard let date = DateFormatter.iso8601FormattedDate(from: $0) else {
                    throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'updatedAt'. Value: \($0)")
                }
                return date
            }
            let storageStatus = storage.status.map(Monitoring.PowerFlowStorage.Status.init(rawValue:))
            let gridStatus = grid.status.map(Monitoring.PowerFlowGrid.Status.init(rawValue:))

            return Monitoring.PowerFlow(updatedAt: updatedAt,
                             refreshRate: refreshRate,
                             unit: try Self.power(unit),
                             pv: Monitoring.PowerFlowNode(active: pv.active, power: pv.power),
                             load: Monitoring.PowerFlowNode(active: load.active, power: load.power),
                             storage: Monitoring.PowerFlowStorage(active: storage.active, power: storage.power,
                                                       status: storageStatus, chargeLevel: storage.chargeLevel),
                             grid: Monitoring.PowerFlowGrid(active: grid.active, power: grid.power, status: gridStatus))
        }
    }

    /// This endpoint writes `kW`; ``Monitoring/Power`` uses `KW` like the rest of the API.
    private static func power(_ unit: String) throws -> Monitoring.Power {
        switch unit {
            case "W": return .watt
            case "kW": return .kiloWatt
            default:
                guard let power = Monitoring.Power(rawValue: unit) else {
                    throw SolarEdgeError.decodingWithMessage(message: "Unexpected unit for field 'unit'. Value: \(unit)")
                }
                return power
        }
    }
}
