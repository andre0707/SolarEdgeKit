import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SolarEdgeCore

/// Sends requests with `URLSession`, notes the rate-limit header names it
/// sees and, if asked, saves each raw response to a directory.
final class InspectingTransport: HTTPTransport, @unchecked Sendable {
    private let base = URLSessionTransport()
    private let captureDirectory: URL?
    private let lock = NSLock()
    private var requestCount = 0
    private var rateLimitHeaders: [Int: Set<String>] = [:]

    init(captureDirectory: URL? = LiveEnvironment.captureDirectory) {
        self.captureDirectory = captureDirectory
    }

    /// How many requests were sent.
    var requests: Int { lock.withLock { requestCount } }

    /// The names of the rate-limit headers seen, per status code. Names
    /// only, never values.
    var rateLimitHeaderNames: [Int: Set<String>] { lock.withLock { rateLimitHeaders } }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await base.send(request)
        let number = record(response)
        if let captureDirectory {
            save(data, of: request, response: response, number: number, in: captureDirectory)
        }
        return (data, response)
    }

    private func record(_ response: HTTPURLResponse) -> Int {
        let names = response.allHeaderFields.keys
            .compactMap { ($0 as? String)?.lowercased() }
            .filter { $0.contains("ratelimit") || $0 == "retry-after" }
        return lock.withLock {
            requestCount += 1
            rateLimitHeaders[response.statusCode, default: []].formUnion(names)
            return requestCount
        }
    }

    private func save(_ data: Data, of request: URLRequest, response: HTTPURLResponse, number: Int, in directory: URL) {
        let path = (request.url?.path ?? "response")
            .split(separator: "/")
            .joined(separator: "-")
        let isImage = response.value(forHTTPHeaderField: "Content-Type")?.hasPrefix("image/") == true
        let name = String(format: "%03d-%@-%d.%@", number, path, response.statusCode, isImage ? "png" : "json")
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: directory.appending(path: name))
        } catch {
            print("[live] could not save \(name): \(error.localizedDescription)")
        }
    }
}
