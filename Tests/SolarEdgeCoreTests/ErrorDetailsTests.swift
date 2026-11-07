import Testing
import Foundation
@testable import SolarEdgeCore

/// Reading error bodies, as the spec describes them.
struct ErrorDetailsTests {

    func details(_ json: String, status: Int) -> SolarEdgeError.ErrorDetails? {
        APIClient.errorDetails(from: Data(json.utf8), statusCode: status)
    }

    /// A missing key or token: only `error` and `error_description`.
    @Test
    func gatewayMissingToken() throws {
        let details = try #require(details(#"{"error":"invalid_request","error_description":"The access token is missing"}"#, status: 401))

        #expect(details.message == "The access token is missing")
        #expect(details.code == "invalid_request")
        #expect(details.requestID == nil)
    }

    /// A wrong key or a limit: only `message` and `request_id`.
    @Test
    func gatewayWrongKey() throws {
        let details = try #require(details(#"{"message":"Unauthorized","request_id":"a214540d"}"#, status: 401))

        #expect(details.message == "Unauthorized")
        #expect(details.requestID == "a214540d")
        #expect(details.code == nil)
    }

    /// With all four fields, the more specific description wins.
    @Test
    func gatewayPrefersErrorDescription() {
        let json = #"{"message":"API rate limit exceeded","request_id":"r","error":"invalid_request","error_description":"The access token is missing"}"#

        #expect(details(json, status: 401)?.message == "The access token is missing")
    }

    @Test
    func problemDetailWithFieldErrors() throws {
        let json = #"{"type":null,"title":"Bad Request","status":400,"detail":"page must be at least 1","traceId":"00-abc","errors":{"page":"must be >= 1"}}"#
        let details = try #require(details(json, status: 400))

        #expect(details.message == "page must be at least 1")
        #expect(details.requestID == "00-abc")
        #expect(details.fieldErrors == ["page": "must be >= 1"])
    }

    /// Error bodies are lenient: a title alone still gives a message.
    @Test
    func problemDetailWithTitleOnly() {
        #expect(details(#"{"title":"Not Found"}"#, status: 404)?.message == "Not Found")
    }

    /// A server sending the other shape than the spec says is still read.
    @Test
    func fallsBackToTheOtherShape() {
        #expect(details(#"{"detail":"Too many"}"#, status: 429)?.message == "Too many")
        #expect(details(#"{"message":"Forbidden"}"#, status: 403)?.message == "Forbidden")
    }

    @Test(arguments: ["", "not json", "{}", "[]", #"{"unrelated":1}"#])
    func noUsableBodyGivesNil(_ body: String) {
        #expect(details(body, status: 404) == nil)
    }
}
