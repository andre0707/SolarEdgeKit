//
//  DeviceDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

struct DeviceDataDTO: Codable {
    let type: String
    let serialNumber: String
    let manufacturer: String
    let model: String
    let partNumber: String?
    let powerModel: String
    let createdAt: String
    let firmwareVersion: String?
    let firmware: String?
    let connectedTo: String?
    /// Not nullable in the spec, but documented as omitted for top-level devices.
    let connectedToName: String?
    let parent: DeviceParentDTO?
    let active: Bool
    let nameplate: Double?
    let name: String
    /// Not nullable in the spec, but documented as only present for meters.
    let meterType: String?
    let form: String?
    let communicationType: String?
    let connectedOptimizers: Int?
}


extension DeviceDataDTO {
    var entity: Monitoring.Device {
        get throws {
            let type = Monitoring.DeviceType(rawValue: type)
            guard let createdAt = DateFormatter.iso8601FormattedDate(from: createdAt) else {
                throw SolarEdgeError.decodingWithMessage(message: "Wrong date format for field 'createdAt'. Value: \(self.createdAt)")
            }
            let communicationType = communicationType.map(Monitoring.CommunicationType.init(rawValue:))

            return Monitoring.Device(type: type,
                          serialNumber: serialNumber,
                          manufacturer: manufacturer,
                          model: model,
                          partNumber: partNumber,
                          powerModel: powerModel,
                          createdAt: createdAt,
                          firmwareVersion: firmwareVersion,
                          firmware: firmware,
                          connectedTo: connectedTo,
                          connectedToName: connectedToName,
                          parent: try parent?.entity,
                          active: active,
                          nameplate: nameplate,
                          name: name,
                          meterType: meterType,
                          form: form,
                          communicationType: communicationType,
                          connectedOptimizers: connectedOptimizers)
        }
    }
}
