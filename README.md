# SolarEdgeKit

A Swift package for the SolarEdge Monitoring API v2 (Basic and Advanced Monitoring API) and the SolarEdge Designer API, built on `URLSession` and Foundation only, with no third-party dependencies.

> **Status: in development.** All operations of the Basic Monitoring, Advanced Monitoring and Designer API specs are implemented (see [Implemented endpoints](#implemented-endpoints)) and tested against the Stoplight mocks. They have not yet been checked against real API responses.

## Requirements

- Swift 6.0 tools or later
- macOS 13, iOS 16, tvOS 16, watchOS 9, visionOS 1 or later
- Linux: intended to work with a Swift 6.0 toolchain, but not yet built or tested there

### Linux

On Linux, `URLSession`, `URLRequest`, `HTTPURLResponse` and `URLError` live in `FoundationNetworking`, not `Foundation`. The package imports it where needed. If you write your own `HTTPTransport`, import it in that file too:

```swift
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
```

Time zones need the system's time zone database. Slim container images often lack it (on Debian or Ubuntu, install `tzdata`); without it, every `SiteDetails.location.timezone` is `nil`.

## API specs

The package is built against these OpenAPI specs from SolarEdge:

| API | Spec title | Version |
|---|---|---|
| Basic Monitoring | SolarEdge Basic Monitoring API | 2.1.0 |
| Advanced Monitoring | SolarEdge Advanced Monitoring API | 2.0.1 |
| Designer | SolarEdge Designer Public API | 1.0.0 |

The specs belong to SolarEdge and are not part of this package. The Stoplight mocks used by the mock tests are generated from these versions.
See [https://api-docs.solaredge.com](https://api-docs.solaredge.com) for the API documentation.


## Products and targets

| Product | Target | Contents |
|---|---|---|
| `SolarEdgeONE` | `SolarEdgeONE` | SolarEdge ONE monitoring: sites, measurements, devices |
| `SolarEdgeDesigner` | `SolarEdgeDesigner` | Designer API: estimations, lookup data, reports, projects, Auto Design, battery upsell |
| `SolarEdgeKit` | `SolarEdgeKit` | Umbrella: re-exports all of the above |
| — | `SolarEdgeCore` | Shared plumbing: transport, authentication, errors, `CalendarDate`. Not a product of its own. |

## Example: site details

```swift
import SolarEdgeKit

// Load the key from secure storage; never hard-code or commit it.
let apiKey = "<your API key>"

let client = SolarEdgeONEClient(credentials: .apiKey(apiKey))

do {
    let details = try await client.sites.details(for: 93082)

    print(details.name)                 // Smith, John CRM1234
    print(details.peakPower)            // 6.14 (kWp)
    print(details.installationDate)     // 2026-03-10
    print(details.lastUpdateTime)       // 2026-10-08 06:30:00 +0000
    print(details.location.city)        // Green Bay
    print(details.activationStatus)     // active

    // The installation date has no time zone; use the site's own.
    if let timeZone = details.location.timezone {
        let installedAt = details.installationDate.startOfDay(in: timeZone)
        print(installedAt as Any)
    }
} catch SolarEdgeError.notFound {
    print("No such site, or no access to it.")
} catch let error as SolarEdgeError {
    print(error.localizedDescription)
}
```

The printed values are those of the example response in the API spec. `import SolarEdgeONE` works the same if you only add that product.

## Example: Designer

The Designer spec gives no host, only the path `/wsd-backend/v1/api`, so the base URL has to be passed in. Its public types live in the `Designer` namespace, e.g. `Designer.Estimation`, just as the Monitoring types live in `Monitoring`.

```swift
import SolarEdgeKit

// Load the key from secure storage; never hard-code or commit it.
let designerKey = "<your Designer API key>"

let designer = SolarEdgeDesignerClient(
    credentials: .bearerToken(StaticTokenProvider(token: designerKey)),
    baseURL: SolarEdgeDesignerClient.baseURL(host: URL(string: "https://designer.example")!)  // your Designer host
)

do {
    // Lookup data for an estimation.
    let grids = try await designer.estimation.gridCodes(country: "DE")
    print(grids.map(\.name))

    // The electrical and financial estimation of a site's default design.
    switch try await designer.estimation.estimation(for: 1371991379163700) {
    case .ready(let estimation):
        print(estimation.installedSystem.annualEnergy)                   // Wh
        print(estimation.detailedFinancialAnalysis.paybackPeriod)        // years
    case .stillInDesign(let message):
        print(message)
    }
} catch let error as SolarEdgeError {
    print(error.localizedDescription)
}
```

## Architecture

A request goes through four layers:

```
SolarEdgeONEClient.sites               public entry point
SitesService.overview(for:)            public API, validates parameters
  └─ SiteOverviewEndpoint              internal: path, query items, allowed auth
       └─ APIClient.send(_:)           SolarEdgeCore: builds, authorizes, sends, decodes
            └─ SiteSummaryDTO          internal: mirrors the API's JSON
                 └─ .entity → Monitoring.SiteOverview   public: what callers get
```

- **Endpoints** conform to `Endpoint` (`SolarEdgeCore`) and describe one API call: `path`, `queryItems` and `supportedAuthentication`. Only `APIClient` turns them into network requests.
- **DTOs** mirror the OpenAPI schemas one to one. A field is optional only if the spec marks it `nullable: true`, or its description explicitly says the API omits it (e.g. "Only present for METER devices").
- **Entities** are the public types: `Sendable`, `Hashable`, with a public memberwise `init`. Each DTO has an `entity` property that maps it and throws `SolarEdgeError.decodingWithMessage` for values it cannot convert (unknown units, unreadable dates).
- **Services** (`SitesService`, `AlertsService`, `InventoryService`, `InvertersService`, `MetersService`, `BatteriesService`) group the public methods per API area. `SolarEdgeONEClient` creates them and holds one per area, e.g. `client.sites`, `client.alerts`, `client.inventory`, `client.inverters`, `client.meters` and `client.batteries`. `InvertersService` covers all three inverter tags of the spec (Telemetry, Measurements, Status), `MetersService` both meter tags, and `BatteriesService` Storage Telemetry, Storage Status and Battery Measurements. `AdvancedService` (`client.advanced`) holds the Advanced Monitoring API, which needs a Pro or Enterprise plan. The API calls batteries "storage" in its paths; the DTOs keep that name, the public types say "Battery".
- **Designer services** follow the spec's tags and hang off `SolarEdgeDesignerClient`: `estimation` (lookup data and estimations), `deviceModels`, `reports`, `sharableLinks`, `projects`, `autoDesign` and `batteryUpsell`. Request bodies are public parameter types (e.g. `Designer.EstimationParameters`) that map to internal request DTOs; `nil` values are left out of the JSON so the API applies its defaults, and the ranges the spec gives are checked before sending.

### Conventions

- **Dates.** Values that are a day without a time (e.g. `installationDate`) become `CalendarDate`; real points in time become `Date`. Dates sent as query parameters are always in UTC (`2026-10-01T00:00:00Z`); the API rejects dates without a time zone.
- **Namespaces.** The public Monitoring types live in `Monitoring` (e.g. `Monitoring.Site`, `Monitoring.Power`), the Designer types in `Designer`. Generic names such as `Alert`, `Device` or `Location` therefore do not clash with an app's own types or with frameworks such as SwiftUI. Clients and services stay top-level (`SolarEdgeONEClient`, `SitesService`); with type inference, callers rarely write the prefix.
- **Units.** Each kind of unit is its own enum: `Monitoring.Power`, `Energy`, `Percentage`, `Voltage`, `ElectricCurrent`, `Frequency`, `Temperature`, `UnitSystem`. Time series are generic over the unit, e.g. `Monitoring.Measurements<Monitoring.Power>`; device-state series use `StatusSeries`, e.g. `StatusSeries<Temperature>`.
- **Values the server owns.** Statuses and types the API can extend over time (e.g. `DeviceType`, `AlertStatus`, `InverterMode`, the Designer bill-of-materials `ItemType`) have a `case unknown(String)`, so a new value decodes instead of failing the whole response; switches over them must handle it. Units, resolutions and other closed sets (e.g. `Month`, `MountingType`) stay strict and throw `decodingWithMessage` for an unexpected value.
- **Validation before sending.** Parameters the API would reject are checked locally where that is unambiguous (page ranges, period length per resolution, unsupported units), so no request or credit is wasted. See `PeriodValidation.swift`.
- **Errors.** Everything thrown is a `SolarEdgeError`, except `CancellationError` when the task is cancelled: HTTP status cases (`unauthorized(details:)`, `forbidden(details:)`, `notFound(details:)`, `rateLimited(retryAfter:details:limits:)`, `http(statusCode:details:)`), `network`, `decoding` and `invalidRequest`. A failing `AccessTokenProvider` becomes `authentication(underlying:)`, and an error from a custom `HTTPTransport` becomes `transport(underlying:)`; a `SolarEdgeError` thrown by either passes through unchanged. `ErrorDetails` holds what the error body says: `message`, the gateway's `code`, the `requestID` to quote to SolarEdge, and per-parameter `fieldErrors`. For a `429`, `RateLimit` holds the `x-ratelimit-*` headers: per-minute, or monthly plus per-second, and whether the monthly quota is used up. To watch the limits before a `429`, pass `onRateLimit:` to the client's `init`; it is called for every response that carries these headers. The spec documents them only for `429`, so whether successful responses have them depends on the gateway. Error bodies are read best-effort, so the two error DTOs in `SolarEdgeCore/DTOs` are the one exception to the optional-fields rule: all their fields are optional.

## Authentication

`SolarEdgeCredentials` supports both methods the API offers:

- `.apiKey(String)`, sent as the `X-API-Key` header. Accepted by every endpoint.
- `.bearerToken(any AccessTokenProvider)`, sent as `Authorization: Bearer …`. For Monitoring Site Access, `Monitoring.OAuthTokenProvider` handles the tokens (see [OAuth](#oauth-site-access) below); otherwise implement `AccessTokenProvider` with your own storage and refresh.
  After a `401`, the client calls `invalidate(_:)` with the rejected token, asks for a token again and, if it is a different one, repeats the request once. Implement `invalidate(_:)` to drop the token from your cache; without it, the `401` is thrown as `SolarEdgeError.unauthorized` right away.
- For a token that never changes, such as a Designer API key, use `.bearerToken(StaticTokenProvider(token: …))`.

Every Designer endpoint accepts a Designer API key as a bearer token (via `StaticTokenProvider`) or a SolarEdge API key.

Site List (`GET /sites`) and Fleet Alerts (`GET /alerts`) accept only an API key. Using a bearer token there throws `unsupportedAuthentication` before any request is made.

### OAuth (Site Access)

A Fleet API key covers all sites your account owns. To read sites owned by someone else, the homeowner connects each site to your app through SolarEdge Connect, and you get one token pair per site. The package covers everything except the browser step and storage:

```swift
let oauth = Monitoring.OAuthClient(clientID: clientID, clientSecret: clientSecret)

// 1. Send the homeowner to SolarEdge Connect to sign in and approve.
let url = Monitoring.OAuthClient.authorizationURL(clientID: clientID, externalID: userID)

// 2. Your redirect URL receives `code`, `site_id` and `external_id`.
//    Exchange the one-time code for the site's first token pair:
let tokens = try await oauth.exchange(code: code)
try store.save(tokens, for: siteID)

// 3. One provider and one client per site.
let provider = Monitoring.OAuthTokenProvider(tokens: tokens, oauth: oauth) { newTokens in
    try? store.save(newTokens, for: siteID)   // called after every refresh
}
let client = SolarEdgeONEClient(credentials: .bearerToken(provider))
```

- **Tokens.** `OAuthTokens` holds the access token, the refresh token and `expiresAt`, and is `Codable`. Access tokens last 2 hours; the provider refreshes 5 minutes early (`refreshMargin:`), and after a `401`.
- **Save every refresh.** Each refresh returns a new pair and invalidates the old refresh token. `onRefresh` receives the new pair before any request uses it; if it isn't saved, the homeowner has to connect the site again. Only one refresh runs at a time, however many requests need a token.
- **14 days.** A refresh token expires after 14 days without use. If your app may go that long without a request, call `provider.refresh()` on a schedule.
- **Errors.** The OAuth endpoints throw `Monitoring.OAuthError` with the `error` code and `error_description`. During a request, a failed refresh arrives as `SolarEdgeError.authentication(underlying:)` with that error: the site has to be connected again. If a refresh fails while the old token is still valid, the old token is used and the next request tries again.
- **Disconnecting.** `provider.revoke()` revokes the refresh token; reconnecting needs the browser step again.
- **Client secret.** `OAuthClient` needs it, so run the exchange and refreshes only where it is safe: on your backend, or in a tool for your own sites. Never ship it in an app given to others, and never commit it.
- **Scopes.** `SITE_DATA` covers site data, `DEVICE_DATA` device data; a token without the needed scope gets `403`.

Never commit real API keys or tokens. The tests use the dummy key `123` against a mock server.

## Folder layout

```
Sources/
  SolarEdgeCore/        APIClient, Endpoint, credentials, errors, CalendarDate
  SolarEdgeONE/
    SolarEdgeONEClient.swift   public entry point; re-exports SolarEdgeCore
    Monitoring.swift    the `Monitoring` namespace
    DTOs/               DTOs shared across API areas (Measurements, Period, errors) and not yet sorted
    Entities/           shared public types (Measurements, units, Resolution)
    Extensions/         internal helpers (query items, period and serial number validation)
    Sites/              SitesService and one endpoint file per Sites operation
      DTOs/             DTOs used only by Sites operations
      Entities/         public types used only by Sites operations
    Alerts/             AlertsService, its endpoints, DTOs and entities
    Inventory/          InventoryService, its endpoints, DTOs and entities
    Inverters/          InvertersService, its endpoints, DTOs and entities
    Meters/             MetersService, its endpoints, DTOs and entities
    Batteries/          BatteriesService, its endpoints, DTOs and entities
    Advanced/           AdvancedService (Advanced Monitoring API), its endpoints, DTOs and entities
    OAuth/              OAuthClient, OAuthTokens, OAuthError and OAuthTokenProvider for Site Access
  SolarEdgeDesigner/
    SolarEdgeDesignerClient.swift   public entry point; re-exports SolarEdgeCore
    Designer.swift      the `Designer` namespace
    DTOs/, Entities/    request DTOs and public types shared across Designer areas
    Extensions/         internal helpers (authentication, query items, parameter validation)
    Estimation/         EstimationService: lookup data, and estimations in Report/
    DeviceModels/, Reports/, SharableLinks/, Project/, AutoDesign/, BatteryUpsell/
                        one folder per service, with its endpoints, DTOs and entities
  SolarEdgeKit/         umbrella re-exports
Tests/
  SolarEdgeCoreTests/
  SolarEdgeONETests/
    MockServer.swift    shared mock server setup and the .mockServer tag
    Sites/              endpoint tests (offline) and mock tests (network)
  SolarEdgeDesignerTests/
    DesignerMockServer.swift   Designer mock URL and the .mockServer tag
  SolarEdgeLiveTests/   opt-in read-only tests against the real API
```

## Implemented endpoints

| API | Method |
|---|---|
| `GET /sites` | `list(filter:page:pageSize:)`, `all(filter:pageSize:)` |
| `GET /sites/{id}` | `details(for:)` |
| `GET /sites/{id}/overview` | `overview(for:from:to:)` |
| `GET /sites/{id}/overview/performance` | `performance(for:from:to:)` |
| `GET /sites/{id}/power` | `power(for:from:to:resolution:unit:)` |
| `GET /sites/{id}/energy` | `energy(for:from:to:resolution:unit:)` |
| `GET /sites/{id}/lifetime-energy` | `lifetimeEnergy(for:)` |
| `GET /sites/{id}/external-production-energy` | `externalProductionEnergy(for:)` |
| `GET /sites/{id}/environmental-benefits` | `environmentalBenefits(for:unit:)` |
| `GET /sites/{id}/alerts` | `client.alerts.list(for:page:pageSize:onlyOpen:)` |
| `GET /alerts` | `client.alerts.list(filter:page:pageSize:onlyOpen:)` |
| `GET /sites/{id}/devices` | `client.inventory.devices(for:types:)` |
| `GET /sites/{id}/devices/{serialNumber}` | `client.inventory.device(_:for:)` |
| `GET /sites/{id}/inverters/telemetry` | `client.inverters.telemetry(for:from:to:resolution:)` |
| `GET /sites/{id}/inverters/{serialNumbers}/telemetry` | `client.inverters.telemetry(for:serialNumbers:from:to:resolution:)` |
| `GET /sites/{id}/inverters/{serialNumber}/power` | `client.inverters.power(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/inverters/{serialNumber}/energy` | `client.inverters.energy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/inverters/{serialNumber}/consumed-ac-power` | `client.inverters.consumedAcPower(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/inverters/{serialNumber}/consumed-ac-energy` | `client.inverters.consumedAcEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/inverters/{serialNumber}/voltage` | `client.inverters.voltage(for:serialNumber:from:to:resolution:)` |
| `GET /sites/{id}/inverters/{serialNumber}/current` | `client.inverters.current(for:serialNumber:from:to:resolution:)` |
| `GET /sites/{id}/inverters/{serialNumber}/frequency` | `client.inverters.frequency(for:serialNumber:from:to:resolution:)` |
| `GET /sites/{id}/inverters/{serialNumber}/lifetime-energy` | `client.inverters.lifetimeEnergy(for:serialNumber:from:to:)` |
| `GET /sites/{id}/inverters/lifetime-energy` | `client.inverters.lifetimeEnergy(for:from:to:)` |
| `GET /sites/{id}/inverters/status` | `client.inverters.status(for:from:to:resolution:)` |
| `GET /sites/{id}/inverters/{serialNumbers}/status` | `client.inverters.status(for:serialNumbers:from:to:resolution:)` |
| `GET /sites/{id}/meters/telemetry` | `client.meters.telemetry(for:from:to:resolution:)` |
| `GET /sites/{id}/meters/{serialNumbers}/telemetry` | `client.meters.telemetry(for:serialNumbers:from:to:resolution:)` |
| `GET /sites/{id}/meters/{serialNumber}/production-power` | `client.meters.productionPower(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/meters/{serialNumber}/production-energy` | `client.meters.productionEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/meters/{serialNumber}/consumption-power` | `client.meters.consumptionPower(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/meters/{serialNumber}/consumption-energy` | `client.meters.consumptionEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/meters/{serialNumber}/import-power` | `client.meters.importPower(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/meters/{serialNumber}/import-energy` | `client.meters.importEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/meters/{serialNumber}/export-power` | `client.meters.exportPower(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/meters/{serialNumber}/export-energy` | `client.meters.exportEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/meters/lifetime-energy` | `client.meters.lifetimeEnergy(for:directions:from:to:)` |
| `GET /sites/{id}/meters/{serialNumbers}/lifetime-energy` | `client.meters.lifetimeEnergy(for:serialNumbers:directions:from:to:)` |
| `GET /sites/{id}/storage/telemetry`, `…/storage/{serialNumbers}/telemetry` | `client.batteries.telemetry(for:serialNumbers:from:to:resolution:)` |
| `GET /sites/{id}/storage/status`, `…/storage/{serialNumbers}/status` | `client.batteries.status(for:serialNumbers:from:to:)` |
| `GET /sites/{id}/storage/{serialNumber}/charge-power` | `client.batteries.chargePower(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/storage/{serialNumber}/discharge-power` | `client.batteries.dischargePower(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/storage/{serialNumber}/charge-energy` | `client.batteries.chargeEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/storage/{serialNumber}/discharge-energy` | `client.batteries.dischargeEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/storage/{serialNumber}/state-of-energy` | `client.batteries.stateOfEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/storage/{serialNumber}/remaining-energy` | `client.batteries.remainingEnergy(for:serialNumber:from:to:resolution:unit:)` |
| `GET /sites/{id}/storage/lifetime-energy`, `…/storage/{serialNumbers}/lifetime-energy` | `client.batteries.lifetimeEnergy(for:serialNumbers:from:to:)` |

The rows without a `client.` prefix are in `SitesService`, reached through `client.sites`.

All operations of the Basic Monitoring API spec are implemented.

### Advanced Monitoring API

Pro and Enterprise plans only; other keys get `SolarEdgeError.forbidden`.

| API | Method |
|---|---|
| `GET /sites/{id}/power/per-destination` | `client.advanced.powerPerDestination(for:from:to:resolution:)` |
| `GET /sites/{id}/energy/per-destination` | `client.advanced.energyPerDestination(for:from:to:resolution:)` |
| `GET /sites/{id}/power-flow` | `client.advanced.powerFlow(for:)` |
| `POST /sites/{id}/power-flow` | `client.advanced.startLivePowerFlow(for:)` |
| `GET /sites/{id}/weather-guard` | `client.advanced.weatherGuard(for:)` |
| `GET /sites/{id}/backup-reserve` | `client.advanced.backupReserve(for:)` |

All operations of the Advanced Monitoring API spec are implemented.

### Designer API

`client` is a `SolarEdgeDesignerClient`. Sites can be addressed by their Designer ID (`Designer.SiteID`) or, where the spec offers it, by external ID; battery upsell targets a Designer site or a Monitoring layout (`Designer.BatteryUpsellTarget`).

| API | Method |
|---|---|
| `GET /batteries` | `client.estimation.batteries(manufacturer:phase:)` |
| `GET /consumption-profiles` | `client.estimation.consumptionProfiles(country:)` |
| `GET /grid-codes` | `client.estimation.gridCodes(country:)` |
| `GET /pv-modules` | `client.estimation.pvModules(manufacturer:)` |
| `GET /pv-modules/{moduleModelId}` | `client.estimation.pvModule(_:)` |
| `GET /utility-rates/utility-names` | `client.estimation.utilityProviders(rateType:country:state:)` |
| `GET /utility-rates` | `client.estimation.utilityRates(utilityNames:rateType:orphanRates:country:state:)` |
| `GET /utility-rates/{rateId}` | `client.estimation.utilityRate(_:)` |
| `GET /incentives` | `client.estimation.incentives(country:state:)` |
| `GET /incentives/{incentiveId}` | `client.estimation.incentive(_:)` |
| `POST /estimation` | `client.estimation.estimate(_:)` |
| `GET /report/sites/{siteId}` | `client.estimation.estimation(for:)` |
| `GET /report/sites/{siteId}/designs/{designId}` | `client.estimation.estimation(for:design:)` |
| `GET /device-models` | `client.deviceModels.models(for:countryCode:stateCode:sector:)` |
| `GET /sites/{siteId}` | `client.reports.report(for:)` |
| `GET /sites/external-id/{externalId}` | `client.reports.report(forExternalID:)` |
| `GET /sites/{siteId}/images/{imageId}` | `client.reports.image(_:for:)` |
| `GET /sites/external-id/{externalId}/images/{imageId}` | `client.reports.image(_:forExternalID:)` |
| `GET /report/sites/{siteId}/sharable-links`, `…/designs/{designId}/sharable-links` | `client.sharableLinks.links(for:design:locale:units:)` |
| `GET /report/external-id/{externalId}/sharable-links`, `…/designs/{designId}/sharable-links` | `client.sharableLinks.links(forExternalID:design:locale:units:)` |
| `POST /project` | `client.projects.create(_:)` |
| `PUT /project/{projectId}` | `client.projects.update(_:with:)` |
| `POST /auto-design` | `client.autoDesign.start(_:)` |
| `GET /auto-design/status` | `client.autoDesign.status(of:)` |
| `POST /sites/{siteId}/designs/{designId}/battery-upsell`, `POST /layouts/{layoutId}/designs/{designId}/battery-upsell` | `client.batteryUpsell.apply(_:to:)` |
| `POST …/battery-upsell/financials` (both) | `client.batteryUpsell.applyWithFinancials(_:to:)` |

All 30 operations of the Designer API spec are implemented.

## Adding an endpoint

1. Read the operation and its schemas in the OpenAPI spec. The spec file is kept outside this repository.
2. Create or check the DTOs: fields as in the spec, optional only where `nullable: true` or where the description says the field is omitted. Put them in the area's `DTOs/` folder, or in `SolarEdgeONE/DTOs/` if other areas use them too.
3. Add the public entity with doc comments, and an `entity` mapping on the DTO.
4. Add the `Endpoint` type: path, query items, `supportedAuthentication` from the operation's `security` section.
5. Add the public method to the service, with defaults matching the API's and local validation where the limits are clear.
6. Add tests: an offline test for path and query items, and a mock test that decodes the spec's example.

## Testing

```bash
swift test
```

- **Offline tests** check request building, validation and parsing.
- **Mock tests** (tag `.mockServer`) send real requests to the Stoplight mocks generated from the three specs (`MockServer.baseURL`, `MockServer.advancedBaseURL` and `DesignerMockServer.baseURL`). They validate query parameters and request bodies against the spec and answer with the spec's examples. They need network access; skip them with `swift test --skip 'Mock(Setup)?Tests'`.

Mock limitations: the mock's examples for Site Details and Site Alerts omit fields the spec does not mark as optional (`latitude`, `longitude`, `countryCode` and `timezone`; `category`), and the metric endpoints have no examples, so the mock always sends `unit: "W"`. Those mock tests therefore only check that requests are accepted, using `expectAcceptedByMock(allowing:)` from `MockServer.swift`; decoding is tested offline with complete JSON. The mock also rejects comma-separated serial numbers in paths, so the device mock tests use a single one.

Designer mock limitations: most Designer schemas have no examples, so the mock sends generated placeholders (`"string"`, `0`, extreme numbers); those tests check decoding and the request shape, not values. The image endpoints declare a JSON schema for their PNG responses, so the mock sends JSON labelled `image/png`; the tests only check that the raw bytes arrive. The Auto Design status always carries an `errorCode` in the mock.

### Live tests

`SolarEdgeLiveTests` calls the real API, read-only. Every test is skipped unless its environment variables are set, so a plain `swift test` sends no live requests.

| Variable | Needed for |
|---|---|
| `SOLAREDGE_API_KEY` | Monitoring tests; also Designer, if no Designer key is set |
| `SOLAREDGE_SITE_ID` | Monitoring tests: the site for the site, device and measurement calls |
| `SOLAREDGE_DESIGNER_HOST` | Designer tests: the host, without `/wsd-backend/v1/api` |
| `SOLAREDGE_DESIGNER_KEY` | Designer tests, optional: a Designer API key |
| `SOLAREDGE_DESIGNER_COUNTRY` | Designer lookups, optional: defaults to `US` |
| `SOLAREDGE_DESIGNER_SITE_ID` | Designer site calls, optional: report, image, estimation and links |
| `SOLAREDGE_CAPTURE_DIR` | Optional: saves every raw response there, e.g. `LiveCaptures` |

```bash
SOLAREDGE_API_KEY=… SOLAREDGE_SITE_ID=… swift test --filter MonitoringLiveTests
```

- **Keys stay out of the repository.** Set the variables in your shell, or in a non-shared Xcode scheme; a shared scheme's settings are committed.
- **The output is safe to share.** Each call prints one `[live]` line with counts or, on failure, where the response did not match the model, such as a missing key. It never prints values, names, addresses, serial numbers or keys.
- **A `403` or `404` is not a failure.** It is printed as "not available for this key or site", e.g. for Advanced Monitoring without a Pro or Enterprise tier. Decoding failures and other errors fail the test.
- **Nothing is changed.** Calls that create or change data are left out: projects, Auto Design, battery upsell, the estimation `POST` and starting a live power flow.
- **Credits.** Every request uses API credits; a full Monitoring run is about 40 requests.
- **Captured responses may contain customer data.** `LiveCaptures/` is ignored by git; anonymise a capture before using it as a fixture.
