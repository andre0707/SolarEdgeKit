import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct MeterTelemetryDTOTests {

    func decode(_ meter: String) throws -> [String: Monitoring.MeterTelemetry] {
        let json = """
        {"period":{"from":"2026-01-01T00:00:00Z","to":"2026-01-01T00:30:00Z"},"resolution":"QUARTER_HOUR",
         "meters":{"M-1":\(meter)}}
        """
        return try JSONDecoder().decode(MeterTelemetryResponseDTO.self, from: Data(json.utf8)).entity
    }

    func metric(_ unit: String) -> String {
        """
        {"unit":"\(unit)","values":[{"timestamp":"2026-01-01T00:00:00Z","value":1}]}
        """
    }

    /// Each metric gets the response's period and resolution.
    @Test
    func mapsAllEightMetricsWithTheSharedPeriod() throws {
        let telemetry = try decode("""
        {"productionPower":\(metric("W")),"productionEnergy":\(metric("WH")),
         "consumptionPower":\(metric("KW")),"consumptionEnergy":\(metric("KWH")),
         "importPower":\(metric("MW")),"importEnergy":\(metric("MWH")),
         "exportPower":\(metric("W")),"exportEnergy":\(metric("WH"))}
        """)

        let meter = try #require(telemetry["M-1"])
        let period = DateInterval(start: Date(timeIntervalSince1970: 1_767_225_600), end: Date(timeIntervalSince1970: 1_767_227_400))
        #expect(meter.productionPower?.unit == .watt)
        #expect(meter.productionEnergy?.unit == .wattHour)
        #expect(meter.consumptionPower?.unit == .kiloWatt)
        #expect(meter.consumptionEnergy?.unit == .kiloWattHour)
        #expect(meter.importPower?.unit == .megaWatt)
        #expect(meter.importEnergy?.unit == .megaWattHour)
        #expect(meter.exportPower?.period == period)
        #expect(meter.exportEnergy?.resolution == .quarterHour)
    }

    /// At DAY and coarser, only the energy metrics are present.
    @Test
    func leavesUnsupportedMetricsNil() throws {
        let telemetry = try decode("""
        {"importEnergy":\(metric("WH")),"exportEnergy":\(metric("WH"))}
        """)

        let meter = try #require(telemetry["M-1"])
        #expect(meter.importEnergy != nil)
        #expect(meter.exportEnergy != nil)
        #expect(meter.importPower == nil)
        #expect(meter.productionPower == nil)
    }

    @Test
    func rejectsAPowerUnitForAnEnergyMetric() {
        #expect(throws: SolarEdgeError.self) {
            try decode("""
            {"importEnergy":\(metric("W"))}
            """)
        }
    }
}
