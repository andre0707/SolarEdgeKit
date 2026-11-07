import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// The Stoplight mock servers generated from the Basic and Advanced
/// Monitoring API specs. They validate requests against the spec and answer
/// with example data.
enum MockServer {
    static let baseURL = URL(string: "https://stoplight.io/mocks/se-api/basic-monitoring-api/2044751966")!
    static let advancedBaseURL = URL(string: "https://stoplight.io/mocks/se-api/advanced-monitoring/1938242183")!

    /// The mock only checks that a key or token is present, not its value.
    static func sitesService(
        credentials: SolarEdgeCredentials = .apiKey("123")
    ) -> SitesService {
        SitesService(client: APIClient(
            baseURL: baseURL,
            credentials: credentials,
            transport: URLSessionTransport()
        ))
    }
}

extension Tag {
    @Tag static var mockServer: Self
}

/// A decoding failure that is the mock's fault, not the client's.
struct ExpectedMockFailure: Sendable {
    let matches: @Sendable (SolarEdgeError) -> Bool

    /// The metric endpoints have no examples, so the mock always sends
    /// `unit: "W"`, which a typed client rightly rejects for energy, voltage etc.
    static let placeholderUnit = ExpectedMockFailure { error in
        guard case .decodingWithMessage(let message) = error else { return false }
        return message.contains("Unexpected unit")
    }

    /// The spec's example omits fields that the spec does not mark as
    /// optional, so decoding stops at the first of these keys.
    static func missingKeys(_ keys: Set<String>) -> ExpectedMockFailure {
        ExpectedMockFailure { error in
            guard case .decoding(let underlying) = error,
                  case DecodingError.keyNotFound(let key, _) = underlying
            else { return false }
            return keys.contains(key.stringValue)
        }
    }
}

/// Passes if the mock accepted the request: it either succeeds, or fails
/// only while decoding in the way `expected` describes. Fails on any HTTP or
/// network error, and on any other decoding error.
func expectAcceptedByMock(
    allowing expected: ExpectedMockFailure,
    sourceLocation: SourceLocation = #_sourceLocation,
    _ request: () async throws -> some Any
) async {
    do {
        _ = try await request()
    } catch let error as SolarEdgeError where expected.matches(error) {
        // Accepted by the mock; only its example data is incomplete.
    } catch {
        Issue.record(error, sourceLocation: sourceLocation)
    }
}
