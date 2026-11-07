//
//  HTTPTransport.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// The seam between the library and the network. Inject your own
/// implementation for tests, logging, retries or custom TLS handling.
public protocol HTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

/// Default transport backed by `URLSession`.
public struct URLSessionTransport: HTTPTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SolarEdgeError.invalidResponse
        }
        return (data, http)
    }
}
