import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct BatteryDTOTests {
    let period = #"{"from":"2026-01-01T00:00:00Z","to":"2026-01-01T00:30:00Z"}"#

    func metric(_ unit: String) -> String {
        #"{"unit":"\#(unit)","values":[{"timestamp":"2026-01-01T00:00:00Z","value":1}]}"#
    }

    @Test
    func telemetryMapsAllSevenMetrics() throws {
        let json = """
        {"period":\(period),"resolution":"QUARTER_HOUR","storage":{"BATT-001":{
          "chargePower":\(metric("W")),"dischargePower":\(metric("KW")),
          "chargeEnergy":\(metric("WH")),"dischargeEnergy":\(metric("KWH")),"remainingEnergy":\(metric("MWH")),
          "stateOfEnergy":\(metric("PERCENTAGE")),"acGridChargingEnergy":\(metric("WH"))}}}
        """
        let battery = try #require(try JSONDecoder().decode(StorageTelemetryResponseDTO.self, from: Data(json.utf8)).entity["BATT-001"])

        #expect(battery.chargePower?.unit == .watt)
        #expect(battery.dischargePower?.unit == .kiloWatt)
        #expect(battery.chargeEnergy?.unit == .wattHour)
        #expect(battery.dischargeEnergy?.unit == .kiloWattHour)
        #expect(battery.remainingEnergy?.unit == .megaWattHour)
        #expect(battery.stateOfEnergy?.unit == .percentage)
        #expect(battery.acGridChargingEnergy?.resolution == .quarterHour)
    }

    @Test
    func telemetryRejectsAWrongUnitForStateOfEnergy() {
        let json = """
        {"period":\(period),"resolution":"QUARTER_HOUR","storage":{"A":{"stateOfEnergy":\(metric("WH"))}}}
        """

        #expect(throws: SolarEdgeError.self) {
            try JSONDecoder().decode(StorageTelemetryResponseDTO.self, from: Data(json.utf8)).entity
        }
    }

    /// The spec allows `null` for period and resolution when there is no data.
    @Test
    func statusWithoutDataHasNoPeriod() throws {
        let json = #"{"period":null,"resolution":null,"storage":{}}"#
        let report = try JSONDecoder().decode(StorageStatusResponseDTO.self, from: Data(json.utf8)).entity

        #expect(report.period == nil)
        #expect(report.batteries.isEmpty)
    }

    /// A metric is present only where the battery has reported it.
    @Test
    func statusLeavesUnreportedMetricsNil() throws {
        let json = """
        {"period":\(period),"resolution":"QUARTER_HOUR","storage":{"BATT-001":{
          "internalTemperature":{"unit":"CELSIUS","values":[{"timestamp":"2026-01-01T00:00:00Z","value":28.3}]}}}}
        """
        let battery = try #require(try JSONDecoder().decode(StorageStatusResponseDTO.self, from: Data(json.utf8)).entity.batteries["BATT-001"])

        #expect(battery.batteryState == nil)
        #expect(battery.internalTemperature?.unit == .celsius)
        #expect(battery.internalTemperature?.values.map(\.value) == [28.3])
    }

    @Test
    func lifetimeMapsBothCounters() throws {
        let json = """
        {"batteries":[{"serialNumber":"BATT-001",
          "lifetimeEnergyCharged":[{"timestamp":"2026-01-01T00:00:00Z","value":2999999850}],
          "lifetimeEnergyDischarged":[{"timestamp":"2026-01-01T00:00:00Z","value":2499999900}],"unit":"WH"}]}
        """
        let battery = try #require(try JSONDecoder().decode(StorageLifetimeEnergyResponseDTO.self, from: Data(json.utf8)).entity.first)

        #expect(battery.serialNumber == "BATT-001")
        #expect(battery.unit == .wattHour)
        #expect(battery.charged.map(\.value) == [2999999850])
        #expect(battery.discharged.map(\.value) == [2499999900])
    }
}
