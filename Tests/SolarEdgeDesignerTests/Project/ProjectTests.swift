import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeDesigner
import SolarEdgeCore

/// The spec's required values for a new project.
let exampleProject = Designer.ProjectParameters(
    name: "Test Project", longitude: 7.2561046, latitude: 51.6123927, countryCode: "DE",
    oversizing: 1.1, systemType: .threePhase
)

/// The spec's layout examples, combined.
let exampleLayout = Designer.PvLayout(
    polygons: [.init(vertices: [.init(x: 0, y: -15, z: 5), .init(x: 15, y: -15, z: 5.2), .init(x: 15, y: 3, z: 5.2), .init(x: 0, y: 3, z: 5)])],
    obstacles: [.init(rectangle: .init(centerX: 2, centerY: 5, width: 0.5, height: 0.8, rotation: 0), height: 10)],
    moduleModels: [.init(manufacturer: "Astom AG", model: "ASH 195M-72")],
    moduleGroups: [.init(modelIndex: 0, polygonIndex: 0, rows: 10, columns: 10, x: 1, y: 1, orientation: .portrait,
                         rackingType: .tilted, tilt: 30, azimuth: 270, deletedModules: [.init(row: 1, column: 1)])]
)

struct ProjectEndpointTests {

    @Test
    func pathsAndMethodsMatchTheSpec() {
        let create = CreateProjectEndpoint(parameters: ProjectParamsDTO(exampleProject.asUpdate))
        let update = UpdateProjectEndpoint(siteID: 1371991379163700, parameters: ProjectParamsDTO(Designer.ProjectUpdate()))

        #expect(create.path == "project")
        #expect(create.method == .post)
        #expect(update.path == "project/1371991379163700")
        #expect(update.method == .put)
        #expect(create.supportedAuthentication == [.apiKey, .bearerToken])
        #expect(update.supportedAuthentication == [.apiKey, .bearerToken])
    }

    func json(_ dto: ProjectParamsDTO) throws -> [String: Any] {
        try #require(JSONSerialization.jsonObject(with: JSONEncoder().encode(dto)) as? [String: Any])
    }

    @Test
    func createBodyHasOnlyTheSetKeys() throws {
        let body = try json(ProjectParamsDTO(exampleProject.asUpdate))

        #expect(Set(body.keys) == ["name", "longitude", "latitude", "countryCode", "oversizing", "systemType"])
        #expect(body["systemType"] as? String == "3Phase")
    }

    @Test
    func emptyUpdateSendsAnEmptyObject() throws {
        #expect(try json(ProjectParamsDTO(Designer.ProjectUpdate())).isEmpty)
    }

    /// Snake-case keys and arrays for points, as in the spec.
    @Test
    func layoutUsesTheSpecShape() throws {
        var project = exampleProject
        project.pvLayout = exampleLayout
        project.externalID = "crm-42"
        project.address = .init(city: "Fernwald")

        let body = try json(ProjectParamsDTO(project.asUpdate))
        let layout = try #require(body["pvLayoutConfig"] as? [String: Any])
        let polygon = try #require((layout["polygons"] as? [[String: Any]])?.first)
        let obstacle = try #require((layout["obstacles"] as? [[String: Any]])?.first)
        let model = try #require((layout["moduleModels"] as? [[String: Any]])?.first)
        let group = try #require((layout["moduleGroups"] as? [[String: Any]])?.first)

        #expect(body["externalId"] as? String == "crm-42")
        #expect(body["address"] as? [String: String] == ["city": "Fernwald"])
        #expect((polygon["vertices"] as? [[Double]])?.first == [0, -15, 5])
        #expect((obstacle["rectangle"] as? [String: Any])?["center"] as? [Double] == [2, 5])
        #expect((obstacle["rectangle"] as? [String: Any])?["size"] as? [Double] == [0.5, 0.8])
        #expect(model as? [String: String] == ["manufacturer": "Astom AG", "model": "ASH 195M-72"])
        #expect(group["model_id"] as? Int == 0)
        #expect(group["racking_type"] as? String == "tilted")
        #expect(group["orientation"] as? String == "portrait")
        #expect(group["deleted_modules"] as? [[String: Int]] == [["r": 1, "c": 1]])
        #expect(group["row_spacing"] == nil)
    }

