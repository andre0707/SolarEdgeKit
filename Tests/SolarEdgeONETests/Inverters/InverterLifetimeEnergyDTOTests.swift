import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Decodes the spec's lifetime energy examples.
struct InverterLifetimeEnergyDTOTests {

    @Test
    func mapsSingleInverterResponseToMeasurements() throws {
        let json = """
        {"period":{"from":"2026-01-01T00:00:00Z","to":"2026-01-01T00:30:00Z"},"unit":"WH","resolution":"QUARTER_HOUR",
         "lifetimeEnergy":[{"timestamp":"2026-01-01T00:03:30Z","value":48341},{"timestamp":"2026-01-01T00:18:30Z","value":48343.5}]}
        """
        let lifetime = try JSONDecoder().decode(InverterLifetimeEnergyResponseDTO.self, from: Data(json.utf8)).entity

        #expect(lifetime.unit == .wattHour)
        #expect(lifetime.resolution == .quarterHour)
        #expect(lifetime.values.map(\.value) == [48341, 48343.5])
        // 2026-01-01T00:03:30Z
        #expect(lifetime.values.first?.timestamp == Date(timeIntervalSince1970: 1_767_225_810))
    }

    @Test
    func keepsInvertersWithoutReadings() throws {
        let json = """
        {"inverters":[
          {"serialNumber":"7E1234B5-67","lifetimeEnergy":[{"timestamp":"2026-01-01T00:03:30Z","value":48341}],"unit":"WH"},
          {"serialNumber":"7E1234B5-68","lifetimeEnergy":[],"unit":"WH"}]}
        """
        let inverters = try JSONDecoder().decode(SiteInverterLifetimeEnergyResponseDTO.self, from: Data(json.utf8)).entity

        #expect(inverters.map(\.serialNumber) == ["7E1234B5-67", "7E1234B5-68"])
        #expect(inverters[1].values.isEmpty)
    }

    @Test
    func rejectsANonEnergyUnit() {
        let json = """
        {"inverters":[{"serialNumber":"A","lifetimeEnergy":[],"unit":"W"}]}
        """

        #expect(throws: SolarEdgeError.self) {
            try JSONDecoder().decode(SiteInverterLifetimeEnergyResponseDTO.self, from: Data(json.utf8)).entity
        }
    }
}
