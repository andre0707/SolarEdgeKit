//
//  Monitoring.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

/// Namespace for the public types of the SolarEdge Monitoring API (Basic and
/// Advanced), e.g. `Monitoring.Site` or `Monitoring.Power`.
///
/// Keeps generic names such as `Alert`, `Device` or `Location` from clashing
/// with an app's own types or with frameworks like SwiftUI, and apart from
/// the `Designer` types. The client and its services stay top-level, e.g.
/// ``SolarEdgeONEClient`` and ``SitesService``.
public enum Monitoring {}
