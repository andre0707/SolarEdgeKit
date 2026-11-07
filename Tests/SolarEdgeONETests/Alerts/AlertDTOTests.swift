import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Decodes the Fleet Alerts example from the spec, which has every field.
struct AlertDTOTests {

    func dto(firstTrigger: String = "2026-09-28 23:07:18", status: String = "OPEN") throws -> AlertDTO {
        let json = """
        {"alertId":112957209,"siteId":2112736,"category":"EQUIPMENT","type":"DC Isolation","impact":7,"status":"\(status)",
         "firstTrigger":"\(firstTrigger)","lastTrigger":"2026-09-28 23:07:18",
         "closeDate":"2026-10-05 13:05:00","muteExpirationDate":"2026-10-05 13:05:00",
         "component":{"name":"Inverter 2","serialNumber":"BE1002D3-A3"},"errorCodes":["1800x105"]}
        """
        return try JSONDecoder().decode(AlertDTO.self, from: Data(json.utf8))
    }

    @Test
    func mapsTheSpecExample() throws {
        let alert = try dto().entity

        #expect(alert.id == 112957209)
        #expect(alert.siteID == 2112736)
        #expect(alert.category == "EQUIPMENT")
        #expect(alert.type == "DC Isolation")
        #expect(alert.impact == 7)
        #expect(alert.status == .open)
        // Without an offset, the time is read as UTC.
        #expect(alert.firstTrigger == Date(timeIntervalSince1970: 1_790_636_838))
        #expect(alert.closeDate == Date(timeIntervalSince1970: 1_791_205_500))
        #expect(alert.component == Monitoring.AlertComponent(name: "Inverter 2", serialNumber: "BE1002D3-A3"))
        #expect(alert.errorCodes == ["1800x105"])
    }

    @Test
    func acceptsTheDeclaredOffsetFormat() throws {
        let alert = try dto(firstTrigger: "2026-10-01T13:30:00+03:00").entity

        #expect(alert.firstTrigger == Date(timeIntervalSince1970: 1_790_850_600))
    }

    /// Without an offset, alert dates are read as UTC, with a space or a `T`.
    @Test(arguments: ["2026-09-28 23:07:18", "2026-09-28T23:07:18"])
    func readsDatesWithoutOffsetAsUTC(_ value: String) throws {
        let alert = try dto(firstTrigger: value).entity

        #expect(alert.firstTrigger == Date(timeIntervalSince1970: 1_790_636_838))
    }

    @Test(arguments: ["2026-09-28", "28.09.2026 23:07", "yesterday"])
    func rejectsUnreadableDates(_ value: String) throws {
        let dto = try dto(firstTrigger: value)

        #expect(throws: SolarEdgeError.self) { try dto.entity }
    }

    /// A status added on the server is kept, not a decoding error.
    @Test
    func keepsUnknownStatus() throws {
        #expect(try dto(status: "MUTED").entity.status == .unknown("MUTED"))
    }
}
