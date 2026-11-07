//
//  PvLayout.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// A detailed PV layout for a project (`PvLayoutConfig`): roof polygons,
    /// obstacles, module models and the module groups placed on the polygons.
    ///
    /// Coordinates are in meters. The origin is the project's latitude and
    /// longitude; the positive x-axis points east, the positive y-axis north.
    public struct PvLayout: Sendable, Hashable {
        /// A point in the layout's coordinate system, in meters.
        public struct Point: Sendable, Hashable {
            /// Meters east of the origin.
            public var x: Double
            /// Meters north of the origin.
            public var y: Double
            /// Height in meters.
            public var z: Double

            public init(x: Double, y: Double, z: Double) {
                self.x = x
                self.y = y
                self.z = z
            }
        }

        /// A roof facet (`PublicApiPolygon`). At least 3 vertices, all on one
        /// plane; polygons must not overlap.
        public struct Polygon: Sendable, Hashable {
            /// The vertices.
            public var vertices: [Point]

            public init(vertices: [Point]) {
                self.vertices = vertices
            }
        }

        /// A rectangle on the ground plane (`PublicApiRectangle`).
        public struct Rectangle: Sendable, Hashable {
            /// The center's x coordinate.
            public var centerX: Double
            /// The center's y coordinate.
            public var centerY: Double
            /// The size along the rectangle's horizontal axis. Must be positive.
            public var width: Double
            /// The size along the rectangle's vertical axis. Must be positive.
            public var height: Double
            /// The counterclockwise angle in degrees between the positive
            /// x-axis and the rectangle's horizontal axis, `0` to `359.9`.
            /// API default: `0`.
            public var rotation: Double?

            public init(centerX: Double, centerY: Double, width: Double, height: Double, rotation: Double? = nil) {
                self.centerX = centerX
                self.centerY = centerY
                self.width = width
                self.height = height
                self.rotation = rotation
            }
        }

        /// An obstacle on a roof (`PublicApiObstacle`).
        public struct Obstacle: Sendable, Hashable {
            /// The obstacle's footprint.
            public var rectangle: Rectangle
            /// Absolute height of the top facet above the ground. An obstacle
            /// below the roof is raised to the roof. `nil` uses the minimum
            /// height.
            public var height: Double?
            /// Whether the top facet lies on the roof surface instead of
            /// parallel to the ground. Only valid if all corners are inside
            /// the same polygon. API default: `false`.
            public var flushed: Bool?

            public init(rectangle: Rectangle, height: Double? = nil, flushed: Bool? = nil) {
                self.rectangle = rectangle
                self.height = height
                self.flushed = flushed
            }
        }

        /// A module model used by module groups (`PublicApiModuleModel`).
        ///
        /// Found by ``externalID`` if set; otherwise, or if that fails, by
        /// ``manufacturer`` and ``model``, including custom modules in
        /// Designer. Groups whose model is not found are not created.
        public struct ModuleModel: Sendable, Hashable {
            /// The ID of the module in the Photovoltaic Forum database.
            public var externalID: Int?
            /// The manufacturer. Required without ``externalID``.
            public var manufacturer: String?
            /// The model name. Required without ``externalID``.
            public var model: String?

            public init(externalID: Int? = nil, manufacturer: String? = nil, model: String? = nil) {
                self.externalID = externalID
                self.manufacturer = manufacturer
                self.model = model
            }
        }

        /// A module left out of a module group (`PublicApiModuleId`).
        public struct ModulePosition: Sendable, Hashable {
            /// The row of the module, or of its frame. 0-based.
            public var row: Int
            /// The column of the module, or of its frame. 0-based.
            public var column: Int
            /// The row of the module within its frame. 0-based. API default: `0`.
            public var rowInFrame: Int?

            public init(row: Int, column: Int, rowInFrame: Int? = nil) {
                self.row = row
                self.column = column
                self.rowInFrame = rowInFrame
            }
        }

        /// A grid of modules placed on a polygon (`PublicApiModuleGroup`).
        public struct ModuleGroup: Sendable, Hashable {
            /// How the modules are turned.
            public enum Orientation: String, Sendable, Hashable, CaseIterable {
                /// `portrait`.
                case portrait
                /// `landscape`.
                case landscape
            }

            /// How the modules are racked.
            public enum RackingType: String, Sendable, Hashable, CaseIterable {
                /// `flush-mount`.
                case flushMount = "flush-mount"
                /// `tilted`.
                case tilted
                /// `dual-tilted`. Needs ``ModuleGroup/ridgeDirection`` and
                /// ``ModuleGroup/domeSpacing``.
                case dualTilted = "dual-tilted"
            }

            /// Index of the group's module model in ``PvLayout/moduleModels``.
            public var modelIndex: Int
            /// Index of the polygon the group is placed on, in ``PvLayout/polygons``.
            public var polygonIndex: Int
            /// Number of rows, `1` to `1024`.
            public var rows: Int
            /// Number of columns, `1` to `1024`.
            public var columns: Int
            /// The x coordinate of the bottom-left module (row 0, column 0), in meters.
            public var x: Double
            /// The y coordinate of the bottom-left module (row 0, column 0), in meters.
            public var y: Double
            /// How the modules are turned.
            public var orientation: Orientation
            /// How the modules are racked.
            public var rackingType: RackingType
            /// The tilt in degrees relative to the roof, `0` to `90`. Ignored
            /// for flush mount.
            public var tilt: Double?
            /// The angle in degrees of the vector perpendicular to the rows:
            /// 0 north, 90 east, 180 south, 270 west.
            public var azimuth: Double?
            /// The ridge direction. Required for ``RackingType/dualTilted``.
            public var ridgeDirection: Double?
            /// Meters between the top of one row and the start of the next.
            /// API default: `0`.
            public var rowSpacing: Double?
            /// Meters between one column's right side and the next column's
            /// left side. API default: `0`.
            public var columnSpacing: Double?
            /// Required for ``RackingType/dualTilted``; the API currently only
            /// accepts `2`.
            public var domeSpacing: Double?
            /// Number of vertical modules in a single row, `1` to `64`. The API
            /// currently only accepts `1` for dual-tilted. API default: `1`.
            public var frameRows: Int?
            /// Modules left out of the group.
            public var deletedModules: [ModulePosition]

            public init(modelIndex: Int, polygonIndex: Int, rows: Int, columns: Int, x: Double, y: Double,
                        orientation: Orientation, rackingType: RackingType, tilt: Double? = nil, azimuth: Double? = nil,
                        ridgeDirection: Double? = nil, rowSpacing: Double? = nil, columnSpacing: Double? = nil,
                        domeSpacing: Double? = nil, frameRows: Int? = nil, deletedModules: [ModulePosition] = []) {
                self.modelIndex = modelIndex
                self.polygonIndex = polygonIndex
                self.rows = rows
                self.columns = columns
                self.x = x
                self.y = y
                self.orientation = orientation
                self.rackingType = rackingType
                self.tilt = tilt
                self.azimuth = azimuth
                self.ridgeDirection = ridgeDirection
                self.rowSpacing = rowSpacing
                self.columnSpacing = columnSpacing
                self.domeSpacing = domeSpacing
                self.frameRows = frameRows
                self.deletedModules = deletedModules
            }
        }

        /// The roof facets.
        public var polygons: [Polygon]
        /// The obstacles.
        public var obstacles: [Obstacle]
        /// The module models the groups refer to by index.
        public var moduleModels: [ModuleModel]
        /// The module groups.
        public var moduleGroups: [ModuleGroup]

        public init(polygons: [Polygon] = [], obstacles: [Obstacle] = [], moduleModels: [ModuleModel] = [], moduleGroups: [ModuleGroup] = []) {
            self.polygons = polygons
            self.obstacles = obstacles
            self.moduleModels = moduleModels
            self.moduleGroups = moduleGroups
        }
    }
}

