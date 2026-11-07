import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock of the Advanced Monitoring API.
/// Needs network access.
@Suite(.tags(.mockServer))
struct SiteConfigurationMockTests {

    @Test
    func weatherGuardDecodesExample() async throws {
        let advanced = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.advancedBaseURL).advanced

        #expect(try await advanced.weatherGuard(for: 93082).isEnabled)
    }

    /// The spec has no example; the mock generates one with a placeholder percentage.
    @Test
    func backupReserveDecodesGeneratedResponse() async throws {
        let advanced = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.advancedBaseURL).advanced

        #expect(try await advanced.backupReserve(for: 93082).status == .enabled)
    }

    @Test
    func configurationAcceptsBearerToken() async throws {
        let advanced = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.advancedBaseURL
        ).advanced

        _ = try await advanced.weatherGuard(for: 93082)
        _ = try await advanced.backupReserve(for: 93082)
    }
}