    @Test
    func moduleModelExternalIDIsSnakeCase() throws {
        let data = try JSONEncoder().encode(PublicApiModuleModelDTO(externalId: 7, manufacturer: nil, model: nil))

        #expect(String(decoding: data, as: UTF8.self) == #"{"external_id":7}"#)
    }

    @Test
    func mapsTheResponse() throws {
        let dto = try JSONDecoder().decode(PublicApiResponseDTO.self, from: Data(
            #"{"site_id":1371991379163700,"site_url":"https://designer.solaredge.com/sites/1371991379163700"}"#.utf8))

        #expect(try dto.entity == Designer.ProjectSite(siteID: 1371991379163700,
                                                       siteURL: URL(string: "https://designer.solaredge.com/sites/1371991379163700")!))
    }
}

struct ProjectValidationTests {

    @Test
    func examplesAreValid() throws {
        var project = exampleProject
        project.pvLayout = exampleLayout
        try project.validate()
        try Designer.ProjectUpdate().validate()
    }

    @Test(arguments: [
        { (p: inout Designer.ProjectParameters) in p.name = "" },
        { p in p.name = String(repeating: "x", count: 49) },
        { p in p.externalID = String(repeating: "x", count: 129) },
        { p in p.longitude = -181 },
        { p in p.countryCode = " " },
        { p in p.monthlyBill = -1 },
        { p in p.consumptionProfile = Array(repeating: 1 / 8760, count: 8760) },   // without consumption
        { p in p.oversizing = 3 },
        { p in p.pvModuleSetup = [.init(pvModuleID: 1, pvModuleCount: 0, panelDirection: .init(azimuth: 0, tilt: 0), mountType: .tilted)] },
        { p in p.shadingFactor = -0.1 },
    ] as [@Sendable (inout Designer.ProjectParameters) -> Void])
    func invalidProjectIsRejected(_ change: @Sendable (inout Designer.ProjectParameters) -> Void) {
        var project = exampleProject
        change(&project)

        #expect(throws: SolarEdgeError.self) { try project.validate() }
    }

    @Test(arguments: [
        { (l: inout Designer.PvLayout) in l.polygons[0].vertices.removeLast(2) },
        { l in l.obstacles[0].rectangle.width = 0 },
        { l in l.obstacles[0].rectangle.rotation = 360 },
        { l in l.moduleModels[0] = .init(manufacturer: "Astom AG") },
        { l in l.moduleGroups[0].modelIndex = 1 },
        { l in l.moduleGroups[0].polygonIndex = -1 },
        { l in l.moduleGroups[0].rows = 0 },
        { l in l.moduleGroups[0].columns = 1025 },
        { l in l.moduleGroups[0].tilt = 91 },
        { l in l.moduleGroups[0].frameRows = 65 },
        { l in l.moduleGroups[0].rackingType = .dualTilted },   // without ridge direction and dome spacing
        { l in l.moduleGroups[0].deletedModules = [.init(row: -1, column: 0)] },
    ] as [@Sendable (inout Designer.PvLayout) -> Void])
    func invalidLayoutIsRejected(_ change: @Sendable (inout Designer.PvLayout) -> Void) {
        var layout = exampleLayout
        change(&layout)

        #expect(throws: SolarEdgeError.self) { try layout.validate() }
    }

    /// The external ID goes into the JSON body, so only the spec's length
    /// limit applies; a CRM ID with slashes is fine.
    @Test
    func externalIDWithSlashesIsValid() throws {
        var project = exampleProject
        project.externalID = "A/2024/17"

        try project.validate()
        try Designer.ProjectUpdate(externalID: "../x").validate()
    }

    @Test
    func dualTiltedWithRidgeAndDomeIsValid() throws {
        var layout = exampleLayout
        layout.moduleGroups[0].rackingType = .dualTilted
        layout.moduleGroups[0].ridgeDirection = 90
        layout.moduleGroups[0].domeSpacing = 2

        try layout.validate()
    }

    @Test
    func moduleModelByExternalIDAloneIsValid() throws {
        var layout = exampleLayout
        layout.moduleModels = [.init(externalID: 19676)]

        try layout.validate()
    }

