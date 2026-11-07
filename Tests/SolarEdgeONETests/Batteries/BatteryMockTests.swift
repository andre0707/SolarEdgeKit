import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
///
/// Only one serial number per request: the mock rejects comma-separated
/// lists, although the spec allows them. The spec has no examples for the
/// six metric endpoints; the mock always sends `unit: "W"`, so the power
/// metrics decode and the others are only checked for being accepted.
@Suite(.tags(.mockServer))
struct BatteryMockTests {
    let batteries = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).batteries
    let to = Date()
    var from: Date { to.addingTimeInterval(-6 * 3600) }

    @Test
    func telemetryDecodesExample() async throws {
        let site = try await batteries.telemetry(for: 93082)
        let one = try await batteries.telemetry(for: 93082, serialNumbers: ["BATT-001"])

        let battery = try #require(site["BATT-001"])
        #expect(battery.chargePower?.values.map(\.value) == [3000, 2750])
        #expect(battery.stateOfEnergy?.unit == .percentage)
        #expect(battery.stateOfEnergy?.values.map(\.value) == [65.2, 67.8])
        #expect(one["BATT-001"] == battery)
    }

    /// The mock validates `resolution`, `from` and `to` against the spec.
    @Test(arguments: Monitoring.Resolution.allCases)
    func telemetryAcceptsEveryResolution(_ resolution: Monitoring.Resolution) async throws {
        _ = try await batteries.telemetry(for: 93082, from: from, to: to, resolution: resolution)
    }

    @Test
    func statusDecodesExample() async throws {
        let report = try await batteries.status(for: 93082, from: from, to: to)

        let battery = try #require(report.batteries["BATT-001"])
        #expect(battery.batteryState?.map(\.value) == [4])
        #expect(battery.internalTemperature?.values.map(\.value) == [28.3])
        #expect(report.period != nil)
    }

    @Test
    func lifetimeEnergyDecodesExample() async throws {
        let batteries = try await batteries.lifetimeEnergy(for: 93082, serialNumbers: ["BATT-001"], from: from, to: to)

        #expect(batteries.first?.charged.map(\.value) == [2999999850, 3000000000])
        #expect(batteries.first?.discharged.map(\.value) == [2499999900, 2500000000])
    }

    @Test(arguments: Monitoring.IntradayResolution.allCases)
    func metricRequests(resolution: Monitoring.IntradayResolution) async throws {
        let charge = try await batteries.chargePower(for: 93082, serialNumber: "BATT-001", from: from, to: to, resolution: resolution)
        let discharge = try await batteries.dischargePower(for: 93082, serialNumber: "BATT-001", from: from, to: to, resolution: resolution, unit: .megaWatt)
        #expect(charge.unit == .watt)
        #expect(discharge.unit == .watt)

        let energyResolution = try #require(Monitoring.Resolution(rawValue: resolution.rawValue))
        for request in [batteries.chargeEnergy, batteries.dischargeEnergy, batteries.remainingEnergy] {
            await expectAcceptedByMock(allowing: .placeholderUnit) { try await request(93082, "BATT-001", from, to, energyResolution, .kiloWattHour) }
        }
        for unit in Monitoring.Percentage.allCases {
            await expectAcceptedByMock(allowing: .placeholderUnit) { try await batteries.stateOfEnergy(for: 93082, serialNumber: "BATT-001", from: from, to: to, resolution: resolution, unit: unit) }
        }
    }

    @Test
    func batteriesAcceptBearerToken() async throws {
        let batteries = SolarEdgeONEClient(
            credentials: .bearerToken(StaticTokenProvider(token: "123")),
            baseURL: MockServer.baseURL
        ).batteries

        _ = try await batteries.telemetry(for: 93082)
    }
}
