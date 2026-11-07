//
//  DeviceParentDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct DeviceParentDTO: Codable {
    let serialNumber: String
    let type: String
    let name: String
}


extension DeviceParentDTO {
    var entity: Monitoring.DeviceParent {
        get throws {
            let type = Monitoring.DeviceType(rawValue: type)

            return Monitoring.DeviceParent(serialNumber: serialNumber, type: type, name: name)
        }
    }
}
