import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Decodes Site Details offline: the spec's example, completed with the
/// location fields it leaves out.
struct SiteDetailsDTOTests {

    func json(location: String) -> String {
        """
        {"siteId":93082,"name":"Smith, John CRM1234","accountId":123456,"peakPower":6.14,
         "installationDate":"2026-03-10","lastUpdateTime":"2026-10-08T09:30:00+03:00",
         "location":\(location),
         "activationStatus":"ACTIVE","note":"Created via API, triggered from CRM"}
        """
    }

    func location(timezone: String = "America/Chicago") -> String {
        """
        {"address":"2888 Main St","address2":null,"latitude":44.5133,"longitude":-88.0133,
         "city":"Green Bay","state":"Wisconsin","stateCode":"WI","zip":"54311",
         "country":"United States","countryCode":"US","timezone":"\(timezone)"}
        """
    }

    func decode(_ json: String) throws -> Monitoring.SiteDetails {
        try JSONDecoder().decode(SiteMetadataExtendedDTO.self, from: Data(json.utf8)).entity
    }

    @Test
    func mapsTheCompletedExample() throws {
        let details = try decode(json(location: location()))

        #expect(details.id == 93082)
        #expect(details.name == "Smith, John CRM1234")
        #expect(details.accountID == 123456)
        #expect(details.peakPower == 6.14)
        #expect(details.installationDate == CalendarDate(year: 2026, month: 3, day: 10))
        // 2026-10-08T09:30:00+03:00
        #expect(details.lastUpdateTime == Date(timeIntervalSince1970: 1_791_441_000))
        #expect(details.activationStatus == .active)
        #expect(details.note == "Created via API, triggered from CRM")

        let location = details.location
        #expect(location.address == "2888 Main St")
        #expect(location.address2 == nil)
        #expect(location.latitude == 44.5133)
        #expect(location.longitude == -88.0133)
        #expect(location.city == "Green Bay")
        #expect(location.stateCode == "WI")
        #expect(location.zip == "54311")
        #expect(location.countryCode == "US")
        #expect(location.timezone == TimeZone(identifier: "America/Chicago"))
    }

    /// An identifier `TimeZone` does not know becomes `nil`, not the device's zone.
    @Test
    func unknownTimeZoneBecomesNil() throws {
        let details = try decode(json(location: location(timezone: "Mars/Olympus_Mons")))

        #expect(details.location.timezone == nil)
    }

    /// The location fields are required, as the spec does not mark them optional.
    @Test
    func rejectsTheSpecExampleWithoutLocationFields() {
        let incomplete = """
        {"address":"2888 Main St","city":"Green Bay","state":"Wisconsin","zip":"54311","country":"United States"}
        """

        #expect(throws: DecodingError.self) { try decode(json(location: incomplete)) }
    }
}