extension Designer.PvLayout {
    /// Checks the counts, ranges and cross-references the spec gives.
    func validate() throws {
        for polygon in polygons {
            try check(polygon.vertices.count >= 3, "A polygon needs at least 3 vertices, got \(polygon.vertices.count)")
        }
        for obstacle in obstacles {
            try check(obstacle.rectangle.width > 0 && obstacle.rectangle.height > 0, "An obstacle's size must be positive")
            try checkRange(obstacle.rectangle.rotation, 0...359.9, "rotation")
        }
        for model in moduleModels {
            try check(model.externalID != nil || (model.manufacturer != nil && model.model != nil),
                      "A module model needs an external ID, or a manufacturer and a model")
        }
        for group in moduleGroups {
            try check(moduleModels.indices.contains(group.modelIndex), "'model_id' \(group.modelIndex) is not an index of 'moduleModels'")
            try check(polygons.indices.contains(group.polygonIndex), "'polygon_id' \(group.polygonIndex) is not an index of 'polygons'")
            try checkRange(group.rows, 1...1024, "rows")
            try checkRange(group.columns, 1...1024, "cols")
            try checkRange(group.tilt, 0...90, "tilt")
            try checkRange(group.frameRows, 1...64, "frame_rows")
            if group.rackingType == .dualTilted {
                try check(group.ridgeDirection != nil, "'ridge_direction' is required for dual-tilted racking")
                try check(group.domeSpacing != nil, "'dome_spacing' is required for dual-tilted racking")
            }
            for module in group.deletedModules {
                try check(module.row >= 0 && module.column >= 0 && (module.rowInFrame ?? 0) >= 0,
                          "Deleted module positions are 0-based and must not be negative")
            }
        }
    }
}
