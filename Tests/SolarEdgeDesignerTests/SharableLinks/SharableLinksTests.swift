import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeDesigner
import SolarEdgeCore

struct SharableLinksTests {

    @Test
    func pathsMatchTheSpec() {
        func path(_ site: DesignerSiteReference, _ design: Designer.DesignID?) -> String {
            SharableLinksEndpoint(site: site, design: design, locale: nil, units: nil).path
        }

        #expect(path(.id(5), nil) == "report/sites/5/sharable-links")
        #expect(path(.id(5), 7) == "report/sites/5/designs/7/sharable-links")
        #expect(path(.externalID("crm-42"), nil) == "report/external-id/crm-42/sharable-links")
        #expect(path(.externalID("crm-42"), 7) == "report/external-id/crm-42/designs/7/sharable-links")
    }

    @Test
    func sendsOnlyTheSetQueryItems() {
        let bare = SharableLinksEndpoint(site: .id(5), design: nil, locale: nil, units: nil)
        let full = SharableLinksEndpoint(site: .id(5), design: nil, locale: "de_DE", units: .metric)

        #expect(bare.queryItems.isEmpty)
        #expect(full.queryItems == [URLQueryItem(name: "locale", value: "de_DE"), URLQueryItem(name: "units", value: "METRIC")])
        #expect(bare.supportedAuthentication == [.apiKey, .bearerToken])
    }

    func decode(reportUrl: String) throws -> SharableLinksResponseDTO {
        let json = """
        {"reportUrl":"\(reportUrl)","proposalUrl":"https://designer.example/p/1",
         "siteCompletionState":{"hasSystemPricing":true,"hasImportRate":false,"hasExportRate":true,"hasConsumptionProfile":false,"isElectricalDesignValid":true}}
        """
        return try JSONDecoder().decode(SharableLinksResponseDTO.self, from: Data(json.utf8))
    }

    @Test
    func mapsTheResponse() throws {
        let links = try decode(reportUrl: "https://designer.example/r/1").entity

        #expect(links == Designer.SharableLinks(
            reportURL: URL(string: "https://designer.example/r/1")!,
            proposalURL: URL(string: "https://designer.example/p/1")!,
            siteCompletionState: .init(hasSystemPricing: true, hasImportRate: false, hasExportRate: true,
                                       hasConsumptionProfile: false, isElectricalDesignValid: true)
        ))
    }

    @Test
    func rejectsAnEmptyURL() throws {
        let dto = try decode(reportUrl: "")

        #expect(throws: SolarEdgeError.self) { try dto.entity }
    }

    /// Fails the test if a request is sent.
    struct NoRequestTransport: HTTPTransport {
        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            Issue.record("No request expected, got \(request.url!)")
            throw SolarEdgeError.invalidResponse
        }
    }

    @Test(arguments: ["", ".", "..", "a/b"])
    func invalidExternalIDIsRejected(_ externalID: String) async {
        let service = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL,
                                              transport: NoRequestTransport()).sharableLinks

        await #expect(throws: SolarEdgeError.self) { try await service.links(forExternalID: externalID) }
    }
}

/// Sends real requests to the Stoplight mock of the Designer API. The spec
/// has no example, so the mock sends `"string"` as both URLs.
/// Needs network access.
@Suite(.tags(.mockServer))
struct SharableLinksMockTests {

    let service = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL).sharableLinks

    @Test
    func byIDForDefaultAndGivenDesign() async throws {
        let defaultDesign = try await service.links(for: 5)
        // The mock validates `units` against the spec's enum.
        let design = try await service.links(for: 5, design: 7, locale: "de_DE", units: .metric)

        #expect(defaultDesign.siteCompletionState.isElectricalDesignValid)
        #expect(design.reportURL == URL(string: "string"))
    }

    @Test
    func byExternalID() async throws {
        _ = try await service.links(forExternalID: "crm 42", units: .imperial)
        _ = try await service.links(forExternalID: "crm-42", design: 7)
    }

    @Test
    func acceptsADesignerKeyAsBearerToken() async throws {
        let service = SolarEdgeDesignerClient(credentials: .bearerToken(StaticTokenProvider(token: "123")),
                                              baseURL: DesignerMockServer.baseURL).sharableLinks

        _ = try await service.links(for: 5)
    }
}
