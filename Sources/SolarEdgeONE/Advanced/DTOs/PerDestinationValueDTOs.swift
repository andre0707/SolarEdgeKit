//
//  PerDestinationValueDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `SiteProductionValue`: one bucket of production, split by destination.
struct SiteProductionValueDTO: Codable {
    let timestamp: String
    let total: Double
    let toSelfConsumption: Double
    let toStorage: Double
    let toGrid: Double
}

/// `SiteConsumptionValue`: one bucket of consumption, split by source.
struct SiteConsumptionValueDTO: Codable {
    let timestamp: String
    let total: Double
    let fromPv: Double
    let fromStorage: Double
    let fromGrid: Double
}


extension SiteProductionValueDTO {
    var entity: Monitoring.ProductionBreakdown {
        get throws {
            Monitoring.ProductionBreakdown(timestamp: try perDestinationDate(timestamp),
                                total: total,
                                toSelfConsumption: toSelfConsumption,
                                toStorage: toStorage,
                                toGrid: toGrid)
        }
    }
}

extension SiteConsumptionValueDTO {
    var entity: Monitoring.ConsumptionBreakdown {
        get throws {
            Monitoring.ConsumptionBreakdown(timestamp: try perDestinationDate(timestamp),
                                 total: total,
                                 fromPv: fromPv,
                                 fromStorage: fromStorage,
                                 fromGrid: fromGrid)
        }
    }
}

private func perDestinationDate(_ string: String) throws -> Date {
    guard let date = DateFormatter.iso8601FormattedDate(from: string) else {
        throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'timestamp'. Value: \(string)")
    }
    return date
}
