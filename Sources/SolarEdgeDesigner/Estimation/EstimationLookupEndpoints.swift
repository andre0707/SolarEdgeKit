//
//  EstimationLookupEndpoints.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// Batteries. Authentication: Designer API key or SolarEdge API key.
struct BatteriesEndpoint: Endpoint {
    typealias Response = [BatteryDTO]

    let manufacturer: String?
    let phase: Designer.Phase?

    /// `GET /batteries`
    var path: String { "batteries" }

    var queryItems: [URLQueryItem] {
        optionalQueryItem("manufacturer", manufacturer)
            + optionalQueryItem("phase", phase.map { String($0.rawValue) })
    }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Consumption Profiles. Authentication: Designer API key or SolarEdge API key.
struct ConsumptionProfilesEndpoint: Endpoint {
    typealias Response = [ConsumptionProfileDTO]

    let country: String

    /// `GET /consumption-profiles`
    var path: String { "consumption-profiles" }

    var queryItems: [URLQueryItem] { [URLQueryItem(name: "country", value: country)] }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Grid Codes. Authentication: Designer API key or SolarEdge API key.
struct GridCodesEndpoint: Endpoint {
    typealias Response = [GridCodeDTO]

    let country: String

    /// `GET /grid-codes`
    var path: String { "grid-codes" }

    var queryItems: [URLQueryItem] { [URLQueryItem(name: "country", value: country)] }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// PV Modules. Authentication: Designer API key or SolarEdge API key.
struct PvModulesEndpoint: Endpoint {
    typealias Response = [PvModuleDTO]

    let manufacturer: String?

    /// `GET /pv-modules`
    var path: String { "pv-modules" }

    var queryItems: [URLQueryItem] { optionalQueryItem("manufacturer", manufacturer) }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// PV Module. Authentication: Designer API key or SolarEdge API key.
struct PvModuleEndpoint: Endpoint {
    typealias Response = PvModuleDTO

    let id: Designer.PvModule.ID

    /// `GET /pv-modules/{moduleModelId}`
    var path: String { "pv-modules/\(id.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Utility Providers. Authentication: Designer API key or SolarEdge API key.
struct UtilityProvidersEndpoint: Endpoint {
    typealias Response = [UtilityProviderDTO]

    let rateType: Designer.UtilityRate.RateType?
    let country: String?
    let state: String?

    /// `GET /utility-rates/utility-names`
    var path: String { "utility-rates/utility-names" }

    var queryItems: [URLQueryItem] {
        optionalQueryItem("rateType", rateType?.rawValue)
            + optionalQueryItem("country", country)
            + optionalQueryItem("state", state)
    }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Utility Rates. Authentication: Designer API key or SolarEdge API key.
struct UtilityRatesEndpoint: Endpoint {
    typealias Response = [UtilityRateDTO]

    let utilityNames: [String]
    let rateType: Designer.UtilityRate.RateType?
    let orphanRates: Designer.UtilityRate.OrphanRatesFilter?
    let country: String?
    let state: String?

    /// `GET /utility-rates`
    var path: String { "utility-rates" }

    /// `utilityNames` is repeated once per name (OpenAPI's default `form`,
    /// `explode: true`), so names may contain commas.
    var queryItems: [URLQueryItem] {
        utilityNames.map { URLQueryItem(name: "utilityNames", value: $0) }
            + optionalQueryItem("rateType", rateType?.rawValue)
            + optionalQueryItem("orphanRatesFilter", orphanRates?.rawValue)
            + optionalQueryItem("country", country)
            + optionalQueryItem("state", state)
    }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Utility Rate. Authentication: Designer API key or SolarEdge API key.
struct UtilityRateEndpoint: Endpoint {
    typealias Response = UtilityRateDTO

    let id: Designer.UtilityRate.ID

    /// `GET /utility-rates/{rateId}`
    var path: String { "utility-rates/\(id.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Incentives. Authentication: Designer API key or SolarEdge API key.
struct IncentivesEndpoint: Endpoint {
    typealias Response = [IncentiveDTO]

    let country: String?
    let state: String?

    /// `GET /incentives`
    var path: String { "incentives" }

    var queryItems: [URLQueryItem] {
        optionalQueryItem("country", country) + optionalQueryItem("state", state)
    }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}

/// Incentive. Authentication: Designer API key or SolarEdge API key.
struct IncentiveEndpoint: Endpoint {
    typealias Response = IncentiveDTO

    let id: Designer.Incentive.ID

    /// `GET /incentives/{incentiveId}`
    var path: String { "incentives/\(id.rawValue)" }

    var supportedAuthentication: Set<AuthenticationMethod> { designerAuthentication }
}
