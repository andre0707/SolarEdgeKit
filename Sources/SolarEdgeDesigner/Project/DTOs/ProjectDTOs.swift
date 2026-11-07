//
//  ProjectDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `ProjectParams` and `ProjectUpdateParams`, the request bodies of
/// `POST /project` and `PUT /project/{projectId}`. They have the same
/// fields; `nil` values are left out of the JSON.
struct ProjectParamsDTO: Encodable, Hashable {
    let name: String?
    let externalId: String?
    let createdBy: String?
    let longitude: Double?
    let latitude: Double?
    let countryCode: String?
    let stateCode: String?
    let address: ProjectAddressDTO?
    let gridId: String?
    let consumption: Double?
    let monthlyBill: Double?
    let consumptionProfile: [Double]?
    let consumptionProfileId: String?
    let exportLimit: Double?
    let powerFactor: Double?
    let pvModuleSetup: [PvModuleSetupDTO]?
    let pvLayoutConfig: PvLayoutConfigDTO?
    let oversizing: Double?
    let systemType: String?
    let backup: Bool?
    let batteries: [BatteriesDTO]?
    let electricalDesign: ElectricalDesignDTO?
    let incentives: [Int]?
    let utilityImportRateId: Int?
    let utilityExportRateId: Int?
    let systemPrice: Double?
    let pricePerWatt: Double?
    let systemLifetime: SystemLifetimeDTO?
    let shadingFactor: Double?
    let useBma: Bool?
}

/// `ProjectAddress`.
struct ProjectAddressDTO: Encodable, Hashable {
    let street: String?
    let city: String?
    let zipCode: String?
}

/// `PvLayoutConfig`. Empty lists are left out.
struct PvLayoutConfigDTO: Encodable, Hashable {
    let polygons: [PublicApiPolygonDTO]?
    let obstacles: [PublicApiObstacleDTO]?
    let moduleModels: [PublicApiModuleModelDTO]?
    let moduleGroups: [PublicApiModuleGroupDTO]?
}

/// `PublicApiPolygon`. Each vertex is `[x, y, z]`.
struct PublicApiPolygonDTO: Encodable, Hashable {
    let vertices: [[Double]]
}

/// `PublicApiObstacle`.
struct PublicApiObstacleDTO: Encodable, Hashable {
    let rectangle: PublicApiRectangleDTO
    let height: Double?
    let flushed: Bool?
}

/// `PublicApiRectangle`. `center` is `[x, y]`, `size` is `[width, height]`.
struct PublicApiRectangleDTO: Encodable, Hashable {
    let center: [Double]
    let size: [Double]
    let rotation: Double?
}

/// `PublicApiModuleModel`.
struct PublicApiModuleModelDTO: Encodable, Hashable {
    let externalId: Int?
    let manufacturer: String?
    let model: String?

    enum CodingKeys: String, CodingKey {
        case externalId = "external_id"
        case manufacturer, model
    }
}

/// `PublicApiModuleGroup`.
struct PublicApiModuleGroupDTO: Encodable, Hashable {
    let modelId: Int
    let polygonId: Int
    let rows: Int
    let cols: Int
    let x: Double
    let y: Double
    let orientation: String
    let rackingType: String
    let tilt: Double?
    let azimuth: Double?
    let ridgeDirection: Double?
    let rowSpacing: Double?
    let colSpacing: Double?
    let domeSpacing: Double?
    let frameRows: Int?
    let deletedModules: [PublicApiModuleIdDTO]?

    enum CodingKeys: String, CodingKey {
        case modelId = "model_id"
        case polygonId = "polygon_id"
        case rows, cols, x, y, orientation
        case rackingType = "racking_type"
        case tilt, azimuth
        case ridgeDirection = "ridge_direction"
        case rowSpacing = "row_spacing"
        case colSpacing = "col_spacing"
        case domeSpacing = "dome_spacing"
        case frameRows = "frame_rows"
        case deletedModules = "deleted_modules"
    }
}

/// `PublicApiModuleId`.
struct PublicApiModuleIdDTO: Encodable, Hashable {
    let r: Int
    let c: Int
    let fr: Int?
}

