import Testing
import Foundation
import SolarEdgeKit

/// Read-only calls against the real Monitoring API, for one site.
///
/// Needs `SOLAREDGE_API_KEY` and `SOLAREDGE_SITE_ID`; skipped otherwise.
/// Each call uses API credits; a full run is about 40 requests.
@Suite(.serialized, .enabled(if: LiveEnvironment.hasMonitoring, "Set SOLAREDGE_API_KEY and SOLAREDGE_SITE_ID"))
struct MonitoringLiveTests {
    let transport = InspectingTransport()
    let client: SolarEdgeONEClient
    let site: Monitoring.Site.ID

    init() throws {
        client = SolarEdgeONEClient(credentials: .apiKey(try #require(LiveEnvironment.apiKey)), transport: transport)
        site = try #require(LiveEnvironment.siteID)
    }

    /// Recent periods, within every resolution's limit.
    let now = Date()
    var sixHoursAgo: Date { now.addingTimeInterval(-6 * 3600) }
    var weekAgo: Date { now.addingTimeInterval(-7 * 86400) }

    @Test
    func siteEndpointsDecode() async {
        await Probe.run("sites.list", summary: { "\($0.sites.count) sites, totalCount \($0.totalCount.map(String.init) ?? "unknown")" }) {
            try await client.sites.list(pageSize: 5)
        }
        await Probe.run("sites.details") { try await client.sites.details(for: site) }
        await Probe.run("sites.overview") { try await client.sites.overview(for: site) }
        await Probe.run("sites.performance") { try await client.sites.performance(for: site) }
        await Probe.run("sites.power", summary: { "\($0.values.count) values" }) {
            try await client.sites.power(for: site, from: sixHoursAgo, to: now)
        }
        await Probe.run("sites.energy (day)", summary: { "\($0.values.count) values" }) {
            try await client.sites.energy(for: site, from: weekAgo, to: now, resolution: .day)
        }
        await Probe.run("sites.lifetimeEnergy") { try await client.sites.lifetimeEnergy(for: site) }
        await Probe.run("sites.externalProductionEnergy") { try await client.sites.externalProductionEnergy(for: site) }
        await Probe.run("sites.environmentalBenefits") { try await client.sites.environmentalBenefits(for: site) }
    }

    /// Real paging: `totalCount` and ``Monitoring/SiteSequence`` with a small page size.
    @Test
    func sitePaging() async {
        await Probe.run("sites.list page 1 of size 2", summary: { "\($0.sites.count) sites, totalCount \($0.totalCount.map(String.init) ?? "unknown"), mayHaveMore \($0.mayHaveMore)" }) {
            try await client.sites.list(page: 1, pageSize: 2)
        }
        let before = transport.requests
        await Probe.run("sites.all, first 5 sites", summary: { (count: Int) in "\(count) sites in \(transport.requests - before) requests" }) {
            var count = 0
            for try await _ in client.sites.all(pageSize: 2) {
                count += 1
                if count == 5 { break }
            }
            return count
        }
    }

    @Test
    func alertsDecode() async {
        await Probe.run("alerts.list for the site", summary: { "\($0.alerts.count) open alerts" }) {
            try await client.alerts.list(for: site, pageSize: 20)
        }
        await Probe.run("alerts.list for the fleet", summary: { "\($0.alerts.count) open alerts" }) {
            try await client.alerts.list(pageSize: 20)
        }
    }

    /// The inventory, then the measurement calls for the first inverter,
    /// meter and battery found.
    @Test
    func devicesAndMeasurementsDecode() async {
        let devices = await Probe.run("inventory.devices (all types)", summary: { devices in
            Dictionary(grouping: devices, by: \.type.rawValue)
                .map { "\($0.value.count) \($0.key)" }
                .sorted()
                .joined(separator: ", ")
        }) {
            try await client.inventory.devices(for: site, types: Set(Monitoring.DeviceType.allCases))
        } ?? []

        if let inverter = devices.first(where: { $0.type == .inverter })?.serialNumber {
            await Probe.run("inventory.device (an inverter)") { try await client.inventory.device(inverter, for: site) }
            await Probe.run("inverters.telemetry", summary: { "\($0.count) inverters" }) {
                try await client.inverters.telemetry(for: site, serialNumbers: [inverter], from: sixHoursAgo, to: now)
            }
            await Probe.run("inverters.status") {
                try await client.inverters.status(for: site, serialNumbers: [inverter], from: sixHoursAgo, to: now)
            }
            await Probe.run("inverters.power", summary: { "\($0.values.count) values" }) {
                try await client.inverters.power(for: site, serialNumber: inverter, from: sixHoursAgo, to: now)
            }
            await Probe.run("inverters.energy (day)", summary: { "\($0.values.count) values" }) {
                try await client.inverters.energy(for: site, serialNumber: inverter, from: weekAgo, to: now, resolution: .day)
            }
            await Probe.run("inverters.voltage", summary: { "\($0.values.count) values" }) {
                try await client.inverters.voltage(for: site, serialNumber: inverter, from: sixHoursAgo, to: now)
            }
            await Probe.run("inverters.lifetimeEnergy (one)", summary: { "\($0.values.count) values" }) {
                try await client.inverters.lifetimeEnergy(for: site, serialNumber: inverter, from: weekAgo, to: now)
            }
            await Probe.run("inverters.lifetimeEnergy (all)", summary: { "\($0.count) inverters" }) {
                try await client.inverters.lifetimeEnergy(for: site, from: weekAgo, to: now)
            }
        } else {
            print("[live] no inverter in the inventory; inverter calls skipped")
        }

        if let meter = devices.first(where: { $0.type == .meter })?.serialNumber {
            await Probe.run("meters.telemetry", summary: { "\($0.count) meters" }) {
                try await client.meters.telemetry(for: site, serialNumbers: [meter], from: sixHoursAgo, to: now)
            }
            await Probe.run("meters.lifetimeEnergy", summary: { "\($0.count) entries" }) {
                try await client.meters.lifetimeEnergy(for: site, serialNumbers: [meter], from: weekAgo, to: now)
            }
        } else {
            print("[live] no meter in the inventory; meter calls skipped")
        }

        if let battery = devices.first(where: { $0.type == .battery })?.serialNumber {
            await Probe.run("batteries.telemetry", summary: { "\($0.count) batteries" }) {
                try await client.batteries.telemetry(for: site, serialNumbers: [battery], from: sixHoursAgo, to: now)
            }
            await Probe.run("batteries.status") {
                try await client.batteries.status(for: site, serialNumbers: [battery], from: sixHoursAgo, to: now)
            }
            await Probe.run("batteries.stateOfEnergy", summary: { "\($0.values.count) values" }) {
                try await client.batteries.stateOfEnergy(for: site, serialNumber: battery, from: sixHoursAgo, to: now)
            }
            await Probe.run("batteries.lifetimeEnergy", summary: { "\($0.count) entries" }) {
                try await client.batteries.lifetimeEnergy(for: site, serialNumbers: [battery], from: weekAgo, to: now)
            }
        } else {
            print("[live] no battery in the inventory; battery calls skipped")
        }
    }

    /// Advanced Monitoring needs a Pro or Enterprise tier; a `403` is
    /// printed, not failed. Starting a live power flow session is left out:
    /// it changes the site's state.
    @Test
    func advancedEndpointsDecode() async {
        await Probe.run("advanced.powerPerDestination", summary: { "\($0.production.values.count) values" }) {
            try await client.advanced.powerPerDestination(for: site, from: sixHoursAgo, to: now)
        }
        await Probe.run("advanced.energyPerDestination (day)", summary: { "\($0.production.values.count) values" }) {
            try await client.advanced.energyPerDestination(for: site, from: weekAgo, to: now, resolution: .day)
        }
        await Probe.run("advanced.powerFlow") { try await client.advanced.powerFlow(for: site) }
        await Probe.run("advanced.weatherGuard") { try await client.advanced.weatherGuard(for: site) }
        await Probe.run("advanced.backupReserve") { try await client.advanced.backupReserve(for: site) }
    }

    /// Whether successful responses carry `x-ratelimit-*` headers (the spec
    /// documents them only for `429`), and whether `onRateLimit` fires.
    @Test
    func rateLimitHeaders() async {
        let transport = InspectingTransport(captureDirectory: nil)
        let calls = CallbackCounter()
        let client = SolarEdgeONEClient(
            credentials: .apiKey(LiveEnvironment.apiKey ?? ""),
            transport: transport,
            onRateLimit: { _ in calls.increment() }
        )

        await Probe.run("sites.details, watching rate limits") { try await client.sites.details(for: site) }

        for (status, names) in transport.rateLimitHeaderNames.sorted(by: { $0.key < $1.key }) {
            let list = names.isEmpty ? "none" : names.sorted().joined(separator: ", ")
            print("[live] rate-limit headers on HTTP \(status): \(list)")
        }
        print("[live] onRateLimit fired \(calls.value) times")
    }
}

/// Counts callback calls from any thread.
final class CallbackCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0
    var value: Int { lock.withLock { count } }
    func increment() { lock.withLock { count += 1 } }
}
