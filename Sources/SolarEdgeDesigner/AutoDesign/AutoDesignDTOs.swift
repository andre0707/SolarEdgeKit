//
//  AutoDesignDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `AutoDesignParameters`, the request body of `POST /auto-design`. `nil`
/// values are left out. `siteModeling` and `storage` have no properties in
/// the spec and are not sent.
struct AutoDesignParametersDTO: Encodable, Hashable {
    struct Site: Encodable, Hashable {
        let siteName: String
        let latitude: Double
        let longitude: Double
        let sector: String?
        let gridId: String?
    }

    struct Consumption: Encodable, Hashable {
        let utilityRateId: Int?
        let annualConsumptionKwh: Double?
        let consumptionProfileId: String?
    }

    struct PvPlacement: Encodable, Hashable {
        let moduleModelId: Int?
        let racking: String?
        let orientation: String?
        let tiltDegrees: Double?
        let columnSpacing: Double?
        let rowSpacing: Double?
        let elevation: Double?
        let maxColumns: Int?
        let maxRows: Int?
        let horizontalSpacing: Double?
        let verticalSpacing: Double?
        let setbackProfileId: Int?
        let obstacleSpacing: Double?
        let frameSize: Int?
    }

    struct ElectricalDesign: Encodable, Hashable {
        let phase: Int
    }

    struct Financials: Encodable, Hashable {
        let pricePerW: Double
    }

    let site: Site
    let consumption: Consumption?
    let pvPlacement: PvPlacement?
    let electricalDesign: ElectricalDesign?
    let financials: Financials?
}

/// `AutoDesignResponse`.
struct AutoDesignResponseDTO: Codable {
    let requestId: String
    let siteId: Int
}

/// `AutoDesignStatusResponse`.
struct AutoDesignStatusResponseDTO: Codable {
    let siteId: Int
    let executedSteps: [String: Double]
    let errorCode: String
}


extension AutoDesignParametersDTO {
    init(_ parameters: Designer.AutoDesignParameters) {
        let site = parameters.site
        self.init(
            site: Site(siteName: site.siteName, latitude: site.latitude, longitude: site.longitude,
                       sector: site.sector?.rawValue, gridId: site.gridID?.rawValue),
            consumption: parameters.consumption.map {
                Consumption(utilityRateId: $0.utilityRateID?.rawValue, annualConsumptionKwh: $0.annualConsumptionKwh,
                            consumptionProfileId: $0.consumptionProfileID?.rawValue)
            },
            pvPlacement: parameters.pvPlacement.map {
                PvPlacement(moduleModelId: $0.moduleModelID?.rawValue, racking: $0.racking?.rawValue, orientation: $0.orientation?.rawValue,
                            tiltDegrees: $0.tiltDegrees, columnSpacing: $0.columnSpacing, rowSpacing: $0.rowSpacing,
                            elevation: $0.elevation, maxColumns: $0.maxColumns, maxRows: $0.maxRows,
                            horizontalSpacing: $0.horizontalSpacing, verticalSpacing: $0.verticalSpacing,
                            setbackProfileId: $0.setbackProfileID, obstacleSpacing: $0.obstacleSpacing, frameSize: $0.frameSize)
            },
            electricalDesign: parameters.phase.map { ElectricalDesign(phase: $0.rawValue) },
            financials: parameters.pricePerWatt.map { Financials(pricePerW: $0) }
        )
    }
}

extension AutoDesignResponseDTO {
    var entity: Designer.AutoDesignRequest {
        Designer.AutoDesignRequest(requestID: .init(rawValue: requestId), siteID: .init(rawValue: siteId))
    }
}

extension AutoDesignStatusResponseDTO {
    var entity: Designer.AutoDesignStatus {
        get throws {
            let code = Designer.AutoDesignStatus.ErrorCode(rawValue: errorCode)
            return Designer.AutoDesignStatus(siteID: .init(rawValue: siteId), executedSteps: executedSteps, errorCode: code)
        }
    }
}
