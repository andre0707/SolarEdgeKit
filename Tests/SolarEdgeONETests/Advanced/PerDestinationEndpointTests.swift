import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct PerDestinationEndpointTests {
    let from = Date(timeIntervalSince1970: 1_790_812_800)    // 2026-10-01T00:00:00Z
    let advanced = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.advancedBaseURL).advanced

    @Test
    func paths() {
        let power = PowerPerDestinationEndpoint(siteID: 93082, from: nil, to: nil, resolution: .hour)
        let energy = EnergyPerDestinationEndpoint(siteID: 93082, from: from, to: from.addingTimeInterval(24 * 3600), resolution: .day)

        #expect(power.path == "sites/93082/power/per-destination")
        #expect(power.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(power.queryItems == [URLQueryItem(name: "resolution", value: "HOUR")])
        #expect(energy.path == "sites/93082/energy/per-destination")
        #expect(energy.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-02T00:00:00Z"),
            URLQueryItem(name: "resolution", value: "DAY"),
        ])
    }

    /// Fails before any request is made, so no network is needed.
    @Test
    func rejectsPeriodsLongerThanAllowed() async {
        await #expect(throws: SolarEdgeError.self) {
            try await advanced.powerPerDestination(for: 93082, from: from, to: from.addingTimeInterval(13 * 3600))
        }
        await #expect(throws: SolarEdgeError.self) {
            try await advanced.energyPerDestination(for: 93082, from: from, to: from.addingTimeInterval(32 * 24 * 3600), resolution: .day)
        }
    }
}
