import Testing
import SolarEdgeONE

/// The enums whose values the server owns: every known case survives a
/// round trip through its raw value, and anything else becomes `.unknown`.
struct OpenEnumTests {

    func roundTrips<T: RawRepresentable & CaseIterable & Equatable>(_: T.Type) where T.RawValue == String {
        for value in T.allCases {
            #expect(T(rawValue: value.rawValue) == value)
        }
        #expect(Set(T.allCases.map(\.rawValue)).count == T.allCases.count, "duplicate raw values in \(T.self)")
    }

    @Test
    func knownValuesRoundTrip() {
        roundTrips(Monitoring.AlertStatus.self)
        roundTrips(Monitoring.DeviceType.self)
        roundTrips(Monitoring.CommunicationType.self)
        roundTrips(Monitoring.InverterMode.self)
        roundTrips(Monitoring.PowerFlowStorage.Status.self)
        roundTrips(Monitoring.PowerFlowGrid.Status.self)
        roundTrips(Monitoring.BatteryBackupReserve.Status.self)
    }

    @Test
    func otherValuesBecomeUnknown() {
        #expect(Monitoring.DeviceType(rawValue: "TOASTER") == .unknown("TOASTER"))
        #expect(Monitoring.DeviceType.unknown("TOASTER").rawValue == "TOASTER")
        #expect(Monitoring.InverterMode(rawValue: "LOCKED_PHASE_BALNCER") == .lockedPhaseBalancer)
        #expect(!Monitoring.DeviceType.allCases.contains(.unknown("TOASTER")))
    }
}
