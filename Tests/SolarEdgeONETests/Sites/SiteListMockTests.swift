import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Sends real requests to the Stoplight mock server generated from the
/// Basic Monitoring API spec. Needs network access.
@Suite(.tags(.mockServer))
struct SiteListMockTests {
    let sites = MockServer.sitesService()

    @Test
    func listDecodesExampleSite() async throws {
        let page = try await sites.list()

        #expect(page.page == 1)
        #expect(page.pageSize == 50)
        // The mock sends count = Int32.min, which cannot be a total.
        #expect(page.totalCount == nil)
        #expect(!page.mayHaveMore)

        let site = try #require(page.sites.first)
        #expect(site.id == 93082)
        #expect(site.name == "Smith, John CRM1234")
        #expect(site.peakPower == 6.14)
        #expect(site.installationDate == CalendarDate(year: 2026, month: 3, day: 10))
        #expect(site.location.address == "2888 Main St")
        #expect(site.location.city == "Green Bay")
        #expect(site.location.state == "Wisconsin")
        #expect(site.location.zip == "54311")
        #expect(site.location.country == "United States")
        #expect(site.activationStatus == .active)
        #expect(site.note == "Created via API, triggered from CRM")
    }

    /// The mock validates query parameters against the spec, so this checks
    /// that every filter is sent with the expected name and format.
    @Test
    func listAcceptsAllFilters() async throws {
        let filter = Monitoring.SiteFilter(
            name: "Smith",
            city: "Green Bay",
            state: "WI",
            group: UUID(uuidString: "3F2504E0-4F89-11D3-9A0C-0305E82C3301")
        )

        let page = try await sites.list(filter: filter, page: 2, pageSize: 10)

        #expect(page.page == 2)
        #expect(page.pageSize == 10)
    }
}
