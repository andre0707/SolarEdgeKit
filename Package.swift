// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SolarEdgeKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        // Pick only what you need ...
        .library(name: "SolarEdgeONE", targets: ["SolarEdgeONE"]),
        .library(name: "SolarEdgeDesigner", targets: ["SolarEdgeDesigner"]),
        // ... or take everything.
        .library(name: "SolarEdgeKit", targets: ["SolarEdgeKit"]),
    ],
    dependencies: [
        // Intentionally empty: URLSession + Foundation only.
    ],
    targets: [
        // MARK: - Shared plumbing

        // Transport, authentication, errors, coding helpers.
        // Not a product: consumers get it through the API targets,
        // which re-export it (`@_exported import SolarEdgeCore`).
        .target(
            name: "SolarEdgeCore"
        ),

        // MARK: - SolarEdge ONE (basic + advanced monitoring)

        .target(
            name: "SolarEdgeONE",
            dependencies: ["SolarEdgeCore"]
        ),

        // MARK: - Designer API

        .target(
            name: "SolarEdgeDesigner",
            dependencies: ["SolarEdgeCore"]
        ),

        // MARK: - Umbrella (just re-exports the other three)

        .target(
            name: "SolarEdgeKit",
            dependencies: [
                "SolarEdgeCore",
                "SolarEdgeONE",
                "SolarEdgeDesigner",
            ]
        ),

        // MARK: - Tests

        .testTarget(
            name: "SolarEdgeCoreTests",
            dependencies: ["SolarEdgeCore"]
        ),
        .testTarget(
            name: "SolarEdgeONETests",
            dependencies: ["SolarEdgeONE", "SolarEdgeCore"]
        ),
        .testTarget(
            name: "SolarEdgeDesignerTests",
            dependencies: ["SolarEdgeDesigner", "SolarEdgeCore"]
        ),

        // Opt-in tests against the real API. Every test is skipped unless
        // its environment variables are set; see "Live tests" in the README.
        .testTarget(
            name: "SolarEdgeLiveTests",
            dependencies: ["SolarEdgeKit", "SolarEdgeCore"]
        ),
    ]
)
