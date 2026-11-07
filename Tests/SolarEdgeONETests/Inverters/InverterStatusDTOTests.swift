import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct InverterStatusDTOTests {

    func decode(_ inverter: String, resolution: String = "QUARTER_HOUR") throws -> Monitoring.InverterStatusReport {
        let json = """
        {"period":{"from":"2026-01-01T00:00:00Z","to":"2026-01-01T00:30:00Z"},"resolution":"\(resolution)",
         "inverters":{"7E1234B5-67":\(inverter)}}
        """
        return try JSONDecoder().decode(InverterStatusResponseDTO.self, from: Data(json.utf8)).entity
    }

    /// The spec's example for specific inverters, with a `null` temperature.
    @Test
    func mapsTheSpecExample() throws {
        let report = try decode("""
        {"powerLimit":{"unit":"PERCENTAGE","values":[{"timestamp":"2026-01-01T00:00:00Z","value":100},{"timestamp":"2026-01-01T00:15:00Z","value":100}]},
         "operationMode":{"values":[{"timestamp":"2026-01-01T00:00:00Z","value":0},{"timestamp":"2026-01-01T00:15:00Z","value":0}]},
         "inverterMode":{"values":[{"timestamp":"2026-01-01T00:00:00Z","value":"MPPT"},{"timestamp":"2026-01-01T00:15:00Z","value":null}]},
         "temperature":{"unit":"CELSIUS","values":[{"timestamp":"2026-01-01T00:00:00Z","value":37.2},{"timestamp":"2026-01-01T00:15:00Z","value":null}]}}
        """)

        #expect(report.resolution == .quarterHour)
        let status = try #require(report.inverters["7E1234B5-67"])
        #expect(status.powerLimit?.unit == .percentage)
        #expect(status.powerLimit?.values.map(\.value) == [100, 100])
        #expect(status.operationMode?.map(\.value) == [0, 0])
        #expect(status.inverterMode?.map(\.mode) == [.mppt, nil])
        #expect(status.temperature?.unit == .celsius)
        #expect(status.temperature?.values.map(\.value) == [37.2, nil])
    }

    /// For a whole site, a metric is present only where the inverter reported it.
    @Test
    func leavesUnreportedMetricsNil() throws {
        let report = try decode("""
        {"temperature":{"unit":"CELSIUS","values":[{"timestamp":"2026-01-01T00:00:00Z","value":37.5}]}}
        """)

        let status = try #require(report.inverters["7E1234B5-67"])
        #expect(status.temperature != nil)
        #expect(status.powerLimit == nil)
        #expect(status.operationMode == nil)
        #expect(status.inverterMode == nil)
    }

    @Test
    func keepsTheSpecSpellingOfPhaseBalancer() throws {
        let report = try decode("""
        {"inverterMode":{"values":[{"timestamp":"2026-01-01T00:00:00Z","value":"LOCKED_PHASE_BALNCER"}]}}
        """)

        #expect(report.inverters["7E1234B5-67"]?.inverterMode?.first?.mode == .lockedPhaseBalancer)
    }

    /// An unknown unit makes the numbers meaningless, so it throws ...
    @Test
    func rejectsAnUnknownUnit() {
        #expect(throws: SolarEdgeError.self) { try decode(#"{"temperature":{"unit":"FAHRENHEIT","values":[]}}"#) }
    }

    /// ... while an inverter mode added on the server is kept.
    @Test
    func keepsAnUnknownMode() throws {
        let report = try decode(#"{"inverterMode":{"values":[{"timestamp":"2026-01-01T00:00:00Z","value":"DANCING"}]}}"#)

        #expect(report.inverters["7E1234B5-67"]?.inverterMode?.first?.mode == .unknown("DANCING"))
    }

    @Test
    func rejectsAResolutionStatusDoesNotSupport() {
        #expect(throws: SolarEdgeError.self) { try decode("{}", resolution: "DAY") }
    }
}
