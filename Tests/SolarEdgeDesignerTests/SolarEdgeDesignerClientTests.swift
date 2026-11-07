import Testing
import Foundation
@testable import SolarEdgeDesigner
import SolarEdgeCore

struct SolarEdgeDesignerClientTests {

    @Test(arguments: ["https://designer.example", "https://designer.example/"])
    func baseURLAppendsTheSpecPath(_ host: String) {
        let url = SolarEdgeDesignerClient.baseURL(host: URL(string: host)!)

        #expect(url.absoluteString == "https://designer.example/wsd-backend/v1/api")
    }
}

/// Checks the Core support the Designer API needs, against its mock.
/// Needs network access.
@Suite(.tags(.mockServer))
struct DesignerMockSetupTests {

    struct SiteImage: Endpoint {
        typealias Response = Data
        var accept: String
        var path: String { "sites/1/images/1" }
        var supportedAuthentication: Set<AuthenticationMethod> { [.apiKey, .bearerToken] }
    }

    func client(_ credentials: SolarEdgeCredentials) -> APIClient {
        SolarEdgeDesignerClient(credentials: credentials, baseURL: DesignerMockServer.baseURL).client
    }

    /// The image endpoints answer with raw bytes, with either kind of key.
    ///
    /// The spec gives `ReportDataDto` as the schema of these `image/png`
    /// responses (a copy-paste error), so the mock sends that JSON labelled
    /// as PNG. The test therefore only checks that the bytes arrive
    /// unchanged, not that they are a PNG.
    @Test(arguments: [SolarEdgeCredentials.apiKey("123"), .bearerToken(StaticTokenProvider(token: "123"))])
    func imagesComeBackAsRawBytes(_ credentials: SolarEdgeCredentials) async throws {
        let bytes = try await client(credentials).send(SiteImage(accept: "image/png, application/json, application/problem+json"))

        #expect(!bytes.isEmpty)
        // Raw, not decoded: still the mock's JSON text.
        #expect(bytes.starts(with: Array(#"{"siteReport""#.utf8)))
    }

    /// Why images need their own `Accept`: with the JSON default the mock refuses.
    @Test
    func imagesNeedTheirOwnAcceptHeader() async {
        do {
            _ = try await client(.apiKey("123")).send(SiteImage(accept: "application/json, application/problem+json"))
            Issue.record("Expected a 406")
        } catch SolarEdgeError.http(let statusCode, _) {
            #expect(statusCode == 406)
        } catch {
            Issue.record(error)
        }
    }
}
