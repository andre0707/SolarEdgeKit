//
//  SolarEdgeONEClient.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
@_exported import SolarEdgeCore

/// Entry point for the SolarEdge ONE Monitoring API.
///
/// ```swift
/// let client = SolarEdgeONEClient(credentials: .apiKey(apiKey))
/// let details = try await client.sites.details(for: 93082)
/// ```
public struct SolarEdgeONEClient: Sendable {
    /// The production server, `https://monitoringapi.solaredge.com/v2`.
    public static let productionURL = URL(string: "https://monitoringapi.solaredge.com/v2")!

    /// The "Sites" endpoint group.
    public let sites: SitesService

    /// The "Alerts" endpoint group.
    public let alerts: AlertsService

    /// The "Inventory" endpoint group.
    public let inventory: InventoryService

    /// The inverter endpoint groups.
    public let inverters: InvertersService

    /// The meter endpoint groups.
    public let meters: MetersService

    /// The battery endpoint groups.
    public let batteries: BatteriesService

    /// The Advanced Monitoring API. Pro and Enterprise tiers only.
    public let advanced: AdvancedService

    /// - Parameters:
    ///   - credentials: An API key, or a bearer token provider for OAuth.
    ///   - baseURL: The server to talk to. Defaults to ``productionURL``.
    ///   - transport: Sends the requests. Defaults to `URLSession.shared`;
    ///     inject your own for tests, logging or retries.
    ///   - onRateLimit: Called with the rate limits of every response that
    ///     reports them in `x-ratelimit-*` headers, so you can slow down
    ///     before the API answers `429`. Runs on the request's task; keep it short.
    public init(
        credentials: SolarEdgeCredentials,
        baseURL: URL = SolarEdgeONEClient.productionURL,
        transport: any HTTPTransport = URLSessionTransport(),
        onRateLimit: (@Sendable (SolarEdgeError.RateLimit) -> Void)? = nil
    ) {
        let client = APIClient(baseURL: baseURL, credentials: credentials, transport: transport, onRateLimit: onRateLimit)
        self.sites = SitesService(client: client)
        self.alerts = AlertsService(client: client)
        self.inventory = InventoryService(client: client)
        self.inverters = InvertersService(client: client)
        self.meters = MetersService(client: client)
        self.batteries = BatteriesService(client: client)
        self.advanced = AdvancedService(client: client)
    }
}
