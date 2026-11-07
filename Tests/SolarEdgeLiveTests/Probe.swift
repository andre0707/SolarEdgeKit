import Testing
import Foundation
import SolarEdgeKit

/// Runs one live call and prints a one-line result that is safe to share:
/// counts and the shape of a failure, never response values, names,
/// addresses, serial numbers or keys.
enum Probe {
    /// Runs `operation`. A decoding failure or unexpected error is recorded
    /// as a test issue; a `403`, `404` or unsupported authentication is only
    /// printed, because it says something about the account, not the package.
    ///
    /// - Returns: The result, or `nil` if the call failed.
    @discardableResult
    static func run<T>(
        _ name: String,
        summary: (T) -> String = { _ in "ok" },
        _ operation: () async throws -> T
    ) async -> T? {
        do {
            let result = try await operation()
            print("[live] \(name): \(summary(result))")
            return result
        } catch let error as SolarEdgeError {
            switch error {
            case .forbidden, .notFound, .unsupportedAuthentication:
                print("[live] \(name): not available for this key or site (\(describe(error)))")
            default:
                print("[live] \(name): FAILED, \(describe(error))")
                Issue.record("\(name): \(describe(error))")
            }
        } catch is CancellationError {
            print("[live] \(name): cancelled")
        } catch {
            print("[live] \(name): FAILED, \(type(of: error))")
            Issue.record("\(name): \(type(of: error))")
        }
        return nil
    }

    /// The error's kind and, for decoding errors, where the response did not
    /// match. Values, server messages and identifiers are left out.
    static func describe(_ error: SolarEdgeError) -> String {
        switch error {
        case .decoding(let underlying):
            return "decoding: " + describe(underlying)
        case .decodingWithMessage(let message):
            // Our messages end with the offending value; keep only the reason.
            let reason = message.components(separatedBy: " Value:").first ?? message
            return "decoding: \(reason)"
        case .http(let statusCode, let details):
            var text = "HTTP \(statusCode)"
            if let code = details?.code { text += ", code \(code)" }
            if let fields = details?.fieldErrors.keys, !fields.isEmpty {
                text += ", rejected parameters: \(fields.sorted().joined(separator: ", "))"
            }
            return text
        case .unauthorized: return "HTTP 401"
        case .forbidden: return "HTTP 403"
        case .notFound: return "HTTP 404"
        case .rateLimited(let retryAfter, _, let limits):
            let monthly = limits?.isMonthlyQuotaExhausted == true ? ", monthly quota used up" : ""
            return "HTTP 429\(monthly)" + (retryAfter.map { ", retry after \(Int($0)) s" } ?? "")
        case .unsupportedAuthentication(let used, _): return "endpoint does not accept \(used)"
        case .invalidRequest(let reason): return "invalid request: \(reason)"
        case .network(let urlError): return "network: \(urlError.code.rawValue)"
        case .authentication: return "token provider failed"
        case .transport(let underlying): return "transport: \(type(of: underlying))"
        case .invalidResponse: return "not an HTTP response"
        }
    }

    private static func describe(_ error: any Error) -> String {
        guard let error = error as? DecodingError else { return "\(type(of: error))" }
        switch error {
        case .keyNotFound(let key, let context):
            return "key '\(path(context.codingPath + [key]))' missing"
        case .valueNotFound(let type, let context):
            return "null instead of \(type) at '\(path(context.codingPath))'"
        case .typeMismatch(let type, let context):
            return "expected \(type) at '\(path(context.codingPath))'"
        case .dataCorrupted(let context):
            return "invalid data at '\(path(context.codingPath))'"
        @unknown default:
            return "unknown decoding error"
        }
    }

    /// The coding path, with array indices as `[n]`. Dictionary keys that
    /// contain digits, such as serial numbers or IDs, become `<key>`.
    private static func path(_ codingPath: [any CodingKey]) -> String {
        let parts = codingPath.map { key -> String in
            if let index = key.intValue { return "[\(index)]" }
            return key.stringValue.contains(where: \.isNumber) ? "<key>" : key.stringValue
        }
        return parts.isEmpty ? "(root)" : parts.joined(separator: ".")
    }
}
