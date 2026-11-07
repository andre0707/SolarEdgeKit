import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct InverterTelemetryEndpointTests {

    @Test
    func joinsSerialNumbersWithCommas() {
        let endpoint = InverterTelemetryEndpoint(
            siteID: 93082,
            serialNumbers: ["7E1234B5-67", "7E1234B5-68"],
            from: nil, to: nil, resolution: .quarterHour
        )

        #expect(endpoint.path == "sites/93082/inverters/7E1234B5-67,7E1234B5-68/telemetry")
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(endpoint.queryItems == [URLQueryItem(name: "resolution", value: "QUARTER_HOUR")])
    }

    @Test
    func siteTelemetrySendsPeriodInUTC() {
        let endpoint = SiteInverterTelemetryEndpoint(
            siteID: 93082,
            from: Date(timeIntervalSince1970: 1_790_812_800),
            to: Date(timeIntervalSince1970: 1_790_899_200),
            resolution: .day
        )

        #expect(endpoint.path == "sites/93082/inverters/telemetry")
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-02T00:00:00Z"),
            URLQueryItem(name: "resolution", value: "DAY"),
        ])
    }

    /// Fails before any request is made, so no network is needed.
    @Test(arguments: ["", "7E12/34", "7E12,34"])
    func rejectsInvalidSerialNumber(_ serialNumber: String) async {
        let inverters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inverters

        await #expect(throws: SolarEdgeError.self) {
            try await inverters.telemetry(for: 93082, serialNumbers: [serialNumber])
        }
    }

    /// Fails before any request is made, so no network is needed.
    @Test
    func rejectsPeriodLongerThanAllowed() async {
        let inverters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inverters
        let from = Date(timeIntervalSince1970: 1_790_812_800)

        await #expect(throws: SolarEdgeError.self) {
            try await inverters.telemetry(for: 93082, from: from, to: from.addingTimeInterval(13 * 3600))
        }
    }
}
