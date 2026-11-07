//
//  EstimationParamsDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

/// `EstimationParams`, the request body of `POST /estimation`. `nil`
/// values are left out of the JSON.
struct EstimationParamsDTO: Encodable, Hashable {
    let longitude: Double
    let latitude: Double
    let countryCode: String
    let stateCode: String?
    let gridId: String
    let consumption: Double?
    let consumptionProfile: [Double]?
    let consumptionProfileId: String?
    let exportLimit: Double?
    let powerFactor: Double?
    let pvModuleSetup: [PvModuleSetupDTO]
    let oversizing: Double?
    let systemType: String?
    let batteries: [BatteriesDTO]?
    let utilityImportRateId: Int
    let utilityExportRateId: Int
    let systemPrice: Double?
    let pricePerWatt: Double?
    let systemLifetime: SystemLifetimeDTO?
    let shadingFactor: Double
    let useBma: Bool?
    let incentives: [Int]?
    let profile: String?
    let electricalDesign: ElectricalDesignDTO?
}

extension EstimationParamsDTO {
    init(_ parameters: Designer.EstimationParameters) {
        self.init(
            longitude: parameters.longitude,
            latitude: parameters.latitude,
            countryCode: parameters.countryCode,
            stateCode: parameters.stateCode,
            gridId: parameters.gridID.rawValue,
            consumption: parameters.consumption,
            consumptionProfile: parameters.consumptionProfile,
            consumptionProfileId: parameters.consumptionProfileID?.rawValue,
            exportLimit: parameters.exportLimit,
            powerFactor: parameters.powerFactor,
            pvModuleSetup: parameters.pvModuleSetup.map(PvModuleSetupDTO.init),
            oversizing: parameters.oversizing,
            systemType: parameters.systemType?.rawValue,
            batteries: parameters.batteries?.map(BatteriesDTO.init),
            utilityImportRateId: parameters.utilityImportRateID.rawValue,
            utilityExportRateId: parameters.utilityExportRateID.rawValue,
            systemPrice: parameters.systemPrice,
            pricePerWatt: parameters.pricePerWatt,
            systemLifetime: parameters.systemLifetime.map(SystemLifetimeDTO.init),
            shadingFactor: parameters.shadingFactor,
            useBma: parameters.useBatteryManagementAlgorithm,
            incentives: parameters.incentives?.map(\.rawValue),
            profile: parameters.profile?.rawValue,
            electricalDesign: parameters.electricalDesign.map(ElectricalDesignDTO.init)
        )
    }
}
