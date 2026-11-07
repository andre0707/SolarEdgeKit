import Testing
import Foundation
import SolarEdgeKit

/// Read-only calls against the real Designer API.
///
/// Needs `SOLAREDGE_DESIGNER_HOST` and either `SOLAREDGE_DESIGNER_KEY` or
/// `SOLAREDGE_API_KEY`; skipped otherwise. `SOLAREDGE_DESIGNER_COUNTRY`
/// (default `US`) selects the lookup data; `SOLAREDGE_DESIGNER_SITE_ID`
/// adds the site calls.
///
/// Left out on purpose, because they create or change data: creating and
/// updating projects, Auto Design, battery upsell and the estimation `POST`.
@Suite(.serialized, .enabled(if: LiveEnvironment.hasDesigner, "Set SOLAREDGE_DESIGNER_HOST and a key"))
struct DesignerLiveTests {
    let client: SolarEdgeDesignerClient
    let country = LiveEnvironment.designerCountry

    init() throws {
        client = SolarEdgeDesignerClient(
            credentials: try #require(LiveEnvironment.designerCredentials),
            baseURL: SolarEdgeDesignerClient.baseURL(host: try #require(LiveEnvironment.designerHost)),
            transport: InspectingTransport()
        )
    }

    /// The lookup data, and one item each by ID. Also answers whether the
    /// grid codes always have both voltages: if not, decoding fails here.
    @Test
    func lookupsDecode() async {
        await Probe.run("estimation.gridCodes", summary: { "\($0.count) grid codes" }) {
            try await client.estimation.gridCodes(country: country)
        }
        await Probe.run("estimation.consumptionProfiles", summary: { "\($0.count) profiles" }) {
            try await client.estimation.consumptionProfiles(country: country)
        }
        await Probe.run("estimation.batteries", summary: { "\($0.count) batteries" }) {
            try await client.estimation.batteries()
        }
        if let module = await Probe.run("estimation.pvModules", summary: { "\($0.count) modules" }, {
            try await client.estimation.pvModules()
        })?.first {
            await Probe.run("estimation.pvModule (first)") { try await client.estimation.pvModule(module.id) }
        }
        if let incentive = await Probe.run("estimation.incentives", summary: { "\($0.count) incentives" }, {
            try await client.estimation.incentives(country: country)
        })?.first {
            await Probe.run("estimation.incentive (first)") { try await client.estimation.incentive(incentive.id) }
        }
        if let provider = await Probe.run("estimation.utilityProviders", summary: { "\($0.count) providers" }, {
            try await client.estimation.utilityProviders(country: country)
        })?.first,
           let rate = await Probe.run("estimation.utilityRates (first provider)", summary: { "\($0.count) rates" }, {
            try await client.estimation.utilityRates(utilityNames: [provider.name], country: country)
        })?.first {
            await Probe.run("estimation.utilityRate (first)") { try await client.estimation.utilityRate(rate.id) }
        }
    }

    /// Device models without a sector and for each sector, which tells
    /// whether the server accepts the lowercase `sector` values.
    @Test
    func deviceModelsDecode() async {
        guard let grid = await Probe.run("estimation.gridCodes", summary: { "\($0.count) grid codes" }, {
            try await client.estimation.gridCodes(country: country)
        })?.first else {
            print("[live] no grid code for \(country); device model calls skipped")
            return
        }

        func summary(_ models: Designer.DeviceModels) -> String {
            "\(models.inverters.count) inverters, \(models.optimizers.count) optimizers, \(models.batteries.count) batteries"
        }
        await Probe.run("deviceModels.models, no sector", summary: summary) {
            try await client.deviceModels.models(for: grid.id, countryCode: country)
        }
        for sector in Designer.DeviceModels.Sector.allCases {
            await Probe.run("deviceModels.models, sector \(sector.rawValue)", summary: summary) {
                try await client.deviceModels.models(for: grid.id, countryCode: country, sector: sector)
            }
        }
    }

    /// Report, first image, saved estimation and sharable links of one site.
    @Test(.enabled(if: LiveEnvironment.designerSiteID != nil, "Set SOLAREDGE_DESIGNER_SITE_ID"))
    func siteDataDecodes() async throws {
        let site = try #require(LiveEnvironment.designerSiteID)

        await Probe.run("reports.report") { try await client.reports.report(for: site) }
        await Probe.run("reports.image 0", summary: { "\($0.count) bytes" }) { try await client.reports.image(0, for: site) }
        await Probe.run("estimation.estimation (site)") { try await client.estimation.estimation(for: site) }
        await Probe.run("sharableLinks.links") { try await client.sharableLinks.links(for: site) }
    }
}
