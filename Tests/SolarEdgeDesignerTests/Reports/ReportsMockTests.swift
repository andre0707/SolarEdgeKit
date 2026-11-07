import Testing
import Foundation
import SolarEdgeDesigner

/// Sends real requests to the Stoplight mock of the Designer API. The spec
/// has no examples here, so the mock generates placeholder values.
/// Needs network access.
@Suite(.tags(.mockServer))
struct ReportsMockTests {

    let reports = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL).reports

    /// Decodes every field of the generated report.
    @Test
    func reportByID() async throws {
        let data = try await reports.report(for: 1371991379163700)

        #expect(data.siteReport.overview.optimizerGeneralType == .default)
        #expect(data.siteReport.billOfMaterials.moduleCovers.first?.type == .inverter)
        #expect(data.siteReport.pvModules.first?.mountingType == .flushMount)
        #expect(data.siteDetails.name == "string")
    }

    @Test
    func reportByExternalID() async throws {
        let data = try await reports.report(forExternalID: "crm 42")

        #expect(data.siteDetails.customerDetails.firstName == "string")
    }

    /// The spec gives a JSON schema for these PNG responses (a copy-paste
    /// error), so the mock sends JSON labelled as PNG. Only checks that the
    /// bytes arrive.
    @Test
    func imagesByIDAndExternalID() async throws {
        #expect(try await !reports.image(1, for: 5).isEmpty)
        #expect(try await !reports.image(3, forExternalID: "crm-42").isEmpty)
    }

    @Test
    func acceptsADesignerKeyAsBearerToken() async throws {
        let reports = SolarEdgeDesignerClient(credentials: .bearerToken(StaticTokenProvider(token: "123")),
                                              baseURL: DesignerMockServer.baseURL).reports

        _ = try await reports.report(for: 5)
        _ = try await reports.image(2, for: 5)
    }
}
