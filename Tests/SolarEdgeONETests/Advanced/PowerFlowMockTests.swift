import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock of the Advanced Monitoring API.
/// Needs network access.
@Suite(.tags(.mockServer))
struct PowerFlowMockTests {
    let advanced = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.advancedBaseURL).advanced

    @Test
    func powerFlowDecodesExample() async throws {
        let flow = try await advanced.powerFlow(for: 93082)

        #expect(flow.unit == .kiloWatt)
        #expect(flow.refreshRate == 300)
        #expect(flow.storage.status == .discharge)
        #expect(flow.storage.chargeLevel == 96)
        #expect(flow.grid.status == .import)
    }

    /// The mock answers with a body generated from the schema (placeholder values).
    @Test
    func startLivePowerFlowIsAccepted() async throws {
        let start = try await advanced.startLivePowerFlow(for: 93082)

        #expect(start?.status == "string")
    }

    @Test
    func powerFlowAcceptsBearerToken() async throws {
        let advanced = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.advancedBaseURL
        ).advanced

        _ = try await advanced.powerFlow(for: 93082)
        _ = try await advanced.startLivePowerFlow(for: 93082)
    }
}
