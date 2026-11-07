import Testing
import Foundation
import SolarEdgeONE

/// Sends real requests to the Stoplight mock server. Needs network access.
@Suite(.tags(.mockServer))
struct FleetAlertsMockTests {
    let alerts = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL).alerts

    @Test
    func fleetAlertsDecodeExample() async throws {
        let page = try await alerts.list()

        let alert = try #require(page.alerts.first)
        #expect(alert.id == 112957209)
        #expect(alert.siteID == 2112736)
        #expect(alert.category == "EQUIPMENT")
        #expect(alert.type == "DC Isolation")
        #expect(alert.impact == 7)
        #expect(alert.status == .open)
        // 2026-09-28 23:07:18 and 2026-10-05 13:05:00, read as UTC
        #expect(alert.firstTrigger == Date(timeIntervalSince1970: 1_790_636_838))
        #expect(alert.lastTrigger == Date(timeIntervalSince1970: 1_790_636_838))
        #expect(alert.closeDate == Date(timeIntervalSince1970: 1_791_205_500))
        #expect(alert.muteExpirationDate == Date(timeIntervalSince1970: 1_791_205_500))
        #expect(alert.component == Monitoring.AlertComponent(name: "Inverter 2", serialNumber: "BE1002D3-A3"))
        #expect(alert.errorCodes == ["1800x105"])
    }

    /// The mock validates every query parameter against the spec.
    @Test
    func fleetAlertsAcceptAllFilters() async throws {
        let filter = Monitoring.AlertFilter(
            group: UUID(uuidString: "3F2504E0-4F89-11D3-9A0C-0305E82C3301"),
            type: "DC Isolation",
            state: "WI",
            city: "Green Bay"
        )

        _ = try await alerts.list(filter: filter, page: 2, pageSize: 100, onlyOpen: false)
    }
}
