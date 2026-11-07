import Testing
import Foundation
@testable import SolarEdgeDesigner
import SolarEdgeCore

struct EstimationDTOTests {

    func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }

    @Test
    func mapsTheSimpleLookups() throws {
        #expect(try decode(BatteryDTO.self, #"{"id":"bat-1","capacity":9700,"displayName":"Home Battery"}"#).entity
                == Designer.Battery(id: "bat-1", capacity: 9700, displayName: "Home Battery"))
        #expect(try decode(ConsumptionProfileDTO.self, #"{"id":"p1","name":"Family"}"#).entity
                == Designer.ConsumptionProfile(id: "p1", name: "Family"))
        #expect(try decode(GridCodeDTO.self, #"{"id":"g1","name":"Grid","onePhaseVoltage":230,"threePhaseVoltage":400}"#).entity
                == Designer.GridCode(id: "g1", name: "Grid", onePhaseVoltage: 230, threePhaseVoltage: 400))
        #expect(try decode(PvModuleDTO.self, #"{"id":12,"manufacturer":"Maker","model":"M-400","stcPower":400.5}"#).entity
                == Designer.PvModule(id: 12, manufacturer: "Maker", model: "M-400", stcPower: 400.5))
        #expect(try decode(UtilityProviderDTO.self, #"{"name":"Utility Company 1"}"#).entity
                == Designer.UtilityProvider(name: "Utility Company 1"))
        #expect(try decode(IncentiveDTO.self, #"{"id":5,"name":"Rebate","summary":"Short"}"#).entity
                == Designer.Incentive(id: 5, name: "Rebate", summary: "Short"))
    }

    @Test
    func mapsAUtilityRate() throws {
        let rate = try decode(UtilityRateDTO.self, #"{"id":3,"utilityName":"U","name":"R","rateType":"IMPORT_RATE","effectiveDate":"2019-08-24"}"#).entity

        #expect(rate == Designer.UtilityRate(id: 3, utilityName: "U", name: "R", rateType: .import,
                                             effectiveDate: CalendarDate(year: 2019, month: 8, day: 24)!))
    }

    /// `ALL` is only a filter value, never a rate's type.
    @Test(arguments: ["ALL", "export_rate"])
    func rejectsAnUnknownRateType(_ rateType: String) throws {
        let dto = try decode(UtilityRateDTO.self, #"{"id":3,"utilityName":"U","name":"R","rateType":"\#(rateType)","effectiveDate":"2019-08-24"}"#)

        #expect(throws: SolarEdgeError.self) { try dto.entity }
    }

    @Test
    func rejectsAnInvalidEffectiveDate() throws {
        let dto = try decode(UtilityRateDTO.self, #"{"id":3,"utilityName":"U","name":"R","rateType":"EXPORT_RATE","effectiveDate":"24.08.2019"}"#)

        #expect(throws: SolarEdgeError.self) { try dto.entity }
    }
}
