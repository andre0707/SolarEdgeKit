import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct PowerFlowDTOTests {

    func decode(updatedAt: String = #""2026-05-25T20:51:59+02:00""#, refreshRate: Int = 300, unit: String = "kW",
                storage: String = #"{"active":true,"power":0.27,"status":"DISCHARGE","chargeLevel":96}"#,
                grid: String = #"{"active":true,"power":0.02,"status":"IMPORT"}"#) throws -> Monitoring.PowerFlow {
        let json = """
        {"updatedAt":\(updatedAt),"refreshRate":\(refreshRate),"unit":"\(unit)",
         "pv":{"active":true,"power":0.02},"load":{"active":true,"power":0.31},
         "storage":\(storage),"grid":\(grid)}
        """
        return try JSONDecoder().decode(SitePowerFlowDTO.self, from: Data(json.utf8)).entity
    }

    /// The spec's example.
    @Test
    func mapsTheSpecExample() throws {
        let flow = try decode()

        #expect(flow.updatedAt == Date(timeIntervalSince1970: 1_779_735_119))    // 2026-05-25T20:51:59+02:00
        #expect(flow.refreshRate == 300)
        #expect(!flow.isLive)
        #expect(flow.unit == .kiloWatt)
        #expect(flow.pv == Monitoring.PowerFlowNode(active: true, power: 0.02))
        #expect(flow.load == Monitoring.PowerFlowNode(active: true, power: 0.31))
        #expect(flow.storage == Monitoring.PowerFlowStorage(active: true, power: 0.27, status: .discharge, chargeLevel: 96))
        #expect(flow.grid == Monitoring.PowerFlowGrid(active: true, power: 0.02, status: .import))
    }

    @Test
    func aShortRefreshRateMeansLive() throws {
        #expect(try decode(refreshRate: 3).isLive)
    }

    /// This endpoint writes `kW`; plain `W` and the other endpoints' `KW` also work.
    @Test(arguments: [("W", Monitoring.Power.watt), ("kW", .kiloWatt), ("KW", .kiloWatt)])
    func mapsTheUnit(raw: String, unit: Monitoring.Power) throws {
        #expect(try decode(unit: raw).unit == unit)
    }

    /// The nullable fields of the spec.
    @Test
    func acceptsNulls() throws {
        let flow = try decode(updatedAt: "null",
                              storage: #"{"active":false,"power":null,"status":null,"chargeLevel":null}"#,
                              grid: #"{"active":false,"power":null,"status":"GRID_OUTAGE"}"#)

        #expect(flow.updatedAt == nil)
        #expect(flow.storage == Monitoring.PowerFlowStorage(active: false, power: nil, status: nil, chargeLevel: nil))
        #expect(flow.grid.status == .gridOutage)
    }

    /// An unknown unit makes the numbers meaningless, so it throws ...
    @Test
    func rejectsAnUnknownUnit() {
        #expect(throws: SolarEdgeError.self) { try decode(unit: "mW") }
    }

    /// ... while a status added on the server is kept.
    @Test
    func keepsUnknownStatuses() throws {
        let flow = try decode(storage: #"{"active":true,"power":1,"status":"BALANCING","chargeLevel":50}"#,
                              grid: #"{"active":true,"power":1,"status":"SIDEWAYS"}"#)

        #expect(flow.storage.status == .unknown("BALANCING"))
        #expect(flow.grid.status == .unknown("SIDEWAYS"))
    }
}
