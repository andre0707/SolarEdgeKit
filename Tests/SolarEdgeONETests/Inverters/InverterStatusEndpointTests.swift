import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct InverterStatusEndpointTests {
    let from = Date(timeIntervalSince1970: 1_790_812_800)    // 2026-10-01T00:00:00Z
    let inverters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inverters

    @Test
    func paths() {
        let specific = InverterStatusEndpoint(siteID: 93082, serialNumbers: ["A-1", "B-2"], from: nil, to: nil, resolution: .hour)
        let site = SiteInverterStatusEndpoint(siteID: 93082, from: from, to: from, resolution: .quarterHour)

        #expect(specific.path == "sites/93082/inverters/A-1,B-2/status")
        #expect(specific.queryItems == [URLQueryItem(name: "resolution", value: "HOUR")])
        #expect(site.path == "sites/93082/inverters/status")
        #expect(site.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(site.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "resolution", value: "QUARTER_HOUR"),
        ])
    }

    /// Fails before any request is made, so no network is needed.
    @Test(arguments: [
        (Monitoring.IntradayResolution.quarterHour, 7 * 24 * 3600 + 1),
        (.hour, 24 * 3600 + 1),
        (.quarterHour, -1),
    ] as [(Monitoring.IntradayResolution, TimeInterval)])
    func rejectsInvalidPeriod(resolution: Monitoring.IntradayResolution, span: TimeInterval) async {
        await #expect(throws: SolarEdgeError.self) {
            try await inverters.status(for: 93082, from: from, to: from.addingTimeInterval(span), resolution: resolution)
        }
    }

    /// Unlike the measurement endpoints, a week at a quarter hour is fine.
    @Test(arguments: [
        (Monitoring.IntradayResolution.quarterHour, 7 * 24 * 3600),
        (.hour, 24 * 3600),
        (.quarterHour, 0),
    ] as [(Monitoring.IntradayResolution, TimeInterval)])
    func acceptsTheMaximumSpan(resolution: Monitoring.IntradayResolution, span: TimeInterval) throws {
        try InvertersService.validateStatusPeriod(from: from, to: from.addingTimeInterval(span), resolution: resolution)
    }
}
