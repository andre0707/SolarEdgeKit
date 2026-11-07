import Testing
import SolarEdgeONE

struct SitePageTests {

    func page(_ page: Int, pageSize: Int = 2, sites: Int, totalCount: Int?) -> Monitoring.SitePage {
        let site = Monitoring.Site(id: 1, name: "", peakPower: 0, installationDate: CalendarDate(year: 2026, month: 1, day: 1)!,
                        location: Monitoring.Location(address: "", city: "", state: "", zip: nil, country: ""),
                        activationStatus: .active, note: "")
        return Monitoring.SitePage(sites: Array(repeating: site, count: sites), page: page, pageSize: pageSize, totalCount: totalCount)
    }

    @Test
    func usesTotalCountWhenKnown() {
        #expect(page(1, sites: 2, totalCount: 5).mayHaveMore)
        #expect(page(2, sites: 2, totalCount: 5).mayHaveMore)
        #expect(!page(3, sites: 1, totalCount: 5).mayHaveMore)
    }

    /// The case `totalCount` exists for: a full last page needs no extra request.
    @Test
    func fullLastPageHasNoMore() {
        #expect(!page(2, sites: 2, totalCount: 4).mayHaveMore)
    }

    @Test
    func fallsBackToPageSizeWithoutTotalCount() {
        #expect(page(1, sites: 2, totalCount: nil).mayHaveMore)
        #expect(!page(1, sites: 1, totalCount: nil).mayHaveMore)
    }
}

/// `Site`, `SiteDetails` and `Alert` are `Identifiable`, e.g. for SwiftUI lists.
struct IdentifiableEntityTests {

    func id<T: Identifiable>(of value: T) -> T.ID { value.id }

    @Test
    func entitiesAreIdentifiedByTheirTypedIDs() {
        let site = Monitoring.Site(id: 93082, name: "", peakPower: 0, installationDate: CalendarDate(year: 2026, month: 1, day: 1)!,
                                   location: Monitoring.Location(address: "", city: "", state: "", zip: nil, country: ""),
                                   activationStatus: .active, note: "")

        #expect(id(of: site) == 93082)
        #expect(Monitoring.Alert.ID(integerLiteral: 7).description == "7")
    }
}
