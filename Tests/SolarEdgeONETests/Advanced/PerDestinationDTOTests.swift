import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct PerDestinationDTOTests {

    func json(productionUnit: String, consumptionUnit: String) -> String {
        """
        {"siteId":49212,
         "production":{"unit":"\(productionUnit)","values":[{"timestamp":"2022-11-14T11:30:00Z","total":18.01,"toSelfConsumption":9.98,"toStorage":7.96,"toGrid":0.07}]},
         "consumption":{"unit":"\(consumptionUnit)","values":[{"timestamp":"2022-11-14T11:30:00Z","total":20.41,"fromPv":9.98,"fromStorage":10.01,"fromGrid":0.42}]}}
        """
    }

    /// The spec's example for power per destination.
    @Test
    func mapsThePowerExample() throws {
        let result = try JSONDecoder().decode(PowerPerDestinationDTO.self, from: Data(json(productionUnit: "KW", consumptionUnit: "KW").utf8)).entity

        #expect(result.siteID == 49212)
        #expect(result.production.unit == .kiloWatt)
        #expect(result.production.values == [Monitoring.ProductionBreakdown(
            timestamp: Date(timeIntervalSince1970: 1_668_425_400),    // 2022-11-14T11:30:00Z
            total: 18.01, toSelfConsumption: 9.98, toStorage: 7.96, toGrid: 0.07
        )])
        #expect(result.consumption.values == [Monitoring.ConsumptionBreakdown(
            timestamp: Date(timeIntervalSince1970: 1_668_425_400),
            total: 20.41, fromPv: 9.98, fromStorage: 10.01, fromGrid: 0.42
        )])
    }

    /// The Advanced API can return GW and GWH.
    @Test
    func acceptsGigaUnits() throws {
        let power = try JSONDecoder().decode(PowerPerDestinationDTO.self, from: Data(json(productionUnit: "GW", consumptionUnit: "MW").utf8)).entity
        let energy = try JSONDecoder().decode(EnergyPerDestinationDTO.self, from: Data(json(productionUnit: "GWH", consumptionUnit: "KWH").utf8)).entity

        #expect(power.production.unit == .gigaWatt)
        #expect(power.consumption.unit == .megaWatt)
        #expect(energy.production.unit == .gigaWattHour)
        #expect(energy.consumption.unit == .kiloWattHour)
    }

    @Test
    func rejectsAnEnergyUnitForPower() {
        #expect(throws: SolarEdgeError.self) {
            try JSONDecoder().decode(PowerPerDestinationDTO.self, from: Data(json(productionUnit: "KWH", consumptionUnit: "KW").utf8)).entity
        }
    }
}
