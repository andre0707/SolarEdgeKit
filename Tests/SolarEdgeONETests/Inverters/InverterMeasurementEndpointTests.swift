import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct InverterMeasurementEndpointTests {
    let from = Date(timeIntervalSince1970: 1_790_812_800)    // 2026-10-01T00:00:00Z
    let inverters = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).inverters

    @Test(arguments: [
        (InverterMetricEndpoint.Metric.power, "power"),
        (.energy, "energy"),
        (.consumedAcPower, "consumed-ac-power"),
        (.consumedAcEnergy, "consumed-ac-energy"),
        (.voltage, "voltage"),
        (.current, "current"),
        (.frequency, "frequency"),
    ])
    func metricPaths(metric: InverterMetricEndpoint.Metric, component: String) {
        let endpoint = InverterMetricEndpoint(siteID: 93082, serialNumber: "7E1234B5-67", metric: metric,
                                              from: nil, to: nil, resolution: .hour, unit: nil)

        #expect(endpoint.path == "sites/93082/inverters/7E1234B5-67/\(component)")
        #expect(endpoint.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(endpoint.queryItems == [URLQueryItem(name: "resolution", value: "HOUR")])
    }

    @Test
    func metricSendsPeriodAndUnit() {
        let endpoint = InverterMetricEndpoint(siteID: 93082, serialNumber: "7E1234B5-67", metric: .energy,
                                              from: from, to: from.addingTimeInterval(24 * 3600),
                                              resolution: .day, unit: "KWH")

        #expect(endpoint.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-02T00:00:00Z"),
            URLQueryItem(name: "resolution", value: "DAY"),
            URLQueryItem(name: "unit", value: "KWH"),
        ])
    }

    @Test
    func lifetimePaths() {
        let single = InverterLifetimeEnergyEndpoint(siteID: 93082, serialNumber: "7E1234B5-67", from: from, to: from)
        let site = SiteInverterLifetimeEnergyEndpoint(siteID: 93082, from: from, to: from)

        #expect(single.path == "sites/93082/inverters/7E1234B5-67/lifetime-energy")
        #expect(site.path == "sites/93082/inverters/lifetime-energy")
        #expect(site.queryItems == [
            URLQueryItem(name: "from", value: "2026-10-01T00:00:00Z"),
            URLQueryItem(name: "to", value: "2026-10-01T00:00:00Z"),
        ])
    }

    // MARK: Rejected before any request is made, so no network is needed.

    @Test
    func rejectsInvalidSerialNumber() async {
        await #expect(throws: SolarEdgeError.self) {
            try await inverters.power(for: 93082, serialNumber: "7E12/34")
        }
    }

    @Test
    func rejectsGigaWattHour() async {
        await #expect(throws: SolarEdgeError.self) {
            try await inverters.energy(for: 93082, serialNumber: "7E1234B5-67", unit: .gigaWattHour)
        }
        await #expect(throws: SolarEdgeError.self) {
            try await inverters.consumedAcEnergy(for: 93082, serialNumber: "7E1234B5-67", unit: .gigaWattHour)
        }
    }

    @Test
    func rejectsPeriodLongerThanAllowed() async {
        await #expect(throws: SolarEdgeError.self) {
            try await inverters.voltage(for: 93082, serialNumber: "7E1234B5-67", from: from, to: from.addingTimeInterval(13 * 3600))
        }
    }

    @Test(arguments: [0, -1, 7 * 24 * 3600 + 1] as [TimeInterval])
    func rejectsInvalidLifetimePeriod(_ span: TimeInterval) async {
        await #expect(throws: SolarEdgeError.self) {
            try await inverters.lifetimeEnergy(for: 93082, from: from, to: from.addingTimeInterval(span))
        }
        await #expect(throws: SolarEdgeError.self) {
            try await inverters.lifetimeEnergy(for: 93082, serialNumber: "7E1234B5-67", from: from, to: from.addingTimeInterval(span))
        }
    }
}
