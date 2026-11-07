import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

/// Decodes devices as the spec describes them, including the fields it
/// documents as omitted.
struct DeviceDataDTOTests {

    func decode(_ json: String) throws -> Monitoring.Device {
        try JSONDecoder().decode(DeviceDataDTO.self, from: Data(json.utf8)).entity
    }

    /// A top-level inverter: no parent, so no `connectedToName`, and no meter fields.
    @Test
    func decodesTopLevelInverterWithoutOmittedFields() throws {
        let device = try decode("""
        {"type":"INVERTER","serialNumber":"7E140000-AB","manufacturer":"SolarEdge","model":"SE5000H",
         "partNumber":null,"powerModel":"SE5K","createdAt":"2026-10-01T13:30:00+03:00",
         "firmwareVersion":"4.25","firmware":"4.25.15.1.100.2059.2.100.1751","connectedTo":null,
         "parent":null,"active":true,"nameplate":5000,"name":"Inverter 1",
         "form":null,"communicationType":"ETHERNET","connectedOptimizers":16}
        """)

        #expect(device.type == .inverter)
        #expect(device.createdAt == Date(timeIntervalSince1970: 1_790_850_600))
        #expect(device.parent == nil)
        #expect(device.connectedToName == nil)
        #expect(device.meterType == nil)
        #expect(device.communicationType == .ethernet)
        #expect(device.connectedOptimizers == 16)
    }

    /// A meter connected to an inverter: has a parent and the meter fields.
    @Test
    func decodesMeterWithParent() throws {
        let device = try decode("""
        {"type":"METER","serialNumber":"M-1","manufacturer":"SolarEdge","model":"Energy Meter",
         "partNumber":"SE-MTR","powerModel":"","createdAt":"2026-10-01T13:30:00+03:00",
         "firmwareVersion":null,"firmware":null,"connectedTo":"7E140000-AB","connectedToName":"Inverter 1",
         "parent":{"serialNumber":"7E140000-AB","type":"INVERTER","name":"Inverter 1"},
         "active":true,"nameplate":null,"name":"Meter","meterType":"FeedIn","form":"physical",
         "communicationType":null,"connectedOptimizers":null}
        """)

        #expect(device.type == .meter)
        #expect(device.parent == Monitoring.DeviceParent(serialNumber: "7E140000-AB", type: .inverter, name: "Inverter 1"))
        #expect(device.connectedToName == "Inverter 1")
        #expect(device.meterType == "FeedIn")
        #expect(device.form == "physical")
        #expect(device.communicationType == nil)
    }

    /// Types added on the server are kept, not a decoding error. The API's
    /// own `UNKNOWN` communication type lands in the same case.
    @Test
    func keepsUnknownTypes() throws {
        let device = try decode("""
        {"type":"TOASTER","serialNumber":"X","manufacturer":"","model":"","powerModel":"",
         "createdAt":"2026-10-01T13:30:00+03:00","active":true,"name":"","communicationType":"UNKNOWN"}
        """)

        #expect(device.type == .unknown("TOASTER"))
        #expect(device.type.rawValue == "TOASTER")
        #expect(device.communicationType == .unknown("UNKNOWN"))
    }
}
