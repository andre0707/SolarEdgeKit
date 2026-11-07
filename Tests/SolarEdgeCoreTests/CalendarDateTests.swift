import Testing
@testable import SolarEdgeCore
import Foundation

struct CalendarDateTests {

    @Test(arguments: [
        "2026-03-10",
        "2026-03-10T00:00:00Z",
        "2026-03-10T23:59:59+03:00",
        "2026-03-10t08:00:00Z",
        "2026-03-10 08:00:00",
    ])
    func parsesDateAndIgnoresTime(_ input: String) throws {
        let date = try #require(CalendarDate(isoString: input))

        #expect(date.year == 2026)
        #expect(date.month == 3)
        #expect(date.day == 10)
    }

    @Test(arguments: [
        "",
        "2026-03",
        "2026-3-10",
        "26-03-10",
        "2026/03/10",
        "2026-13-10",
        "2026-00-10",
        "2026-03-32",
        "2026-03-00",
        "2026-03-1012",
        "2026-03-10Z",
        "2026-03-10garbage",
        "abcd-ef-gh",
        "+026-03-10",
        "2026-+3-10",
        "2026-02-29",
        "2026-02-30",
        "2026-04-31",
        "1900-02-29",
    ])
    func rejectsMalformedInput(_ input: String) {
        #expect(CalendarDate(isoString: input) == nil)
    }

    @Test(arguments: ["2024-02-29", "2000-02-29", "2026-01-31", "2026-04-30", "2026-12-31"])
    func acceptsTheLastDayOfEachMonth(_ input: String) {
        #expect(CalendarDate(isoString: input) != nil)
    }

    /// `startOfDay(in:)` would otherwise roll February 31 over into March.
    @Test
    func rejectsDaysThatDoNotExist() {
        #expect(CalendarDate(year: 2026, month: 2, day: 31) == nil)
        #expect(CalendarDate(year: 2026, month: 2, day: 28) != nil)
        #expect(CalendarDate(year: 2028, month: 2, day: 29) != nil)
    }

    @Test
    func descriptionRoundTrips() throws {
        let date = try #require(CalendarDate(isoString: "2026-03-10T00:00:00Z"))

        #expect(date.description == "2026-03-10")
        #expect(CalendarDate(isoString: date.description) == date)
    }

    @Test
    func comparesChronologically() throws {
        let earlier = try #require(CalendarDate(year: 2025, month: 12, day: 31))
        let later = try #require(CalendarDate(year: 2026, month: 1, day: 1))

        #expect(earlier < later)
    }

    /// The same calendar day starts at different instants depending on the time zone.
    @Test
    func startOfDayUsesGivenTimeZone() throws {
        let date = try #require(CalendarDate(isoString: "2026-03-10"))
        let utcZone = try #require(TimeZone(identifier: "UTC"))
        let chicagoZone = try #require(TimeZone(identifier: "America/Chicago"))
        let utc = try #require(date.startOfDay(in: utcZone))
        let chicago = try #require(date.startOfDay(in: chicagoZone))

        // Chicago is on daylight saving time (UTC-5) by March 10, 2026.
        #expect(chicago.timeIntervalSince(utc) == 5 * 3600)
    }
}
