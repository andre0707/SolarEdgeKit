import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct InverterStatusMockTests {
    let inverters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inverters

    @Test
    func siteStatusDecodesExample() async throws {
        let report = try await inverters.status(for: 93082)

        // 2026-01-01T00:00:00Z to 00:30:00Z
        #expect(report.period == DateInterval(start: Date(timeIntervalSince1970: 1_767_225_600),
                                              end: Date(timeIntervalSince1970: 1_767_227_400)))
        #expect(report.resolution == .quarterHour)
        let status = try #require(report.inverters["7E1234B5-67"])
        #expect(status.inverterMode?.map(\.mode) == [.mppt, .mppt])
        #expect(status.temperature?.values.map(\.value) == [37.2, 37.5])
    }

    /// Only one serial number: the mock rejects comma-separated lists,
    /// although the spec allows them.
    @Test
    func statusForOneInverterDecodesExample() async throws {
        let report = try await inverters.status(for: 93082, serialNumbers: ["7E1234B5-67"])

        #expect(report.inverters["7E1234B5-67"]?.temperature?.values.map(\.value) == [37.2, nil])
    }

    /// The mock validates `resolution`, `from` and `to` against the spec.
    @Test(arguments: Monitoring.IntradayResolution.allCases)
    func statusAcceptsBothResolutions(_ resolution: Monitoring.IntradayResolution) async throws {
        let to = Date()

        _ = try await inverters.status(for: 93082, from: to.addingTimeInterval(-6 * 3600), to: to, resolution: resolution)
    }

    @Test
    func statusAcceptsBearerToken() async throws {
        let inverters = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).inverters

        _ = try await inverters.status(for: 93082)
    }
}
