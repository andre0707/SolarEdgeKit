import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct PeriodValidationTests {
    let from = Date(timeIntervalSince1970: 1_790_812_800)

    @Test(arguments: Monitoring.Resolution.allCases)
    func acceptsMissingDates(resolution: Monitoring.Resolution) throws {
        try validatePeriod(from: nil, to: nil, resolution: resolution)
        try validatePeriod(from: from, to: nil, resolution: resolution, now: from.addingTimeInterval(3600))
        try validatePeriod(from: nil, to: from, resolution: resolution)
    }

    /// Without `to`, the API ends the period now.
    @Test
    func missingToCountsAsNow() {
        let now = from.addingTimeInterval(13 * 3600)

        #expect(throws: SolarEdgeError.self) {
            try validatePeriod(from: from, to: nil, resolution: .quarterHour, now: now)
        }
        // A day is fine for hourly values ...
        #expect(throws: Never.self) {
            try validatePeriod(from: from, to: nil, resolution: .hour, now: now)
        }
        // ... but `from` must not be in the future.
        #expect(throws: SolarEdgeError.self) {
            try validatePeriod(from: now.addingTimeInterval(1), to: nil, resolution: .hour, now: now)
        }
    }

    @Test(arguments: Monitoring.Resolution.allCases)
    func rejectsToBeforeFrom(resolution: Monitoring.Resolution) {
        #expect(throws: SolarEdgeError.self) {
            try validatePeriod(from: from, to: from.addingTimeInterval(-1), resolution: resolution)
        }
    }

    @Test(arguments: Monitoring.Resolution.allCases)
    func acceptsTheMaximumSpan(resolution: Monitoring.Resolution) throws {
        let span = resolution.maximumSpan ?? 50 * 366 * 24 * 3600
        try validatePeriod(from: from, to: from.addingTimeInterval(span), resolution: resolution)
    }

    @Test(arguments: Monitoring.Resolution.allCases.filter { $0.maximumSpan != nil })
    func rejectsLongerThanTheMaximumSpan(resolution: Monitoring.Resolution) throws {
        let span = try #require(resolution.maximumSpan)
        #expect(throws: SolarEdgeError.self) {
            try validatePeriod(from: from, to: from.addingTimeInterval(span + 1), resolution: resolution)
        }
    }
}
