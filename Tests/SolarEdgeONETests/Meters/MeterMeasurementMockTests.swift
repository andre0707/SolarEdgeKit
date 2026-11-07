import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
///
/// The spec has no examples for the eight metric endpoints, so the mock
/// generates a response from the shared `Measurements` schema and always
/// sends `unit: "W"`. The power metrics decode; for the energy metrics a
/// typed client rightly rejects `W`, so those tests only check that the
/// mock accepted the request (no HTTP error).
@Suite(.tags(.mockServer))
struct MeterMeasurementMockTests {
    let meters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).meters
    let serialNumber = "M-1"
    let to = Date()
    var from: Date { to.addingTimeInterval(-6 * 3600) }

    @Test(arguments: Monitoring.IntradayResolution.allCases)
    func powerMetricsDecode(resolution: Monitoring.IntradayResolution) async throws {
        for request in [meters.productionPower, meters.consumptionPower, meters.importPower, meters.exportPower] {
            let power = try await request(93082, serialNumber, from, to, resolution, .kiloWatt)
            #expect(power.unit == .watt)
        }
    }

    @Test(arguments: Monitoring.Resolution.allCases)
    func energyRequestsAreAccepted(resolution: Monitoring.Resolution) async {
        for request in [meters.productionEnergy, meters.consumptionEnergy, meters.importEnergy, meters.exportEnergy] {
            await expectAcceptedByMock(allowing: .placeholderUnit) { try await request(93082, serialNumber, from, to, resolution, .kiloWattHour) }
        }
    }

    @Test
    func lifetimeEnergyDecodesExamples() async throws {
        let site = try await meters.lifetimeEnergy(for: 93082, from: from, to: to)
        let specific = try await meters.lifetimeEnergy(for: 93082, serialNumbers: ["2644513869"],
                                                       directions: Set(Monitoring.MeterDirection.allCases), from: from, to: to)

        #expect(site.map(\.serialNumber) == ["2644513869", "617887617"])
        #expect(specific.first?.importEnergy.map(\.value) == [4489559, 4489617])
    }

    @Test
    func measurementsAcceptBearerToken() async throws {
        let meters = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).meters

        _ = try await meters.productionPower(for: 93082, serialNumber: serialNumber)
    }
}