/// `PublicApiResponse`.
struct PublicApiResponseDTO: Codable {
    let siteId: Int
    let siteUrl: String

    enum CodingKeys: String, CodingKey {
        case siteId = "site_id"
        case siteUrl = "site_url"
    }
}


extension ProjectParamsDTO {
    init(_ update: Designer.ProjectUpdate) {
        self.init(
            name: update.name,
            externalId: update.externalID,
            createdBy: update.createdBy,
            longitude: update.longitude,
            latitude: update.latitude,
            countryCode: update.countryCode,
            stateCode: update.stateCode,
            address: update.address.map { ProjectAddressDTO(street: $0.street, city: $0.city, zipCode: $0.zipCode) },
            gridId: update.gridID?.rawValue,
            consumption: update.consumption,
            monthlyBill: update.monthlyBill,
            consumptionProfile: update.consumptionProfile,
            consumptionProfileId: update.consumptionProfileID?.rawValue,
            exportLimit: update.exportLimit,
            powerFactor: update.powerFactor,
            pvModuleSetup: update.pvModuleSetup?.map(PvModuleSetupDTO.init),
            pvLayoutConfig: update.pvLayout.map(PvLayoutConfigDTO.init),
            oversizing: update.oversizing,
            systemType: update.systemType?.rawValue,
            backup: update.backup,
            batteries: update.batteries?.map(BatteriesDTO.init),
            electricalDesign: update.electricalDesign.map(ElectricalDesignDTO.init),
            incentives: update.incentives?.map(\.rawValue),
            utilityImportRateId: update.utilityImportRateID?.rawValue,
            utilityExportRateId: update.utilityExportRateID?.rawValue,
            systemPrice: update.systemPrice,
            pricePerWatt: update.pricePerWatt,
            systemLifetime: update.systemLifetime.map(SystemLifetimeDTO.init),
            shadingFactor: update.shadingFactor,
            useBma: update.useBatteryManagementAlgorithm
        )
    }
}

extension PvLayoutConfigDTO {
    init(_ layout: Designer.PvLayout) {
        func nonEmpty<T>(_ list: [T]) -> [T]? { list.isEmpty ? nil : list }

        self.init(
            polygons: nonEmpty(layout.polygons.map { PublicApiPolygonDTO(vertices: $0.vertices.map { [$0.x, $0.y, $0.z] }) }),
            obstacles: nonEmpty(layout.obstacles.map {
                PublicApiObstacleDTO(
                    rectangle: PublicApiRectangleDTO(center: [$0.rectangle.centerX, $0.rectangle.centerY],
                                                     size: [$0.rectangle.width, $0.rectangle.height],
                                                     rotation: $0.rectangle.rotation),
                    height: $0.height, flushed: $0.flushed)
            }),
            moduleModels: nonEmpty(layout.moduleModels.map { PublicApiModuleModelDTO(externalId: $0.externalID, manufacturer: $0.manufacturer, model: $0.model) }),
            moduleGroups: nonEmpty(layout.moduleGroups.map { group in
                PublicApiModuleGroupDTO(
                    modelId: group.modelIndex, polygonId: group.polygonIndex, rows: group.rows, cols: group.columns,
                    x: group.x, y: group.y, orientation: group.orientation.rawValue, rackingType: group.rackingType.rawValue,
                    tilt: group.tilt, azimuth: group.azimuth, ridgeDirection: group.ridgeDirection,
                    rowSpacing: group.rowSpacing, colSpacing: group.columnSpacing, domeSpacing: group.domeSpacing,
                    frameRows: group.frameRows,
                    deletedModules: nonEmpty(group.deletedModules.map { PublicApiModuleIdDTO(r: $0.row, c: $0.column, fr: $0.rowInFrame) })
                )
            })
        )
    }
}

extension PublicApiResponseDTO {
    var entity: Designer.ProjectSite {
        get throws {
            guard let url = URL(string: siteUrl) else {
                throw SolarEdgeError.decodingWithMessage(message: "Invalid URL for field 'site_url'. Value: \(siteUrl)")
            }
            return Designer.ProjectSite(siteID: .init(rawValue: siteId), siteURL: url)
        }
    }
}
