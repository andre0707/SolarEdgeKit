//
//  AlertComponentDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

struct AlertComponentDTO: Codable {
    let name: String
    let serialNumber: String
}


extension AlertComponentDTO {
    var entity: Monitoring.AlertComponent {
        Monitoring.AlertComponent(name: name, serialNumber: serialNumber)
    }
}
