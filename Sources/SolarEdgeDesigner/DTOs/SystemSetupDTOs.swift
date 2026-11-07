//
//  SystemSetupDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

/// `PvModuleSetup`.
struct PvModuleSetupDTO: Encodable, Hashable {
    let pvModuleId: Int
    let pvModuleCount: Int
    let panelDirection: PanelDirectionDTO
    let mountType: String
}

/// `PanelDirection`.
struct PanelDirectionDTO: Encodable, Hashable {
    let azimuth: Double
    let tilt: Double
}

/// `Batteries`.
struct BatteriesDTO: Encodable, Hashable {
    let batteryCount: Int
    let batteryId: String
}

/// `SystemLifetime`. `nil` values are left out.
struct SystemLifetimeDTO: Encodable, Hashable {
    let years: Int?
    let discountRate: Double?
    let expectedElectricityPriceIncrease: Double?
    let expectedProductionDegradation: Double?
}

/// `ElectricalDesign`. `nil` values are left out.
struct ElectricalDesignDTO: Encodable, Hashable {
    let inverterModel: String?
    let optimizerModel: String?
}


extension PvModuleSetupDTO {
    init(_ setup: Designer.PvModuleSetup) {
        self.init(pvModuleId: setup.pvModuleID.rawValue, pvModuleCount: setup.pvModuleCount,
                  panelDirection: PanelDirectionDTO(azimuth: setup.panelDirection.azimuth, tilt: setup.panelDirection.tilt),
                  mountType: setup.mountType.rawValue)
    }
}

extension BatteriesDTO {
    init(_ battery: Designer.BatterySetup) {
        self.init(batteryCount: battery.batteryCount, batteryId: battery.batteryID.rawValue)
    }
}

extension SystemLifetimeDTO {
    init(_ lifetime: Designer.SystemLifetime) {
        self.init(years: lifetime.years, discountRate: lifetime.discountRate,
                  expectedElectricityPriceIncrease: lifetime.expectedElectricityPriceIncrease,
                  expectedProductionDegradation: lifetime.expectedProductionDegradation)
    }
}

extension ElectricalDesignDTO {
    init(_ design: Designer.ElectricalDesign) {
        self.init(inverterModel: design.inverterModel, optimizerModel: design.optimizerModel)
    }
}
