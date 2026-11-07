//
//  ParameterValidation.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Throws ``SolarEdgeError/invalidRequest(_:)`` with `message` unless
/// `condition` holds.
func check(_ condition: Bool, _ message: @autoclosure () -> String) throws {
    if !condition { throw SolarEdgeError.invalidRequest(message()) }
}

/// Checks that `value`, if set, is within `range`.
func checkRange(_ value: Double?, _ range: ClosedRange<Double>, _ name: String) throws {
    guard let value else { return }
    try check(range.contains(value), "'\(name)' must be within \(range.lowerBound)...\(range.upperBound), got \(value)")
}

/// Checks that `value`, if set, is at least the range's lower bound.
func checkRange(_ value: Double?, _ range: PartialRangeFrom<Double>, _ name: String) throws {
    guard let value else { return }
    try check(range.contains(value), "'\(name)' must be at least \(range.lowerBound), got \(value)")
}

/// Checks that `value`, if set, is within `range`.
func checkRange(_ value: Int?, _ range: ClosedRange<Int>, _ name: String) throws {
    guard let value else { return }
    try check(range.contains(value), "'\(name)' must be within \(range.lowerBound)...\(range.upperBound), got \(value)")
}

/// Checks that `value`, if set, has at most `maxLength` characters.
func checkLength(_ value: String?, max maxLength: Int, _ name: String) throws {
    guard let value else { return }
    try check(value.count <= maxLength, "'\(name)' must have at most \(maxLength) characters, got \(value.count)")
}

/// An hourly consumption profile has exactly 8760 values, none negative.
func validateConsumptionProfile(_ profile: [Double]?) throws {
    guard let profile else { return }
    try check(profile.count == 8760, "'consumptionProfile' must have 8760 values, got \(profile.count)")
    try check(profile.allSatisfy { $0 >= 0 }, "'consumptionProfile' must not contain negative values")
}

extension Designer.PvModuleSetup {
    func validate() throws {
        try check(pvModuleCount >= 1, "'pvModuleCount' must be at least 1, got \(pvModuleCount)")
        try checkRange(panelDirection.azimuth, 0...359, "azimuth")
        try checkRange(panelDirection.tilt, 0...80, "tilt")
    }
}

extension Designer.BatterySetup {
    func validate() throws {
        try check(batteryCount >= 1, "'batteryCount' must be at least 1, got \(batteryCount)")
        try validateRequired(batteryID.rawValue, name: "batteryId")
    }
}

extension Designer.SystemLifetime {
    func validate() throws {
        try checkRange(discountRate, 0...1, "discountRate")
        try checkRange(expectedProductionDegradation, 0...1, "expectedProductionDegradation")
    }
}
