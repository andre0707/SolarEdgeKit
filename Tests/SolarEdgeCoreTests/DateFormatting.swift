import Testing
@testable import SolarEdgeCore
import Foundation

struct DateFormattingTests {

    @Test(arguments: [
        ("2026-10-08T09:30:00Z", 1_791_451_800.0),
        ("2026-10-08T09:30:00+03:00", 1_791_441_000.0),
        ("2026-10-08T09:30:00.5Z", 1_791_451_800.5),
        ("2026-10-08T09:30:00.500+02:00", 1_791_444_600.5),
    ])
    func parsesOffsetsAndFractionalSeconds(_ input: String, _ expected: TimeInterval) throws {
        let date = try #require(DateFormatter.iso8601FormattedDate(from: input))

        #expect(abs(date.timeIntervalSince1970 - expected) < 0.001)
    }

    /// The Advanced spec's example has nanoseconds.
    @Test
    func parsesNanoseconds() throws {
        let date = try #require(DateFormatter.iso8601FormattedDate(from: "2022-11-14T11:30:54.276805300Z"))

        #expect(abs(date.timeIntervalSince1970 - 1_668_425_454.2768053) < 0.001)
    }

    /// Without an offset the time zone would be a guess, so these are refused.
    @Test(arguments: ["2026-10-08T09:30:00", "2026-10-08 09:30:00", "2026-10-08", "", "yesterday"])
    func rejectsValuesWithoutOffset(_ input: String) {
        #expect(DateFormatter.iso8601FormattedDate(from: input) == nil)
    }
}
