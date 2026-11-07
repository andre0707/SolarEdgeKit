import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct MeterTelemetryEndpointTests {
    let from = Date(timeIntervalSince1970: 1_790_812_800)    // 2026-10-01T00:00:00Z
    let meters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).meters

    @Test
    func paths() {
        let specific = MeterTelemetryEndpoint(siteID: 93082, serialNumbers: ["M-1", "M-2"], from: nil, to: nil, resolution: .hour)
        let site = SiteMeterTelemetryEndpoint(siteID: 93082, from: from, to: from.addingTimeInterval(24 * 3600), resolution: .day)

        #expect(specific.path == "sites/93082/meters/M-1,M-2/telemetry")
        #expect(specific.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(specific.queryItems == [URLQueryItem(name: "resolution", value: "HOUR")])
        #expect(site.path == "sites/93082/meters/telemetry")
        #expect(site.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-02T00:00:00Z"),
            URLQueryItem(name: "resolution", value: "DAY"),
        ])
    }

    /// Fails before any request is made, so no network is needed.
    @Test(arguments: ["", "M/1", "M,1"])
    func rejectsInvalidSerialNumber(_ serialNumber: String) async {
        await #expect(throws: SolarEdgeError.self) {
            try await meters.telemetry(for: 93082, serialNumbers: [serialNumber])
        }
    }

    /// Fails before any request is made, so no network is needed.
    @Test
    func rejectsPeriodLongerThanAllowed() async {
        await #expect(throws: SolarEdgeError.self) {
            try await meters.telemetry(for: 93082, from: from, to: from.addingTimeInterval(32 * 24 * 3600), resolution: .day)
        }
    }
}
