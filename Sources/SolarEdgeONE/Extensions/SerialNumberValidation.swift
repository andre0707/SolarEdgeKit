//
//  SerialNumberValidation.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Serial numbers go into the URL path as one segment, and the telemetry
/// and status endpoints separate several with commas. `.` and `..` would be
/// read as path segments (`…/inverters/../power` is the site's power).
func validateSerialNumber(_ serialNumber: String) throws {
    guard !serialNumber.isEmpty, serialNumber != ".", serialNumber != "..",
          !serialNumber.contains("/"), !serialNumber.contains(",") else {
        throw SolarEdgeError.invalidRequest("Invalid serial number: '\(serialNumber)'")
    }
}
