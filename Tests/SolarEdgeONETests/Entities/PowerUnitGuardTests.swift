import Testing
import Foundation
import SolarEdgeONE

/// The Basic Monitoring power endpoints accept W, KW and MW, but not GW.
/// All of these fail before any request is made, so no network is needed.
struct PowerUnitGuardTests {
    let client = SolarEdgeONEClient(credentials: .apiKey("123"), baseURL: MockServer.baseURL)

    @Test
    func basicPowerEndpointsRejectGigaWatt() async {
        let requests: [() async throws -> Monitoring.Measurements<Monitoring.Power>] = [
            { try await client.sites.power(for: 1, unit: .gigaWatt) },
            { try await client.inverters.power(for: 1, serialNumber: "A", unit: .gigaWatt) },
            { try await client.inverters.consumedAcPower(for: 1, serialNumber: "A", unit: .gigaWatt) },
            { try await client.meters.productionPower(for: 1, serialNumber: "A", unit: .gigaWatt) },
            { try await client.meters.consumptionPower(for: 1, serialNumber: "A", unit: .gigaWatt) },
            { try await client.meters.importPower(for: 1, serialNumber: "A", unit: .gigaWatt) },
            { try await client.meters.exportPower(for: 1, serialNumber: "A", unit: .gigaWatt) },
            { try await client.batteries.chargePower(for: 1, serialNumber: "A", unit: .gigaWatt) },
            { try await client.batteries.dischargePower(for: 1, serialNumber: "A", unit: .gigaWatt) },
        ]

        for request in requests {
            do {
                _ = try await request()
                Issue.record("Expected GW to be rejected")
            } catch SolarEdgeError.invalidRequest(let reason) {
                #expect(reason.contains("GW"))
            } catch {
                Issue.record(error)
            }
        }
    }
}
