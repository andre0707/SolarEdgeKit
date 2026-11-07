import Testing
import Foundation

/// The Stoplight mock server generated from the Designer API spec. Unlike a
/// real server, it serves the paths without ``SolarEdgeDesignerClient/basePath``.
enum DesignerMockServer {
    static let baseURL = URL(string: "https://stoplight.io/mocks/se-api/designer/639066878")!
}

extension Tag {
    @Tag static var mockServer: Self
}
