import Foundation
import SolarEdgeKit

/// The settings for the live tests, read from environment variables only.
///
/// Never put a key into a file of this repository. Set the variables in your
/// shell, or in a non-shared Xcode scheme (its settings live in the ignored
/// `xcuserdata`); a shared scheme is committed.
enum LiveEnvironment {
    private static var values: [String: String] { ProcessInfo.processInfo.environment }

    private static func value(_ name: String) -> String? {
        guard let value = values[name]?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }

    // MARK: - Monitoring

    /// `SOLAREDGE_API_KEY`: a SolarEdge API key.
    static var apiKey: String? { value("SOLAREDGE_API_KEY") }

    /// `SOLAREDGE_SITE_ID`: one of your sites, the target of the site,
    /// device and measurement calls.
    static var siteID: Monitoring.Site.ID? { value("SOLAREDGE_SITE_ID").flatMap(Int.init).map(Monitoring.Site.ID.init(rawValue:)) }

    static var hasMonitoring: Bool { apiKey != nil && siteID != nil }

    // MARK: - Designer

    /// `SOLAREDGE_DESIGNER_HOST`: the Designer API host, e.g.
    /// `https://designer.example.com`, without ``SolarEdgeDesignerClient/basePath``.
    static var designerHost: URL? { value("SOLAREDGE_DESIGNER_HOST").flatMap(URL.init(string:)) }

    /// `SOLAREDGE_DESIGNER_KEY`: a Designer API key. Without it,
    /// `SOLAREDGE_API_KEY` is used.
    static var designerCredentials: SolarEdgeCredentials? {
        if let key = value("SOLAREDGE_DESIGNER_KEY") { return .bearerToken(StaticTokenProvider(token: key)) }
        return apiKey.map(SolarEdgeCredentials.apiKey)
    }

    /// `SOLAREDGE_DESIGNER_COUNTRY`: the country for the lookup calls.
    /// Defaults to `US`, the country of the spec's examples.
    static var designerCountry: String { value("SOLAREDGE_DESIGNER_COUNTRY") ?? "US" }

    /// `SOLAREDGE_DESIGNER_SITE_ID`: optional, a Designer site for the
    /// report, estimation and link calls.
    static var designerSiteID: Designer.SiteID? { value("SOLAREDGE_DESIGNER_SITE_ID").flatMap(Int.init).map(Designer.SiteID.init(rawValue:)) }

    static var hasDesigner: Bool { designerHost != nil && designerCredentials != nil }

    // MARK: - Capturing

    /// `SOLAREDGE_CAPTURE_DIR`: optional. Raw responses are saved there,
    /// e.g. `LiveCaptures`, which `.gitignore` excludes. They may contain
    /// customer data: anonymise them before using any as a fixture.
    static var captureDirectory: URL? {
        value("SOLAREDGE_CAPTURE_DIR").map { URL(fileURLWithPath: $0, isDirectory: true) }
    }
}
