import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Decodes the spec's Site Meter Lifetime Energy example.
struct MeterLifetimeEnergyDTOTests {

    @Test
    func mapsOneListPerDirection() throws {
        let json = """
        {"meters":[
          {"serialNumber":"2644513869","productionEnergy":[],"consumptionEnergy":[],
           "importEnergy":[{"timestamp":"2026-01-01T00:03:28Z","value":4489559},{"timestamp":"2026-01-01T00:18:28Z","value":4489617}],
           "exportEnergy":[{"timestamp":"2026-01-01T00:03:28Z","value":3932472},{"timestamp":"2026-01-01T00:18:28Z","value":3932472}],
           "unit":"WH"},
          {"serialNumber":"617887617",
           "productionEnergy":[{"timestamp":"2026-01-01T00:03:28Z","value":6198740},{"timestamp":"2026-01-01T00:18:28Z","value":6198828}],
           "consumptionEnergy":[],"importEnergy":[],"exportEnergy":[],"unit":"WH"}]}
        """
        let meters = try JSONDecoder().decode(MeterLifetimeEnergyResponseDTO.self, from: Data(json.utf8)).entity

        #expect(meters.map(\.serialNumber) == ["2644513869", "617887617"])
        let grid = meters[0]
        #expect(grid.unit == .wattHour)
        #expect(grid.productionEnergy.isEmpty)
        #expect(grid.importEnergy.map(\.value) == [4489559, 4489617])
        #expect(grid.exportEnergy.map(\.value) == [3932472, 3932472])
        // 2026-01-01T00:03:28Z
        #expect(grid.importEnergy.first?.timestamp == Date(timeIntervalSince1970: 1_767_225_808))
        #expect(meters[1].productionEnergy.map(\.value) == [6198740, 6198828])
        #expect(meters[1].importEnergy.isEmpty)
    }

    @Test
    func rejectsANonEnergyUnit() {
        let json = """
        {"meters":[{"serialNumber":"A","productionEnergy":[],"consumptionEnergy":[],"importEnergy":[],"exportEnergy":[],"unit":"W"}]}
        """

        #expect(throws: SolarEdgeError.self) {
            try JSONDecoder().decode(MeterLifetimeEnergyResponseDTO.self, from: Data(json.utf8)).entity
        }
    }
}
