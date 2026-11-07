import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
///
/// The spec has no examples for the seven metric endpoints, so the mock
/// generates a response from the shared `Measurements` schema and always
/// sends `unit: "W"`. Power and consumed AC power decode; for the other
/// metrics a typed client rightly rejects `W`, so those tests only check
/// that the mock accepted the request (no HTTP error).
@Suite(.tags(.mockServer))
struct InverterMeasurementMockTests {
    let inverters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inverters
    let serialNumber = "7E1234B5-67"
    let to = Date()
    var from: Date { to.addingTimeInterval(-6 * 3600) }

    @Test(arguments: Monitoring.IntradayResolution.allCases, [Monitoring.Power.watt, .kiloWatt, .megaWatt])
    func powerDecodes(resolution: Monitoring.IntradayResolution, unit: Monitoring.Power) async throws {
        let power = try await inverters.power(for: 93082, serialNumber: serialNumber, from: from, to: to, resolution: resolution, unit: unit)
        let consumed = try await inverters.consumedAcPower(for: 93082, serialNumber: serialNumber, from: from, to: to, resolution: resolution, unit: unit)

        #expect(power.unit == .watt)
        #expect(consumed.unit == .watt)
    }

    @Test(arguments: Monitoring.Resolution.allCases)
    func energyRequestsAreAccepted(resolution: Monitoring.Resolution) async {
        await expectAcceptedByMock(allowing: .placeholderUnit) { try await inverters.energy(for: 93082, serialNumber: serialNumber, from: from, to: to, resolution: resolution, unit: .kiloWattHour) }
        await expectAcceptedByMock(allowing: .placeholderUnit) { try await inverters.consumedAcEnergy(for: 93082, serialNumber: serialNumber, from: from, to: to, resolution: resolution, unit: .megaWattHour) }
    }

    @Test(arguments: Monitoring.IntradayResolution.allCases)
    func gridRequestsAreAccepted(resolution: Monitoring.IntradayResolution) async {
        await expectAcceptedByMock(allowing: .placeholderUnit) { try await inverters.voltage(for: 93082, serialNumber: serialNumber, from: from, to: to, resolution: resolution) }
        await expectAcceptedByMock(allowing: .placeholderUnit) { try await inverters.current(for: 93082, serialNumber: serialNumber, from: from, to: to, resolution: resolution) }
        await expectAcceptedByMock(allowing: .placeholderUnit) { try await inverters.frequency(for: 93082, serialNumber: serialNumber, from: from, to: to, resolution: resolution) }
    }

    @Test
    func lifetimeEnergyDecodesExamples() async throws {
        let single = try await inverters.lifetimeEnergy(for: 93082, serialNumber: serialNumber, from: from, to: to)
        let site = try await inverters.lifetimeEnergy(for: 93082, from: from, to: to)

        #expect(single.values.map(\.value) == [48341, 48343.5])
        #expect(site.map(\.serialNumber) == ["7E1234B5-67", "7E1234B5-68"])
        #expect(site[1].values.isEmpty)
    }

    @Test
    func measurementsAcceptBearerToken() async throws {
        let inverters = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).inverters

        _ = try await inverters.power(for: 93082, serialNumber: serialNumber)
    }
}
