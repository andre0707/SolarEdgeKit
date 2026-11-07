import Testing
import Foundation
@testable import SolarEdgeDesigner
import SolarEdgeCore

struct ReportDataDTOTests {

    func json(optimizerType: String = "S_SERIES", mountingType: String = "TILTED", itemType: String = "SMART_METER") -> String {
        let item = #"{"id":7,"type":"\#(itemType)","modelId":"m","itemNameKey":"k","itemName":"Meter","itemCount":2,"cost":10.5,"notes":"n"}"#
        return """
        {"siteReport":{
           "overview":{"pvModules":20,"inverters":1,"optimizers":10,"orientations":2,"batteries":1,"optimizerGeneralType":"\(optimizerType)"},
           "simulationResults":{"installedPower":8.2,"maxAchievedDcPower":8.0,"actualAchievedOversizing":1.1,"maxActiveAcPower":7000,
             "maxAchievedAcPower":6900,"maxActiveApparentPower":7000,"annualEnergy":9000.5,"nonSeInverterAnnualEnergy":0,
             "annualApparentEnergy":9100,"annualReactiveEnergy":100,"maxReactivePower":500,"performanceRatio":0.85,
             "performanceIndex":0.9,"co2EmissionSaved":4.2,"equivalentTreesPlanted":70},
           "estimatedMonthlyEnergy":[{"produced":500,"clipped":1,"selfConsumed":300,"consumed":400,"monthInEnglish":"January"}],
           "pvModules":[{"modulesCount":20,"moduleName":"M-410","power":410,"mountingType":"\(mountingType)","moduleOrientation":"LANDSCAPE",
             "absoluteAzimuth":180,"absoluteTilt":30,"userDefined":false}],
           "billOfMaterials":{"inverters":[],"optimizers":[],"batteries":[],"modules":[],"custom":[\(item)],"rackingSets":[],"caulkingBottles":[],"moduleCovers":[]},
           "numOfImages":3},
         "siteDetails":{"customerDetails":{"firstName":"Ada","lastName":"Lovelace","company":"Engines Ltd"},"country":"US","state":"NY",
           "city":"New York","street":"Main St 1","name":"Home","zipCode":"10001","grid":"g1","currency":"USD","id":1371991379163700}}
        """
    }

    func decode(_ json: String) throws -> ReportDataDTO {
        try JSONDecoder().decode(ReportDataDTO.self, from: Data(json.utf8))
    }

    @Test
    func mapsAFullReport() throws {
        let data = try decode(json()).entity
        let report = data.siteReport

        #expect(report.overview.optimizerGeneralType == .sSeries)
        #expect(report.overview.pvModules == 20)
        #expect(report.simulationResults.annualEnergy == 9000.5)
        #expect(report.simulationResults.maxReactivePower == 500)
        #expect(report.estimatedMonthlyEnergy.map(\.monthInEnglish) == ["January"])
        #expect(report.pvModules.first?.mountingType == .tilted)
        #expect(report.pvModules.first?.moduleOrientation == .landscape)
        #expect(report.billOfMaterials.custom == [Designer.SiteReport.BillOfMaterials.Item(
            id: 7, type: .smartMeter, modelId: "m", itemNameKey: "k", itemName: "Meter", itemCount: 2, cost: 10.5, notes: "n")])
        #expect(report.billOfMaterials.inverters.isEmpty)
        #expect(report.numOfImages == 3)
        #expect(data.siteDetails.id == 1371991379163700)
        #expect(data.siteDetails.customerDetails.company == "Engines Ltd")
        #expect(data.siteDetails.currency == "USD")
    }

    /// Catalogue values added on the server are kept ...
    @Test
    func keepsUnknownCatalogueValues() throws {
        let report = try decode(json(optimizerType: "OTHER", itemType: "TOASTER")).entity.siteReport

        #expect(report.overview.optimizerGeneralType == .unknown("OTHER"))
        #expect(report.billOfMaterials.custom.first?.type == .unknown("TOASTER"))
    }

    /// ... but the mounting type is a closed set and stays strict.
    @Test
    func rejectsAnUnknownMountingType() throws {
        #expect(throws: SolarEdgeError.self) { try decode(json(mountingType: "flat")).entity }
    }
}
