//
//  AutoDesignParameters.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Designer {
    /// The input of ``AutoDesignService/start(_:)`` (`AutoDesignParameters`).
    ///
    /// Only ``site`` is required. Optional values that are `nil` are not
    /// sent, so the API uses its defaults.
    public struct AutoDesignParameters: Sendable, Hashable {
        /// The site to create (`AutoDesignSiteParameters`).
        public struct Site: Sendable, Hashable {
            /// The sector of the site.
            public enum Sector: String, Sendable, Hashable, CaseIterable {
                /// `RESIDENTIAL`.
                case residential = "RESIDENTIAL"
                /// `COMMERCIAL`.
                case commercial = "COMMERCIAL"
                /// `ALL`.
                case all = "ALL"
            }

            /// The name of the new site. Must not be empty.
            public var siteName: String
            /// Latitude of the site, `-90` to `90`.
            public var latitude: Double
            /// Longitude of the site, `-180` to `180`.
            public var longitude: Double
            /// The sector. API default: ``Sector/commercial``.
            public var sector: Sector?
            /// The grid, e.g. from ``EstimationService/gridCodes(country:)``.
            public var gridID: GridCode.ID?

            public init(siteName: String, latitude: Double, longitude: Double, sector: Sector? = nil, gridID: GridCode.ID? = nil) {
                self.siteName = siteName
                self.latitude = latitude
                self.longitude = longitude
                self.sector = sector
                self.gridID = gridID
            }
        }

        /// The site's consumption (`AutoDesignConsumptionParameters`).
        public struct Consumption: Sendable, Hashable {
            /// The utility rate, e.g. from
            /// ``EstimationService/utilityRates(utilityNames:rateType:orphanRates:country:state:)``.
            public var utilityRateID: UtilityRate.ID?
            /// The annual consumption in kWh.
            public var annualConsumptionKwh: Double?
            /// A consumption profile, e.g. from
            /// ``EstimationService/consumptionProfiles(country:)``.
            public var consumptionProfileID: ConsumptionProfile.ID?

            public init(utilityRateID: UtilityRate.ID? = nil, annualConsumptionKwh: Double? = nil,
                        consumptionProfileID: ConsumptionProfile.ID? = nil) {
                self.utilityRateID = utilityRateID
                self.annualConsumptionKwh = annualConsumptionKwh
                self.consumptionProfileID = consumptionProfileID
            }
        }

        /// How the PV modules are placed (`AutoDesignPvPlacementParameters`).
        /// Spacings, distances and elevation are in meters.
        public struct PvPlacement: Sendable, Hashable {
            /// The module model. `nil` uses the account's favourite PV
            /// module; without one, the design fails with
            /// ``AutoDesignStatus/ErrorCode/missingPvModelID``.
            public var moduleModelID: PvModule.ID?
            /// How the modules are racked.
            public var racking: MountingType?
            /// How the modules are turned.
            public var orientation: ModuleOrientation?
            /// The tilt in degrees. Always `0` for flush mount; for tilted
            /// racking, `nil` uses the optimal tilt.
            public var tiltDegrees: Double?
            /// Distance between the columns of the PV array. API default: `0`.
            public var columnSpacing: Double?
            /// Distance between the rows of the PV array. API default: `0`.
            public var rowSpacing: Double?
            /// Height of the panels above the facet or ground. API default: `0`.
            public var elevation: Double?
            /// Maximum panels per column. `nil` for as many as the facet allows.
            public var maxColumns: Int?
            /// Maximum panels per row. `nil` for as many as the facet allows.
            public var maxRows: Int?
            /// Distance between PV arrays in the same row. API default: `0`.
            public var horizontalSpacing: Double?
            /// Distance between PV arrays in the same column. API default: `0`.
            public var verticalSpacing: Double?
            /// A Designer setback profile: how much space is left free of
            /// panels along the roof's edges.
            public var setbackProfileID: Int?
            /// Space left between obstacles and panels.
            public var obstacleSpacing: Double?
            /// The number of vertically stacked modules in a row (a frame).
            /// API default: `1`.
            public var frameSize: Int?

            public init(moduleModelID: PvModule.ID? = nil, racking: MountingType? = nil, orientation: ModuleOrientation? = nil,
                        tiltDegrees: Double? = nil, columnSpacing: Double? = nil, rowSpacing: Double? = nil,
                        elevation: Double? = nil, maxColumns: Int? = nil, maxRows: Int? = nil,
                        horizontalSpacing: Double? = nil, verticalSpacing: Double? = nil, setbackProfileID: Int? = nil,
                        obstacleSpacing: Double? = nil, frameSize: Int? = nil) {
                self.moduleModelID = moduleModelID
                self.racking = racking
                self.orientation = orientation
                self.tiltDegrees = tiltDegrees
                self.columnSpacing = columnSpacing
                self.rowSpacing = rowSpacing
                self.elevation = elevation
                self.maxColumns = maxColumns
                self.maxRows = maxRows
                self.horizontalSpacing = horizontalSpacing
                self.verticalSpacing = verticalSpacing
                self.setbackProfileID = setbackProfileID
                self.obstacleSpacing = obstacleSpacing
                self.frameSize = frameSize
            }
        }

        /// The site to create.
        public var site: Site
        /// The site's consumption.
        public var consumption: Consumption?
        /// How the PV modules are placed.
        public var pvPlacement: PvPlacement?
        /// The phase of the building's electricity (`electricalDesign.phase`).
        /// API default: three-phase for commercial sites, otherwise single-phase.
        public var phase: Phase?
        /// The price per watt (`financials.pricePerW`).
        public var pricePerWatt: Double?

        public init(site: Site, consumption: Consumption? = nil, pvPlacement: PvPlacement? = nil,
                    phase: Phase? = nil, pricePerWatt: Double? = nil) {
            self.site = site
            self.consumption = consumption
            self.pvPlacement = pvPlacement
            self.phase = phase
            self.pricePerWatt = pricePerWatt
        }
    }
}

extension Designer.AutoDesignParameters {
    /// Checks what the spec defines; it gives no ranges for the placement.
    func validate() throws {
        try validateRequired(site.siteName, name: "siteName")
        try checkRange(site.latitude, -90...90, "latitude")
        try checkRange(site.longitude, -180...180, "longitude")
        if let gridID = site.gridID { try validateRequired(gridID.rawValue, name: "gridId") }
    }
}
