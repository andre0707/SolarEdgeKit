import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock of the Advanced Monitoring API.
/// Needs network access.
@Suite(.tags(.mockServer))
struct PerDestinationMockTests {
    let advanced = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.advancedBaseURL).advanced

    @Test
    func powerPerDestinationDecodesExample() async throws {
        let result = try await advanced.powerPerDestination(for: 93082)

        #expect(result.siteID == 49212)
        #expect(result.production.unit == .kiloWatt)
        #expect(result.production.values.map(\.toGrid) == [0.07])
        #expect(result.consumption.values.map(\.fromStorage) == [10.01])
    }

    @Test
    func energyPerDestinationDecodesExample() async throws {
        let result = try await advanced.energyPerDestination(for: 93082, resolution: .day)

        #expect(result.production.unit == .kiloWattHour)
        #expect(result.production.values.map(\.toSelfConsumption) == [9.98])
        #expect(result.consumption.values.map(\.fromGrid) == [0.42])
    }

    /// The mock validates `resolution`, `from` and `to` against the spec.
    @Test(arguments: Monitoring.IntradayResolution.allCases)
    func powerAcceptsBothResolutions(_ resolution: Monitoring.IntradayResolution) async throws {
        let to = Date()
        _ = try await advanced.powerPerDestination(for: 93082, from: to.addingTimeInterval(-6 * 3600), to: to, resolution: resolution)
    }

    @Test(arguments: Monitoring.Resolution.allCases)
    func energyAcceptsEveryResolution(_ resolution: Monitoring.Resolution) async throws {
        let to = Date()
        _ = try await advanced.energyPerDestination(for: 93082, from: to.addingTimeInterval(-6 * 3600), to: to, resolution: resolution)
    }

    @Test
    func perDestinationAcceptsBearerToken() async throws {
        let advanced = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.advancedBaseURL
        ).advanced

        _ = try await advanced.powerPerDestination(for: 93082)
    }
}
