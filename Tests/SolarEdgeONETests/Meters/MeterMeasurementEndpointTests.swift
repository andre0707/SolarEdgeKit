import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct MeterMeasurementEndpointTests {
    let from = Date(timeIntervalSince1970: 1_790_812_800)    // 2026-10-01T00:00:00Z
    let meters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).meters

    @Test(arguments: [
        (MeterMetricEndpoint.Metric.productionPower, "production-power"),
        (.productionEnergy, "production-energy"),
        (.consumptionPower, "consumption-power"),
        (.consumptionEnergy, "consumption-energy"),
        (.importPower, "import-power"),
        (.importEnergy, "import-energy"),
        (.exportPower, "export-power"),
        (.exportEnergy, "export-energy"),
    ])
    func metricPaths(metric: MeterMetricEndpoint.Metric, component: String) {
        let endpoint = MeterMetricEndpoint(siteID: 93082, serialNumber: "M-1", metric: metric,
                                           from: nil, to: nil, resolution: .hour, unit: "KW")

        #expect(endpoint.path == "sites/93082/meters/M-1/\(component)")
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(endpoint.queryItems == [
            URLQueryItem(name: "resolution", value: "HOUR"),
            URLQueryItem(name: "unit", value: "KW"),
        ])
    }

    @Test
    func lifetimePathsAndFilter() {
        let site = MeterLifetimeEnergyEndpoint(siteID: 93082, serialNumbers: [], directions: [], from: from, to: from)
        let specific = MeterLifetimeEnergyEndpoint(siteID: 93082, serialNumbers: ["M-1", "M-2"],
                                                   directions: [.export, .production, .import], from: from, to: from)

        #expect(site.path == "sites/93082/meters/lifetime-energy")
        #expect(site.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-01T00:00:00Z"),
        ])
        #expect(specific.path == "sites/93082/meters/M-1,M-2/lifetime-energy")
        // Stable order, and the API's main names for import and export.
        #expect(specific.queryItems.last == URLQueryItem(name: "meters", value: "PRODUCTION,PURCHASED,FEEDIN"))
    }

    // MARK: Rejected before any request is made, so no network is needed.

    @Test
    func rejectsInvalidSerialNumber() async {
        await #expect(throws: SolarEdgeError.self) {
            try await meters.importPower(for: 93082, serialNumber: "M/1")
        }
    }

    @Test
    func rejectsGigaWattHour() async {
        await #expect(throws: SolarEdgeError.self) {
            try await meters.exportEnergy(for: 93082, serialNumber: "M-1", unit: .gigaWattHour)
        }
    }

    @Test
    func rejectsPeriodLongerThanAllowed() async {
        await #expect(throws: SolarEdgeError.self) {
            try await meters.productionPower(for: 93082, serialNumber: "M-1", from: from, to: from.addingTimeInterval(13 * 3600))
        }
    }

    @Test(arguments: [0, -1, 7 * 24 * 3600 + 1] as [TimeInterval])
    func rejectsInvalidLifetimePeriod(_ span: TimeInterval) async {
        await #expect(throws: SolarEdgeError.self) {
            try await meters.lifetimeEnergy(for: 93082, from: from, to: from.addingTimeInterval(span))
        }
    }
}
