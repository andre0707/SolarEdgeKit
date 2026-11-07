import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct InverterTelemetryDTOTests {

    func decode(_ json: String) throws -> [String: Monitoring.InverterTelemetry] {
        try JSONDecoder().decode(InverterTelemetryResponseDTO.self, from: Data(json.utf8)).entity
    }

    func series(_ unit: String) -> String {
        """
        {"period":{"from":"2026-01-01T00:00:00Z","to":"2026-01-01T00:15:00Z"},"unit":"\(unit)",
         "resolution":"QUARTER_HOUR","values":[{"timestamp":"2026-01-01T00:00:00Z","value":1}]}
        """
    }

    /// Every metric maps to its own unit type.
    @Test
    func mapsAllSevenMetrics() throws {
        let telemetry = try decode("""
        {"inverters":{"7E1234B5-67":{
          "power":\(series("W")),"energy":\(series("WH")),
          "consumedAcPower":\(series("KW")),"consumedAcEnergy":\(series("KWH")),
          "voltage":\(series("VOLT")),"current":\(series("AMPERE")),"frequency":\(series("HERTZ"))}}}
        """)

        let inverter = try #require(telemetry["7E1234B5-67"])
        #expect(inverter.power?.unit == .watt)
        #expect(inverter.energy?.unit == .wattHour)
        #expect(inverter.consumedAcPower?.unit == .kiloWatt)
        #expect(inverter.consumedAcEnergy?.unit == .kiloWattHour)
        #expect(inverter.voltage?.unit == .volt)
        #expect(inverter.current?.unit == .ampere)
        #expect(inverter.frequency?.unit == .hertz)
    }

    /// At DAY and coarser, only the energy metrics are present.
    @Test
    func leavesUnsupportedMetricsNil() throws {
        let telemetry = try decode("""
        {"inverters":{"A":{"energy":\(series("WH")),"consumedAcEnergy":\(series("WH"))}}}
        """)

        let inverter = try #require(telemetry["A"])
        #expect(inverter.energy != nil)
        #expect(inverter.consumedAcEnergy != nil)
        #expect(inverter.power == nil)
        #expect(inverter.voltage == nil)
        #expect(inverter.current == nil)
        #expect(inverter.frequency == nil)
    }

    @Test
    func rejectsAUnitThatDoesNotFitTheMetric() {
        #expect(throws: SolarEdgeError.self) {
            try decode("""
            {"inverters":{"A":{"voltage":\(series("W"))}}}
            """)
        }
    }
}
