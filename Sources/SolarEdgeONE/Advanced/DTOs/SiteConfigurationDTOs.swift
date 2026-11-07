//
//  SiteConfigurationDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `WeatherGuard`.
struct WeatherGuardDTO: Codable {
    let status: Bool
}

/// `BatteryBackupReserve`.
struct BatteryBackupReserveDTO: Codable {
    let percentage: Double?
    let backupReserveStatus: String
}


extension WeatherGuardDTO {
    var entity: Monitoring.WeatherGuard {
        Monitoring.WeatherGuard(isEnabled: status)
    }
}

extension BatteryBackupReserveDTO {
    var entity: Monitoring.BatteryBackupReserve {
        get throws {
            let status = Monitoring.BatteryBackupReserve.Status(rawValue: backupReserveStatus)

            return Monitoring.BatteryBackupReserve(percentage: percentage, status: status)
        }
    }
}
