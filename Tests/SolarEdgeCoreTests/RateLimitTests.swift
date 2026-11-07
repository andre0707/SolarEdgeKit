import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeCore

/// Reading the `x-ratelimit-*` headers of a `429`.
struct RateLimitTests {

    func limits(_ headers: [String: String]) -> SolarEdgeError.RateLimit? {
        let response = HTTPURLResponse(url: URL(string: "https://example.invalid")!, statusCode: 429, httpVersion: nil, headerFields: headers)!
        return APIClient.rateLimit(from: response)
    }

    /// A key with a per-minute limit.
    @Test
    func perMinuteKey() throws {
        let limits = try #require(limits(["x-ratelimit-limit-minute": "300", "x-ratelimit-remaining-minute": "0"]))

        #expect(limits.perMinute == .init(limit: 300, remaining: 0))
        #expect(limits.perMonth == nil)
        #expect(limits.perSecond == nil)
        #expect(!limits.isMonthlyQuotaExhausted)
    }

    /// A key with a monthly limit: month and second, no minute.
    @Test
    func monthlyKeyWithQuotaUsedUp() throws {
        let limits = try #require(limits([
            "x-ratelimit-limit-month": "10000", "x-ratelimit-remaining-month": "0",
            "x-ratelimit-limit-second": "5", "x-ratelimit-remaining-second": "4",
        ]))

        #expect(limits.perMonth == .init(limit: 10000, remaining: 0))
        #expect(limits.perSecond == .init(limit: 5, remaining: 4))
        #expect(limits.perMinute == nil)
        #expect(limits.isMonthlyQuotaExhausted)
    }

    @Test
    func monthlyKeyHitTheSecondLimitOnly() throws {
        let limits = try #require(limits([
            "x-ratelimit-limit-month": "10000", "x-ratelimit-remaining-month": "8123",
            "x-ratelimit-limit-second": "5", "x-ratelimit-remaining-second": "0",
        ]))

        #expect(!limits.isMonthlyQuotaExhausted)
    }

    /// HTTP header names are case-insensitive.
    @Test
    func headerNamesIgnoreCase() {
        #expect(limits(["X-RateLimit-Limit-Minute": "300", "X-RateLimit-Remaining-Minute": "12"])?.perMinute == .init(limit: 300, remaining: 12))
    }

    /// A window needs both headers as whole numbers.
    @Test(arguments: [
        ["x-ratelimit-limit-minute": "300"],
        ["x-ratelimit-remaining-minute": "0"],
        ["x-ratelimit-limit-minute": "lots", "x-ratelimit-remaining-minute": "0"],
        ["x-ratelimit-limit-minute": "300", "x-ratelimit-remaining-minute": "1.5"],
        [:],
    ])
    func incompleteOrMalformedHeadersGiveNil(_ headers: [String: String]) {
        #expect(limits(headers) == nil)
    }

    @Test
    func descriptionMentionsAnExhaustedMonthlyQuota() {
        let limits = SolarEdgeError.RateLimit(perMinute: nil, perMonth: .init(limit: 10000, remaining: 0), perSecond: nil)
        let error = SolarEdgeError.rateLimited(retryAfter: 1_209_600, details: nil, limits: limits)

        #expect(error.localizedDescription == "Rate limited. The monthly quota is used up. Retry after 1209600 s.")
    }
}
