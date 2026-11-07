import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct BatteryEndpointTests {
    let from = Date(timeIntervalSince1970: 1_790_812_800)    // 2026-10-01T00:00:00Z
    let batteries = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).batteries

    @Test
    func siteAndSpecificPaths() {
        #expect(StorageTelemetryEndpoint(siteID: 1, serialNumbers: [], from: nil, to: nil, resolution: .day).path == "sites/1/storage/telemetry")
        #expect(StorageTelemetryEndpoint(siteID: 1, serialNumbers: ["A", "B"], from: nil, to: nil, resolution: .day).path == "sites/1/storage/A,B/telemetry")
        #expect(StorageStatusEndpoint(siteID: 1, serialNumbers: [], from: nil, to: nil).path == "sites/1/storage/status")
        #expect(StorageStatusEndpoint(siteID: 1, serialNumbers: ["A"], from: nil, to: nil).path == "sites/1/storage/A/status")
        #expect(StorageLifetimeEnergyEndpoint(siteID: 1, serialNumbers: [], from: from, to: from).path == "sites/1/storage/lifetime-energy")
        #expect(StorageLifetimeEnergyEndpoint(siteID: 1, serialNumbers: ["A", "B"], from: from, to: from).path == "sites/1/storage/A,B/lifetime-energy")
    }

    @Test
    func queries() {
        let telemetry = StorageTelemetryEndpoint(siteID: 1, serialNumbers: [], from: from, to: from, resolution: .day)
        let status = StorageStatusEndpoint(siteID: 1, serialNumbers: [], from: nil, to: nil)

        #expect(telemetry.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(telemetry.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "resolution", value: "DAY"),
        ])
        // Status supports only a quarter hour, so no resolution is sent.
        #expect(status.queryItems.isEmpty)
    }

    @Test(arguments: [
        (BatteryMetricEndpoint.Metric.chargePower, "charge-power"),
        (.dischargePower, "discharge-power"),
        (.chargeEnergy, "charge-energy"),
        (.dischargeEnergy, "discharge-energy"),
        (.stateOfEnergy, "state-of-energy"),
        (.remainingEnergy, "remaining-energy"),
    ])
    func metricPaths(metric: BatteryMetricEndpoint.Metric, component: String) {
        let endpoint = BatteryMetricEndpoint(siteID: 93082, serialNumber: "BATT-001", metric: metric,
                                             from: nil, to: nil, resolution: .hour, unit: "PERCENTAGE_100")

        #expect(endpoint.path == "sites/93082/storage/BATT-001/\(component)")
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "resolution", value: "HOUR"),
            URLQueryItem(name: "unit", value: "PERCENTAGE_100"),
        ])
    }

    // MARK: Rejected before any request is made, so no network is needed.

    @Test
    func rejectsInvalidSerialNumbers() async {
        await #expect(throws: SolarEdgeError.self) { try await batteries.telemetry(for: 1, serialNumbers: ["A,B"]) }
        await #expect(throws: SolarEdgeError.self) { try await batteries.status(for: 1, serialNumbers: [""]) }
        await #expect(throws: SolarEdgeError.self) { try await batteries.chargePower(for: 1, serialNumber: "A/B") }
    }

    @Test
    func rejectsGigaWattHour() async {
        await #expect(throws: SolarEdgeError.self) {
            try await batteries.remainingEnergy(for: 1, serialNumber: "BATT-001", unit: .gigaWattHour)
        }
    }

    @Test(arguments: [7 * 24 * 3600 + 1, -1] as [TimeInterval])
    func statusRejectsInvalidPeriod(_ span: TimeInterval) async {
        await #expect(throws: SolarEdgeError.self) {
            try await batteries.status(for: 1, from: from, to: from.addingTimeInterval(span))
        }
    }

    @Test(arguments: [0, 7 * 24 * 3600 + 1] as [TimeInterval])
    func lifetimeRejectsInvalidPeriod(_ span: TimeInterval) async {
        await #expect(throws: SolarEdgeError.self) {
            try await batteries.lifetimeEnergy(for: 1, from: from, to: from.addingTimeInterval(span))
        }
    }

    @Test
    func metricsRejectPeriodLongerThanAllowed() async {
        await #expect(throws: SolarEdgeError.self) {
            try await batteries.stateOfEnergy(for: 1, serialNumber: "BATT-001", from: from, to: from.addingTimeInterval(13 * 3600))
        }
    }
}
