import Testing
import Foundation
@testable import SolarEdgeONE
import SolarEdgeCore

struct SiteConfigurationTests {

    @Test
    func paths() {
        #expect(WeatherGuardEndpoint(siteID: 93082).path == "sites/93082/weather-guard")
        #expect(BatteryBackupReserveEndpoint(siteID: 93082).path == "sites/93082/backup-reserve")
        #expect(WeatherGuardEndpoint(siteID: 93082).supportedAuthentication == [.apiKey, .bearerToken])
        #expect(BatteryBackupReserveEndpoint(siteID: 93082).queryItems.isEmpty)
    }

    @Test(arguments: [true, false])
    func weatherGuard(_ status: Bool) throws {
        let dto = try JSONDecoder().decode(WeatherGuardDTO.self, from: Data(#"{"status":\#(status)}"#.utf8))

        #expect(dto.entity == Monitoring.WeatherGuard(isEnabled: status))
    }

    @Test
    func backupReserve() throws {
        let enabled = try JSONDecoder().decode(BatteryBackupReserveDTO.self, from: Data(#"{"percentage":30,"backupReserveStatus":"ENABLED"}"#.utf8)).entity
        let disabled = try JSONDecoder().decode(BatteryBackupReserveDTO.self, from: Data(#"{"percentage":null,"backupReserveStatus":"DISABLED"}"#.utf8)).entity

        #expect(enabled == Monitoring.BatteryBackupReserve(percentage: 30, status: .enabled))
        #expect(disabled == Monitoring.BatteryBackupReserve(percentage: nil, status: .disabled))
    }

    /// A status added on the server is kept, not a decoding error.
    @Test
    func backupReserveKeepsUnknownStatus() throws {
        let dto = try JSONDecoder().decode(BatteryBackupReserveDTO.self, from: Data(#"{"percentage":30,"backupReserveStatus":"PAUSED"}"#.utf8))

        #expect(try dto.entity.status == .unknown("PAUSED"))
    }
}
