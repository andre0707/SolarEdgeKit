import Testing
import SolarEdgeONE

struct ActivationStatusTests {

    @Test(arguments: [("ACTIVE", Monitoring.ActivationStatus.active), ("PENDING", .pending)])
    func knownValuesRoundTrip(rawValue: String, status: Monitoring.ActivationStatus) {
        #expect(Monitoring.ActivationStatus(rawValue: rawValue) == status)
        #expect(status.rawValue == rawValue)
    }

    /// Unknown values are kept instead of turning into `.pending`.
    @Test(arguments: ["DEACTIVATED", "active", ""])
    func unknownValuesAreKept(_ rawValue: String) {
        let status = Monitoring.ActivationStatus(rawValue: rawValue)

        #expect(status == .unknown(rawValue))
        #expect(status.rawValue == rawValue)
    }
}