    /// Regenerating the electrical design needs `oversizing` and `systemType`.
    @Test
    func regeneratingUpdateNeedsOversizingAndSystemType() throws {
        let setup = Designer.PvModuleSetup(pvModuleID: 1, pvModuleCount: 10, panelDirection: .init(azimuth: 180, tilt: 30), mountType: .tilted)
        let battery = Designer.BatterySetup(batteryID: "SE_HOME_48V_3M", batteryCount: 1)

        #expect(throws: SolarEdgeError.self) { try Designer.ProjectUpdate(pvModuleSetup: [setup]).validate() }
        #expect(throws: SolarEdgeError.self) { try Designer.ProjectUpdate(pvLayout: exampleLayout, oversizing: 1.2).validate() }
        #expect(throws: SolarEdgeError.self) { try Designer.ProjectUpdate(electricalDesign: .init(inverterModel: "SE10K")).validate() }
        // Batteries regenerate unless backup is off.
        #expect(throws: SolarEdgeError.self) { try Designer.ProjectUpdate(batteries: [battery]).validate() }
        try Designer.ProjectUpdate(backup: false, batteries: [battery]).validate()
        try Designer.ProjectUpdate(pvModuleSetup: [setup], oversizing: 1.2, systemType: .singlePhase).validate()
        // Plain value changes do not.
        try Designer.ProjectUpdate(name: "Renamed", systemPrice: 20000).validate()
    }

    /// Fails the test if a request is sent.
    struct NoRequestTransport: HTTPTransport {
        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            Issue.record("No request expected, got \(request.url!)")
            throw SolarEdgeError.invalidResponse
        }
    }

    @Test
    func invalidValuesAreRejectedBeforeSending() async {
        let projects = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL,
                                               transport: NoRequestTransport()).projects
        var project = exampleProject
        project.name = ""

        await #expect(throws: SolarEdgeError.self) { try await projects.create(project) }
        await #expect(throws: SolarEdgeError.self) { try await projects.update(5, with: .init(powerFactor: 0.5)) }
    }
}

/// Sends real requests to the Stoplight mock of the Designer API, which
/// checks the bodies against the spec and answers with its example.
/// Needs network access.
@Suite(.tags(.mockServer))
struct ProjectMockTests {

    let projects = SolarEdgeDesignerClient(credentials: .apiKey("123"), baseURL: DesignerMockServer.baseURL).projects
    let expected = Designer.ProjectSite(siteID: 1371991379163700, siteURL: URL(string: "https://designer.solaredge.com/sites/1371991379163700")!)

    @Test
    func createWithRequiredValues() async throws {
        #expect(try await projects.create(exampleProject) == expected)
    }

    @Test
    func createWithLayoutAndOptionalValues() async throws {
        var project = exampleProject
        project.externalID = "crm-42"
        project.createdBy = "owner@example.com"
        project.stateCode = "HE"
        project.address = .init(street: "Main St 1", city: "Fernwald", zipCode: "35463")
        project.gridID = "230"
        project.monthlyBill = 300
        project.consumptionProfileID = "double_peak"
        project.exportLimit = 5000
        project.powerFactor = 1
        project.pvLayout = exampleLayout
        project.backup = true
        project.batteries = [.init(batteryID: "SE_HOME_48V_3M", batteryCount: 1)]
        project.electricalDesign = .init(inverterModel: "SE10K", optimizerModel: "S440")
        project.incentives = [6393815952735273]
        project.utilityImportRateID = 1
        project.utilityExportRateID = 2
        project.systemPrice = 50000
        project.pricePerWatt = 0.0005
        project.systemLifetime = .init(years: 25)
        project.shadingFactor = 0
        project.useBatteryManagementAlgorithm = false

        #expect(try await projects.create(project) == expected)
    }

    @Test
    func update() async throws {
        #expect(try await projects.update(1371991379163700, with: .init(name: "Renamed")) == expected)
        _ = try await projects.update(5, with: .init())
    }

    @Test
    func acceptsADesignerKeyAsBearerToken() async throws {
        let projects = SolarEdgeDesignerClient(credentials: .bearerToken(StaticTokenProvider(token: "123")),
                                               baseURL: DesignerMockServer.baseURL).projects

        _ = try await projects.create(exampleProject)
    }
}
