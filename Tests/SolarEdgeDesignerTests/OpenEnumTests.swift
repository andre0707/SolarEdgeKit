import Testing
import SolarEdgeDesigner

/// The Designer enums whose values the server owns: every known case
/// survives a round trip through its raw value, and anything else becomes
/// `.unknown`.
struct DesignerOpenEnumTests {

    func roundTrips<T: RawRepresentable & CaseIterable & Equatable>(_: T.Type) where T.RawValue == String {
        for value in T.allCases {
            #expect(T(rawValue: value.rawValue) == value)
        }
        #expect(Set(T.allCases.map(\.rawValue)).count == T.allCases.count, "duplicate raw values in \(T.self)")
    }

    @Test
    func knownValuesRoundTrip() {
        roundTrips(Designer.AutoDesignStatus.ErrorCode.self)
        roundTrips(Designer.InverterModel.InverterType.self)
        roundTrips(Designer.OptimizerModel.OptimizerType.self)
        roundTrips(Designer.OptimizerModel.MountLocation.self)
        roundTrips(Designer.BatteryModel.ConnectionType.self)
        roundTrips(Designer.SiteReport.BillOfMaterials.Item.ItemType.self)
        #expect(Designer.SiteReport.BillOfMaterials.Item.ItemType.allCases.count == 28)
    }

    @Test
    func otherValuesBecomeUnknown() {
        #expect(Designer.InverterModel.InverterType(rawValue: "HD_WAVE") == .unknown("HD_WAVE"))
        #expect(Designer.SiteReport.BillOfMaterials.Item.ItemType(rawValue: "SWITCH") == .switch)
    }
}
