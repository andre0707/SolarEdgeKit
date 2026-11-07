//
//  SolarEdgeDesignerClient.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
@_exported import SolarEdgeCore

/// Entry point for the SolarEdge Designer API.
///
/// The spec gives no host, only the path ``basePath``, so the base URL has to
/// be supplied:
///
/// ```swift
/// let client = SolarEdgeDesignerClient(
///     credentials: .bearerToken(StaticTokenProvider(token: designerKey)),
///     baseURL: SolarEdgeDesignerClient.baseURL(host: URL(string: "https://…")!)
/// )
/// ```
///
/// Every endpoint accepts a Designer API key as a bearer token, or a
/// SolarEdge API key (`.apiKey`, sent as `X-API-Key`).
public struct SolarEdgeDesignerClient: Sendable {
    /// The path of the API on its host, as given by the spec.
    public static let basePath = "/wsd-backend/v1/api"

    /// The base URL for a given host: the host followed by ``basePath``.
    public static func baseURL(host: URL) -> URL {
        host.appending(path: basePath)
    }

    let client: APIClient

    /// Estimations, and the lookup data they are built from: batteries,
    /// consumption profiles, grids, PV modules, utility rates and incentives.
    public let estimation: EstimationService
    /// The inverters, optimizers and batteries available for a grid.
    public let deviceModels: DeviceModelsService
    /// The report, details and images of a site marked as done.
    public let reports: ReportsService
    /// Public links to a design's report and proposal.
    public let sharableLinks: SharableLinksService
    /// Create and update projects (sites) in Designer.
    public let projects: ProjectService
    /// Automatic site creation and design.
    public let autoDesign: AutoDesignService
    /// Apply batteries to existing designs, with or without financials.
    public let batteryUpsell: BatteryUpsellService

    /// - Parameters:
    ///   - credentials: A Designer API key via ``StaticTokenProvider``, or a
    ///     SolarEdge API key.
    ///   - baseURL: The API's base URL, including ``basePath``; see
    ///     ``baseURL(host:)``.
    ///   - transport: Sends the requests. Defaults to `URLSession.shared`;
    ///     inject your own for tests, logging or retries.
    ///   - onRateLimit: Called with the rate limits of every response that
    ///     reports them in `x-ratelimit-*` headers, so you can slow down
    ///     before the API answers `429`. Runs on the request's task; keep it short.
    public init(
        credentials: SolarEdgeCredentials,
        baseURL: URL,
        transport: any HTTPTransport = URLSessionTransport(),
        onRateLimit: (@Sendable (SolarEdgeError.RateLimit) -> Void)? = nil
    ) {
        let client = APIClient(baseURL: baseURL, credentials: credentials, transport: transport, onRateLimit: onRateLimit)
        self.client = client
        self.estimation = EstimationService(client: client)
        self.deviceModels = DeviceModelsService(client: client)
        self.reports = ReportsService(client: client)
        self.sharableLinks = SharableLinksService(client: client)
        self.projects = ProjectService(client: client)
        self.autoDesign = AutoDesignService(client: client)
        self.batteryUpsell = BatteryUpsellService(client: client)
    }
}
