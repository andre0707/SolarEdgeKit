//
//  SiteReport.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The report of a Designer site, part of ``ReportData``.
    ///
    /// The spec documents neither the meaning nor the units of most values;
    /// names and types mirror it.
    public struct SiteReport: Sendable, Hashable {
        /// How many devices of each kind the design has.
        public struct Overview: Sendable, Hashable {
            /// Number of PV modules.
            public let pvModules: Int
            /// Number of inverters.
            public let inverters: Int
            /// Number of optimizers.
            public let optimizers: Int
            /// Number of orientations.
            public let orientations: Int
            /// Number of batteries.
            public let batteries: Int
            /// The general type of the optimizers.
            public let optimizerGeneralType: OptimizerModel.OptimizerType

            public init(pvModules: Int, inverters: Int, optimizers: Int, orientations: Int, batteries: Int,
                        optimizerGeneralType: OptimizerModel.OptimizerType) {
                self.pvModules = pvModules
                self.inverters = inverters
                self.optimizers = optimizers
                self.orientations = orientations
                self.batteries = batteries
                self.optimizerGeneralType = optimizerGeneralType
            }
        }

        /// The simulated system data (`SystemDataDto`).
        public struct SimulationResults: Sendable, Hashable {
            /// Installed power.
            public let installedPower: Double
            /// Maximum achieved DC power.
            public let maxAchievedDcPower: Double
            /// Actual achieved oversizing.
            public let actualAchievedOversizing: Double
            /// Maximum active AC power.
            public let maxActiveAcPower: Int
            /// Maximum achieved AC power.
            public let maxAchievedAcPower: Int
            /// Maximum active apparent power.
            public let maxActiveApparentPower: Int
            /// Annual energy.
            public let annualEnergy: Double
            /// Annual energy of non-SolarEdge inverters.
            public let nonSeInverterAnnualEnergy: Double
            /// Annual apparent energy.
            public let annualApparentEnergy: Double
            /// Annual reactive energy.
            public let annualReactiveEnergy: Double
            /// Maximum reactive power.
            public let maxReactivePower: Int
            /// Performance ratio.
            public let performanceRatio: Double
            /// Performance index.
            public let performanceIndex: Double
            /// CO₂ emission saved.
            public let co2EmissionSaved: Double
            /// Equivalent trees planted.
            public let equivalentTreesPlanted: Double

            public init(installedPower: Double, maxAchievedDcPower: Double, actualAchievedOversizing: Double,
                        maxActiveAcPower: Int, maxAchievedAcPower: Int, maxActiveApparentPower: Int,
                        annualEnergy: Double, nonSeInverterAnnualEnergy: Double, annualApparentEnergy: Double,
                        annualReactiveEnergy: Double, maxReactivePower: Int, performanceRatio: Double,
                        performanceIndex: Double, co2EmissionSaved: Double, equivalentTreesPlanted: Double) {
                self.installedPower = installedPower
                self.maxAchievedDcPower = maxAchievedDcPower
                self.actualAchievedOversizing = actualAchievedOversizing
                self.maxActiveAcPower = maxActiveAcPower
                self.maxAchievedAcPower = maxAchievedAcPower
                self.maxActiveApparentPower = maxActiveApparentPower
                self.annualEnergy = annualEnergy
                self.nonSeInverterAnnualEnergy = nonSeInverterAnnualEnergy
                self.annualApparentEnergy = annualApparentEnergy
                self.annualReactiveEnergy = annualReactiveEnergy
                self.maxReactivePower = maxReactivePower
                self.performanceRatio = performanceRatio
                self.performanceIndex = performanceIndex
                self.co2EmissionSaved = co2EmissionSaved
                self.equivalentTreesPlanted = equivalentTreesPlanted
            }
        }

        /// The estimated energy of one month.
        public struct MonthlyEnergy: Sendable, Hashable {
            /// Energy produced.
            public let produced: Double
            /// Energy clipped.
            public let clipped: Double
            /// Energy self-consumed.
            public let selfConsumed: Double
            /// Energy consumed.
            public let consumed: Double
            /// The month's English name, as sent by the API.
            public let monthInEnglish: String

            public init(produced: Double, clipped: Double, selfConsumed: Double, consumed: Double, monthInEnglish: String) {
                self.produced = produced
                self.clipped = clipped
                self.selfConsumed = selfConsumed
                self.consumed = consumed
                self.monthInEnglish = monthInEnglish
            }
        }

        /// A group of PV modules of one model and orientation (`PvModulesDto`).
        public struct PvModuleGroup: Sendable, Hashable {
            /// Number of modules.
            public let modulesCount: Int
            /// The module's name.
            public let moduleName: String
            /// Power.
            public let power: Double
            /// How the modules are mounted.
            public let mountingType: MountingType
            /// How the modules are turned.
            public let moduleOrientation: ModuleOrientation
            /// Absolute azimuth.
            public let absoluteAzimuth: Double
            /// Absolute tilt.
            public let absoluteTilt: Double
            /// Whether the module is user-defined.
            public let userDefined: Bool

            public init(modulesCount: Int, moduleName: String, power: Double, mountingType: MountingType,
                        moduleOrientation: ModuleOrientation, absoluteAzimuth: Double, absoluteTilt: Double, userDefined: Bool) {
                self.modulesCount = modulesCount
                self.moduleName = moduleName
                self.power = power
                self.mountingType = mountingType
                self.moduleOrientation = moduleOrientation
                self.absoluteAzimuth = absoluteAzimuth
                self.absoluteTilt = absoluteTilt
                self.userDefined = userDefined
            }
        }

        /// The bill of materials, grouped by category (`BillOfMaterialsDto`).
        public struct BillOfMaterials: Sendable, Hashable {
            /// One line of the bill of materials (`BomItemDto`).
            public struct Item: Sendable, Hashable {
                /// The kind of item.
                public enum ItemType: Sendable, Hashable, CaseIterable, RawRepresentable {
                    /// `INVERTER`.
                    case inverter
                    /// `OPTIMIZER`.
                    case optimizer
                    /// `BATTERY`.
                    case battery
                    /// `MODULE`.
                    case module
                    /// `RACKING_SET`.
                    case rackingSet
                    /// `CAULKING_BOTTLE`.
                    case caulkingBottle
                    /// `MODULE_COVER`.
                    case moduleCover
                    /// `COMBINER_BOX`.
                    case combinerBox
                    /// `AC_COMBINER_BOX`.
                    case acCombinerBox
                    /// `CABLE`.
                    case cable
                    /// `AC_CABLE`.
                    case acCable
                    /// `CUSTOM`.
                    case custom
                    /// `GENERAL`.
                    case general
                    /// `EV_CHARGER`.
                    case evCharger
                    /// `WATER_HEATER`.
                    case waterHeater
                    /// `BACKUP_INTERFACE`.
                    case backupInterface
                    /// `DEVICE`.
                    case device
                    /// `COMMUNICATION`.
                    case communication
                    /// `SMART_METER`.
                    case smartMeter
                    /// `SENSOR`.
                    case sensor
                    /// `CABLES_CUSTOM`.
                    case cablesCustom
                    /// `AC_CABLE_CUSTOM`.
                    case acCableCustom
                    /// `RAIL`.
                    case rail
                    /// `SPLICE`.
                    case splice
                    /// `CLAMP`.
                    case clamp
                    /// `STOPPER`.
                    case stopper
                    /// `BOLT`.
                    case bolt
                    /// `SWITCH`.
                    case `switch`
                    /// A value this version of the package does not know yet, as the
                    /// API sent it. New values are added on the server over time.
                    case unknown(String)

                    /// The known values, without ``unknown(_:)``.
                    public static let allCases: [ItemType] = [.inverter, .optimizer, .battery, .module, .rackingSet, .caulkingBottle, .moduleCover, .combinerBox, .acCombinerBox, .cable, .acCable, .custom, .general, .evCharger, .waterHeater, .backupInterface, .device, .communication, .smartMeter, .sensor, .cablesCustom, .acCableCustom, .rail, .splice, .clamp, .stopper, .bolt, .`switch`]

                    /// The case for an API value, or ``unknown(_:)``. Never `nil`.
                    public init(rawValue: String) {
                        self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
                    }

                    /// The value as the API sends it.
                    public var rawValue: String {
                        switch self {
                        case .inverter: "INVERTER"
                        case .optimizer: "OPTIMIZER"
                        case .battery: "BATTERY"
                        case .module: "MODULE"
                        case .rackingSet: "RACKING_SET"
                        case .caulkingBottle: "CAULKING_BOTTLE"
                        case .moduleCover: "MODULE_COVER"
                        case .combinerBox: "COMBINER_BOX"
                        case .acCombinerBox: "AC_COMBINER_BOX"
                        case .cable: "CABLE"
                        case .acCable: "AC_CABLE"
                        case .custom: "CUSTOM"
                        case .general: "GENERAL"
                        case .evCharger: "EV_CHARGER"
                        case .waterHeater: "WATER_HEATER"
                        case .backupInterface: "BACKUP_INTERFACE"
                        case .device: "DEVICE"
                        case .communication: "COMMUNICATION"
                        case .smartMeter: "SMART_METER"
                        case .sensor: "SENSOR"
                        case .cablesCustom: "CABLES_CUSTOM"
                        case .acCableCustom: "AC_CABLE_CUSTOM"
                        case .rail: "RAIL"
                        case .splice: "SPLICE"
                        case .clamp: "CLAMP"
                        case .stopper: "STOPPER"
                        case .bolt: "BOLT"
                        case .switch: "SWITCH"
                        case .unknown(let rawValue): rawValue
                        }
                    }
                }

                /// The item's ID.
                public let id: Int
                /// The kind of item.
                public let type: ItemType
                /// The device model's ID.
                public let modelId: String
                /// The key of the item's name.
                public let itemNameKey: String
                /// The item's name.
                public let itemName: String
                /// How many of the item.
                public let itemCount: Double
                /// Cost.
                public let cost: Double
                /// Notes.
                public let notes: String

                public init(id: Int, type: ItemType, modelId: String, itemNameKey: String, itemName: String,
                            itemCount: Double, cost: Double, notes: String) {
                    self.id = id
                    self.type = type
                    self.modelId = modelId
                    self.itemNameKey = itemNameKey
                    self.itemName = itemName
                    self.itemCount = itemCount
                    self.cost = cost
                    self.notes = notes
                }
            }

            /// Inverters.
            public let inverters: [Item]
            /// Optimizers.
            public let optimizers: [Item]
            /// Batteries.
            public let batteries: [Item]
            /// PV modules.
            public let modules: [Item]
            /// Custom items.
            public let custom: [Item]
            /// Racking sets.
            public let rackingSets: [Item]
            /// Caulking bottles.
            public let caulkingBottles: [Item]
            /// Module covers.
            public let moduleCovers: [Item]

            public init(inverters: [Item], optimizers: [Item], batteries: [Item], modules: [Item], custom: [Item],
                        rackingSets: [Item], caulkingBottles: [Item], moduleCovers: [Item]) {
                self.inverters = inverters
                self.optimizers = optimizers
                self.batteries = batteries
                self.modules = modules
                self.custom = custom
                self.rackingSets = rackingSets
                self.caulkingBottles = caulkingBottles
                self.moduleCovers = moduleCovers
            }
        }

        /// How many devices of each kind the design has.
        public let overview: Overview
        /// The simulated system data.
        public let simulationResults: SimulationResults
        /// The estimated energy per month.
        public let estimatedMonthlyEnergy: [MonthlyEnergy]
        /// The PV modules, grouped by model and orientation.
        public let pvModules: [PvModuleGroup]
        /// The bill of materials.
        public let billOfMaterials: BillOfMaterials
        /// How many images the report has. Fetch them with
        /// ``ReportsService/image(_:for:)``.
        public let numOfImages: Int

        public init(overview: Overview, simulationResults: SimulationResults, estimatedMonthlyEnergy: [MonthlyEnergy],
                    pvModules: [PvModuleGroup], billOfMaterials: BillOfMaterials, numOfImages: Int) {
            self.overview = overview
            self.simulationResults = simulationResults
            self.estimatedMonthlyEnergy = estimatedMonthlyEnergy
            self.pvModules = pvModules
            self.billOfMaterials = billOfMaterials
            self.numOfImages = numOfImages
        }
    }
}
