import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeDesigner
import SolarEdgeCore

struct ReportEndpointTests {

    @Test
    func pathsMatchTheSpec() {
        #expect(SiteReportDataEndpoint(site: .id(1371991379163700)).path == "sites/1371991379163700")
        #expect(SiteReportDataEndpoint(site: .externalID("crm-42")).path == "sites/external-id/crm-42")
        #expect(SiteImageEndpoint(site: .id(5), index: 2).path == "sites/5/images/2")
        #expect(SiteImageEndpoint(site: .externalID("crm-42"), index: 3).path == "sites/external-id/crm-42/images/3")
    }

    @Test
    func imagesAskForPNGAndReportsForJSON() {
        let report = SiteReportDataEndpoint(site: .id(5))
        let image = SiteImageEndpoint(site: .id(5), index: 1)

        #expect(report.accept == "application/json, application/problem+json")
        #expect(image.accept.hasPrefix("image/png"))
        #expect(report.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(image.supportedAuthentication == [.apiKey, .bearerToken])
    }

    /// Records the URL of the one request it gets, and answers with an empty PNG body.
    final class RecordingTransport: HTTPTransport, @unchecked Sendable {
        var urls: [URL] = []

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            urls.append(request.url!)
            return (Data([0x89, 0x50, 0x4E, 0x47]), HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)
        }
    }

    /// Spaces, `?` and `#` in an external ID stay part of the path segment.
    @Test
    func externalIDIsPercentEncoded() async throws {
        let transport = RecordingTransport()
        let reports = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: URL(string: "https://designer.example/api")!,
                                              transport: transport).reports

        let bytes = try await reports.image(1, forExternalID: "a b?c#d")

        #expect(bytes == Data([0x89, 0x50, 0x4E, 0x47]))
        #expect(transport.urls.map(\.absoluteString) == ["https://designer.example/api/sites/external-id/a%20b%3Fc%23d/images/1"])
    }

    /// Fails the test if a request is sent.
    struct NoRequestTransport: HTTPTransport {
        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            Issue.record("No request expected, got \(request.url!)")
            throw SolarEdgeError.invalidResponse
        }
    }

    var reports: ReportsService {
        SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL, transport: NoRequestTransport()).reports
    }

    @Test(arguments: [0, 4, -1])
    func imageIndexOutside1To3IsRejected(_ index: Int) async {
        await #expect(throws: SolarEdgeError.self) { try await reports.image(index, for: 5) }
        await #expect(throws: SolarEdgeError.self) { try await reports.image(index, forExternalID: "crm-42") }
    }

    @Test(arguments: ["", ".", "..", "a/b"])
    func invalidExternalIDIsRejected(_ externalID: String) async {
        await #expect(throws: SolarEdgeError.self) { try await reports.report(forExternalID: externalID) }
        await #expect(throws: SolarEdgeError.self) { try await reports.image(1, forExternalID: externalID) }
    }
}
