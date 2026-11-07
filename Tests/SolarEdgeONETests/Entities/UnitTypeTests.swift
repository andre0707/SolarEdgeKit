import Testing
@testable import SolarEdgeONE

/// Every unit in the spec's `Measurements.unit` enum maps to exactly one unit type.
struct UnitTypeTests {

    @Test
    func coversAllMeasurementUnitsInTheSpec() {
        let specUnits: Set<String> = [
            "W", "KW", "MW",
            "WH", "KWH", "MWH",
            "PERCENTAGE", "PERCENTAGE_100",
            "VOLT", "AMPERE", "HERTZ",
        ]

        let rawValues = Monitoring.Power.allCases.map(\.rawValue)
            + Monitoring.Energy.allCases.map(\.rawValue)
            + Monitoring.Percentage.allCases.map(\.rawValue)
            + Monitoring.Voltage.allCases.map(\.rawValue)
            + Monitoring.ElectricCurrent.allCases.map(\.rawValue)
            + Monitoring.Frequency.allCases.map(\.rawValue)

        // Energy also has GWH (Site Overview), Power also GW (Advanced
        // Monitoring per destination).
        #expect(Set(rawValues) == specUnits.union(["GWH", "GW"]))
        #expect(rawValues.count == Set(rawValues).count)
    }
}
