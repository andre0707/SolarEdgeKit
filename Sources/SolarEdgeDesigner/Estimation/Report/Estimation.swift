//
//  Estimation.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// An electrical and financial estimation, as returned by
    /// ``EstimationService/estimate(_:)`` and
    /// ``EstimationService/estimation(for:design:)``.
    ///
    /// The documentation of each value is the spec's description. The spec's
    /// units are not always consistent with its examples, so the values are
    /// plain numbers, not measurements.
    public struct Estimation: Sendable, Hashable {
        /// A calendar month, as named by the API.
        public enum Month: String, Sendable, Hashable, CaseIterable {
            /// January.
            case january = "January"
            /// February.
            case february = "February"
            /// March.
            case march = "March"
            /// April.
            case april = "April"
            /// May.
            case may = "May"
            /// June.
            case june = "June"
            /// July.
            case july = "July"
            /// August.
            case august = "August"
            /// September.
            case september = "September"
            /// October.
            case october = "October"
            /// November.
            case november = "November"
            /// December.
            case december = "December"

            /// The month's number, `1` for January to `12` for December.
            public var number: Int { Self.allCases.firstIndex(of: self)! + 1 }
        }

        /// The estimated energy for one month (`EstimatedMonthlyEnergy`).
        public struct MonthlyEnergy: Sendable, Hashable {
            /// The month.
            public let month: Month
            /// Solar power production for the month in kWh.
            public let solarProduction: Double
            /// Solar power consumption for the month in kWh.
            public let consumption: Double
            /// Solar power self-consumption for the month in kWh.
            public let selfConsumption: Double

            public init(month: Month, solarProduction: Double, consumption: Double, selfConsumption: Double) {
                self.month = month
                self.solarProduction = solarProduction
                self.consumption = consumption
                self.selfConsumption = selfConsumption
            }
        }

        /// The bill of materials of the estimation.
        public struct BillOfMaterials: Sendable, Hashable {
            /// PV modules.
            public let modules: [BillOfMaterialsItem]
            /// Inverters.
            public let inverters: [BillOfMaterialsItem]
            /// Optimizers.
            public let optimizers: [BillOfMaterialsItem]
            /// Batteries.
            public let batteries: [BillOfMaterialsItem]

            public init(modules: [BillOfMaterialsItem], inverters: [BillOfMaterialsItem],
                        optimizers: [BillOfMaterialsItem], batteries: [BillOfMaterialsItem]) {
                self.modules = modules
                self.inverters = inverters
                self.optimizers = optimizers
                self.batteries = batteries
            }
        }

        /// The installed system. Units are as the spec states them; its examples suggest W where it says kW.
        public struct InstalledSystem: Sendable, Hashable {
            /// System power in kW.
            public let installedPower: Double
            /// The maximum theoretical power that the PV modules can produce depending on their Azimuth and Tilt while not taking into account any optimizer or inverter limitations.
            public let maxAchievedDcPower: Double
            /// The actual DC/AC oversizing of the system.
            public let actualAchievedOversizing: Double
            /// Maximum active AC power in kW.
            public let maxActiveAcPower: Double
            /// Maximum achieved AC power in kW.
            public let maxAchievedAcPower: Double
            /// Maximum active apparent power in kW.
            public let maxActiveApparentPower: Double
            /// Total annual energy production in Wh.
            public let annualEnergy: Double
            /// Typical annual energy production for non SE inverter in Wh.
            public let nonSeInverterAnnualEnergy: Double
            /// Maximum Reactive Power.
            public let maxReactivePower: Double
            /// The performance ratio of the system.
            public let performanceRatio: Double
            /// Performance index of the system in kWh/kWp.
            public let performanceIndex: Double
            /// CO2 emissions saved in kg.
            public let co2EmissionSaved: Double
            /// Equivalent trees planted.
            public let equivalentTreesPlanted: Double

            public init(installedPower: Double, maxAchievedDcPower: Double, actualAchievedOversizing: Double, maxActiveAcPower: Double, maxAchievedAcPower: Double, maxActiveApparentPower: Double, annualEnergy: Double, nonSeInverterAnnualEnergy: Double, maxReactivePower: Double, performanceRatio: Double, performanceIndex: Double, co2EmissionSaved: Double, equivalentTreesPlanted: Double) {
                self.installedPower = installedPower
                self.maxAchievedDcPower = maxAchievedDcPower
                self.actualAchievedOversizing = actualAchievedOversizing
                self.maxActiveAcPower = maxActiveAcPower
                self.maxAchievedAcPower = maxAchievedAcPower
                self.maxActiveApparentPower = maxActiveApparentPower
                self.annualEnergy = annualEnergy
                self.nonSeInverterAnnualEnergy = nonSeInverterAnnualEnergy
                self.maxReactivePower = maxReactivePower
                self.performanceRatio = performanceRatio
                self.performanceIndex = performanceIndex
                self.co2EmissionSaved = co2EmissionSaved
                self.equivalentTreesPlanted = equivalentTreesPlanted
            }
        }

        /// How many devices of each kind the design has.
        public struct ProjectDesign: Sendable, Hashable {
            /// Total number of modules installed.
            public let pvModules: Int
            /// Total number of inverters installed.
            public let inverters: Int
            /// Total number of optimizers installed.
            public let optimizers: Int
            /// Number of different orientations.
            public let orientations: Int
            /// Number of batteries installed.
            public let batteries: Int

            public init(pvModules: Int, inverters: Int, optimizers: Int, orientations: Int, batteries: Int) {
                self.pvModules = pvModules
                self.inverters = inverters
                self.optimizers = optimizers
                self.orientations = orientations
                self.batteries = batteries
            }
        }

        /// Summary results of the simulation. Units are as the spec states them; it says MW for an energy value.
        public struct SimulationResults: Sendable, Hashable {
            /// Annual production in MW.
            public let annualEnergyProduction: Double
            /// Typical annual production in for non SolarEdge inverters in MW.
            public let annualEnergyProductionForNonSe: Double
            /// CO2 emissions saved in tonnes.
            public let co2EmissionSavedTonnes: Double
            /// Equivalent trees planted.
            public let treesPlanted: Int

            public init(annualEnergyProduction: Double, annualEnergyProductionForNonSe: Double, co2EmissionSavedTonnes: Double, treesPlanted: Int) {
                self.annualEnergyProduction = annualEnergyProduction
                self.annualEnergyProductionForNonSe = annualEnergyProductionForNonSe
                self.co2EmissionSavedTonnes = co2EmissionSavedTonnes
                self.treesPlanted = treesPlanted
            }
        }

        /// Yearly production and consumption totals (`ProductionConsumptionData`).
        public struct ProductionAndConsumption: Sendable, Hashable {
            /// Total yearly consumption in Wh.
            public let totalConsumption: Double
            /// Total self-consumption in Wh.
            public let totalSelfConsumption: Double
            /// Battery self-consumption in Wh.
            public let batterySelfConsumption: Double
            /// Total power import in Wh.
            public let totalImport: Double
            /// Total power production in Wh.
            public let totalProduction: Double
            /// Total power export in Wh.
            public let totalExport: Double

            public init(totalConsumption: Double, totalSelfConsumption: Double, batterySelfConsumption: Double, totalImport: Double, totalProduction: Double, totalExport: Double) {
                self.totalConsumption = totalConsumption
                self.totalSelfConsumption = totalSelfConsumption
                self.batterySelfConsumption = batterySelfConsumption
                self.totalImport = totalImport
                self.totalProduction = totalProduction
                self.totalExport = totalExport
            }
        }

        /// Where the yearly consumption comes from and where the yearly production goes.
        public struct ProductionConsumptionDetails: Sendable, Hashable {
            /// The yearly consumption that comes directly from imported grid energy in Wh.
            public let consumptionFromGridWh: Double
            /// The yearly consumption that comes directly from imported grid energy as percent of the total consumption.
            public let consumptionFromGridPercent: Double
            /// The yearly consumption that comes from energy stored in batteries in Wh.
            public let consumptionFromBatteriesWh: Double
            /// The yearly consumption that comes from energy stored in batteries as percent of the total consumption.
            public let consumptionFromBatteriesPercent: Double
            /// The yearly consumption that comes directly from produced solar energy in Wh.
            public let consumptionFromSolarWh: Double
            /// The yearly consumption that comes directly from produced solar energy as percent of the total consumption.
            public let consumptionFromSolarPercent: Double
            /// Total yearly consumption in Wh.
            public let totalConsumption: Double
            /// The yearly production that is exported to the grid in Wh.
            public let productionToGridWh: Double
            /// The yearly production that is exported to the grid as percent of the total production.
            public let productionToGridPercent: Double
            /// The yearly production that is used to charge batteries in Wh.
            public let productionToBatteriesWh: Double
            /// The yearly production that is used to charge batteries as percent of the total production.
            public let productionToBatteriesPercent: Double
            /// The yearly production that is self-consumed by the site in Wh.
            public let productionToHomeWh: Double
            /// The yearly production that is self-consumed by the site as percent of the total production.
            public let productionToHomePercent: Double
            /// The yearly clipping loss in Wh.
            public let clippingLossWh: Double
            /// The yearly clipping loss as percent of the total production.
            public let clippingLossPercent: Double
            /// Total yearly production in Wh.
            public let totalProduction: Double

            public init(consumptionFromGridWh: Double, consumptionFromGridPercent: Double, consumptionFromBatteriesWh: Double, consumptionFromBatteriesPercent: Double, consumptionFromSolarWh: Double, consumptionFromSolarPercent: Double, totalConsumption: Double, productionToGridWh: Double, productionToGridPercent: Double, productionToBatteriesWh: Double, productionToBatteriesPercent: Double, productionToHomeWh: Double, productionToHomePercent: Double, clippingLossWh: Double, clippingLossPercent: Double, totalProduction: Double) {
                self.consumptionFromGridWh = consumptionFromGridWh
                self.consumptionFromGridPercent = consumptionFromGridPercent
                self.consumptionFromBatteriesWh = consumptionFromBatteriesWh
                self.consumptionFromBatteriesPercent = consumptionFromBatteriesPercent
                self.consumptionFromSolarWh = consumptionFromSolarWh
                self.consumptionFromSolarPercent = consumptionFromSolarPercent
                self.totalConsumption = totalConsumption
                self.productionToGridWh = productionToGridWh
                self.productionToGridPercent = productionToGridPercent
                self.productionToBatteriesWh = productionToBatteriesWh
                self.productionToBatteriesPercent = productionToBatteriesPercent
                self.productionToHomeWh = productionToHomeWh
                self.productionToHomePercent = productionToHomePercent
                self.clippingLossWh = clippingLossWh
                self.clippingLossPercent = clippingLossPercent
                self.totalProduction = totalProduction
            }
        }

        /// Where the energy stored in the batteries comes from and where it goes (`StorageEnergyBreakdownDetails`).
        public struct StorageEnergyBreakdown: Sendable, Hashable {
            /// The storage energy that comes from clipped energy in Wh.
            public let fromClippedEnergyWh: Double
            /// The storage energy that comes from clipped energy as percent of the total storage energy from all sources.
            public let fromClippedEnergyPercent: Double
            /// The storage energy that comes from imported grid energy in Wh.
            public let fromGridWh: Double
            /// The storage energy that comes from imported grid energy as percent of the total storage energy from all sources.
            public let fromGridPercent: Double
            /// The storage energy that comes from produced solar energy in Wh.
            public let fromSolarWh: Double
            /// The storage energy that comes from produced solar energy as percent of the total storage energy from all sources.
            public let fromSolarPercent: Double
            /// The total storage energy from all sources in Wh.
            public let totalFromAllSourcesWh: Double
            /// The storage energy that is consumed by the site in Wh.
            public let toHomeWh: Double
            /// The storage energy that is consumed by the site as percent of the total storage energy to all destinations.
            public let toHomePercent: Double
            /// The storage energy that is exported to the grid in Wh.
            public let toGridWh: Double
            /// The storage energy that is exported to the grid as percent of the total storage energy to all destinations.
            public let toGridPercent: Double
            /// The total storage energy to all destinations in Wh.
            public let totalToAllDestinationsWh: Double

            public init(fromClippedEnergyWh: Double, fromClippedEnergyPercent: Double, fromGridWh: Double, fromGridPercent: Double, fromSolarWh: Double, fromSolarPercent: Double, totalFromAllSourcesWh: Double, toHomeWh: Double, toHomePercent: Double, toGridWh: Double, toGridPercent: Double, totalToAllDestinationsWh: Double) {
                self.fromClippedEnergyWh = fromClippedEnergyWh
                self.fromClippedEnergyPercent = fromClippedEnergyPercent
                self.fromGridWh = fromGridWh
                self.fromGridPercent = fromGridPercent
                self.fromSolarWh = fromSolarWh
                self.fromSolarPercent = fromSolarPercent
                self.totalFromAllSourcesWh = totalFromAllSourcesWh
                self.toHomeWh = toHomeWh
                self.toHomePercent = toHomePercent
                self.toGridWh = toGridWh
                self.toGridPercent = toGridPercent
                self.totalToAllDestinationsWh = totalToAllDestinationsWh
            }
        }

        /// The cash flow of one year.
        public struct YearlyCashFlow: Sendable, Hashable {
            /// The year.
            public let year: Int
            /// The total system price until this year.
            public let systemPrice: Double
            /// The return from incentives for the year.
            public let returnFromIncentives: Double
            /// The bill savings for the year.
            public let netBillSavings: Double
            /// The cash flow for the year.
            public let annualCashFlow: Double
            /// The cumulative cash flow until this year.
            public let cumulativeCashFlow: Double

            public init(year: Int, systemPrice: Double, returnFromIncentives: Double, netBillSavings: Double, annualCashFlow: Double, cumulativeCashFlow: Double) {
                self.year = year
                self.systemPrice = systemPrice
                self.returnFromIncentives = returnFromIncentives
                self.netBillSavings = netBillSavings
                self.annualCashFlow = annualCashFlow
                self.cumulativeCashFlow = cumulativeCashFlow
            }
        }

        /// The electricity bills and savings of one year. The monthly arrays have one value per month.
        public struct AnnualSavings: Sendable, Hashable {
            /// The year for which the annual savings are calculated.
            public let year: Int
            /// The current bill per month.
            public let currentMonthlyBill: [Double]
            /// The bill per month with SolarEdge.
            public let monthlyBillWithSolarEdge: [Double]
            /// Typical bill per month with non SolarEdge inverter.
            public let monthlyBillWithNonSolarEdge: [Double]
            /// The savings per month with SolarEdge.
            public let netMonthlyBillSavings: [Double]
            /// The savings per month with SolarEdge without battery.
            public let netMonthlyBillSavingsWithoutBattery: [Double]
            /// The savings per month with SolarEdge without smart battery management.
            public let netMonthlyBillSavingsWithoutSmartBattery: [Double]
            /// The current annual bill (sum of all current monthly bills).
            public let annualBill: Double
            /// The average current monthly bill.
            public let averageMonthlyBill: Double
            /// The annual bill with SolarEdge (sum of all monthly bills with SolarEdge).
            public let annualBillWithSolarEdge: Double
            /// The estimated annual bill with Non SolarEdge Inverter.
            public let annualBillWithNonSolarEdge: Double
            /// The average monthly bill with SolarEdge.
            public let averageMonthlyBillWithSolarEdge: Double
            /// The annual bill savings with SolarEdge.
            public let annualBillSavings: Double
            /// The average monthly bill savings with SolarEdge.
            public let averageMonthlyBillSavings: Double
            /// The annual bill savings with SolarEdge without battery.
            public let annualBillSavingsWithoutBattery: Double
            /// The average monthly bill savings with SolarEdge without battery.
            public let averageMonthlyBillSavingsWithoutBattery: Double
            /// The annual bill savings with SolarEdge without smart battery management.
            public let annualBillSavingsWithoutSmartBattery: Double
            /// The average monthly bill savings with SolarEdge without smart battery management.
            public let averageMonthlyBillSavingsWithoutSmartBattery: Double

            public init(year: Int, currentMonthlyBill: [Double], monthlyBillWithSolarEdge: [Double], monthlyBillWithNonSolarEdge: [Double], netMonthlyBillSavings: [Double], netMonthlyBillSavingsWithoutBattery: [Double], netMonthlyBillSavingsWithoutSmartBattery: [Double], annualBill: Double, averageMonthlyBill: Double, annualBillWithSolarEdge: Double, annualBillWithNonSolarEdge: Double, averageMonthlyBillWithSolarEdge: Double, annualBillSavings: Double, averageMonthlyBillSavings: Double, annualBillSavingsWithoutBattery: Double, averageMonthlyBillSavingsWithoutBattery: Double, annualBillSavingsWithoutSmartBattery: Double, averageMonthlyBillSavingsWithoutSmartBattery: Double) {
                self.year = year
                self.currentMonthlyBill = currentMonthlyBill
                self.monthlyBillWithSolarEdge = monthlyBillWithSolarEdge
                self.monthlyBillWithNonSolarEdge = monthlyBillWithNonSolarEdge
                self.netMonthlyBillSavings = netMonthlyBillSavings
                self.netMonthlyBillSavingsWithoutBattery = netMonthlyBillSavingsWithoutBattery
                self.netMonthlyBillSavingsWithoutSmartBattery = netMonthlyBillSavingsWithoutSmartBattery
                self.annualBill = annualBill
                self.averageMonthlyBill = averageMonthlyBill
                self.annualBillWithSolarEdge = annualBillWithSolarEdge
                self.annualBillWithNonSolarEdge = annualBillWithNonSolarEdge
                self.averageMonthlyBillWithSolarEdge = averageMonthlyBillWithSolarEdge
                self.annualBillSavings = annualBillSavings
                self.averageMonthlyBillSavings = averageMonthlyBillSavings
                self.annualBillSavingsWithoutBattery = annualBillSavingsWithoutBattery
                self.averageMonthlyBillSavingsWithoutBattery = averageMonthlyBillSavingsWithoutBattery
                self.annualBillSavingsWithoutSmartBattery = annualBillSavingsWithoutSmartBattery
                self.averageMonthlyBillSavingsWithoutSmartBattery = averageMonthlyBillSavingsWithoutSmartBattery
            }
        }

        /// Battery figures of the estimation.
        public struct StorageReportData: Sendable, Hashable {
            /// The self-consumption ratio.
            public let selfConsumptionRatio: Double
            /// The self-consumption from batteries ratio.
            public let selfConsumptionFromBatteriesRatio: Double
            /// Total storage capacity in kWH.
            public let totalStorageCapacity: Double
            /// Total battery power.
            public let totalBatteryPower: Double
            /// Backup time without PV.
            public let backupTimeWithoutPV: Double
            /// Batteries backup percentage.
            public let backupPercentage: Double
            /// Backup time with PV.
            public let backupTimeWithPV: Double

            public init(selfConsumptionRatio: Double, selfConsumptionFromBatteriesRatio: Double, totalStorageCapacity: Double, totalBatteryPower: Double, backupTimeWithoutPV: Double, backupPercentage: Double, backupTimeWithPV: Double) {
                self.selfConsumptionRatio = selfConsumptionRatio
                self.selfConsumptionFromBatteriesRatio = selfConsumptionFromBatteriesRatio
                self.totalStorageCapacity = totalStorageCapacity
                self.totalBatteryPower = totalBatteryPower
                self.backupTimeWithoutPV = backupTimeWithoutPV
                self.backupPercentage = backupPercentage
                self.backupTimeWithPV = backupTimeWithPV
            }
        }

        /// One line of the bill of materials (`BomItem`).
        public struct BillOfMaterialsItem: Sendable, Hashable {
            /// The id of the BOM item.
            public let modelId: String
            /// The name of the BOM item.
            public let itemName: String
            /// The number of BOM items.
            public let itemCount: Double

            public init(modelId: String, itemName: String, itemCount: Double) {
                self.modelId = modelId
                self.itemName = itemName
                self.itemCount = itemCount
            }
        }

        /// The financial analysis over the system's lifetime (`FinancialAnalysis`).
        public struct FinancialAnalysis: Sendable, Hashable {
            /// The initial cost of the system.
            public let systemPrice: Double
            /// Return from incentives.
            public let returnFromIncentives: Double
            /// The net payment for the system.
            public let netPayments: Double
            /// Total bill savings for the entire lifetime of the system.
            public let totalBillSaving: Double
            /// Total bill savings with non SE inverter for the entire lifetime of the system.
            public let totalBillSavingWithNonSe: Double
            /// Total profit for the entire lifetime of the system.
            public let systemProfit: Double
            /// The internal return rate for the system in percent.
            public let internalReturnRate: Double
            /// ROI for the system.
            public let returnOfInvestment: Double
            /// Levelized cost of energy.
            public let levelizedCostOfEnergy: Double
            /// Payback period for the system in years.
            public let paybackPeriod: Double
            /// The base price for the system.
            public let basePrice: Double
            /// The expected electricity price escalation.
            public let electricityPriceEscalation: Double
            /// The cash flow per year.
            public let yearlyCashFlowList: [YearlyCashFlow]

            public init(systemPrice: Double, returnFromIncentives: Double, netPayments: Double, totalBillSaving: Double, totalBillSavingWithNonSe: Double, systemProfit: Double, internalReturnRate: Double, returnOfInvestment: Double, levelizedCostOfEnergy: Double, paybackPeriod: Double, basePrice: Double, electricityPriceEscalation: Double, yearlyCashFlowList: [YearlyCashFlow]) {
                self.systemPrice = systemPrice
                self.returnFromIncentives = returnFromIncentives
                self.netPayments = netPayments
                self.totalBillSaving = totalBillSaving
                self.totalBillSavingWithNonSe = totalBillSavingWithNonSe
                self.systemProfit = systemProfit
                self.internalReturnRate = internalReturnRate
                self.returnOfInvestment = returnOfInvestment
                self.levelizedCostOfEnergy = levelizedCostOfEnergy
                self.paybackPeriod = paybackPeriod
                self.basePrice = basePrice
                self.electricityPriceEscalation = electricityPriceEscalation
                self.yearlyCashFlowList = yearlyCashFlowList
            }
        }

        /// The installed system.
        public let installedSystem: InstalledSystem
        /// How many devices of each kind the design has.
        public let projectDesign: ProjectDesign
        /// Summary results of the simulation.
        public let simulationResults: SimulationResults
        /// The estimated energy for each month.
        public let estimatedMonthlyEnergy: [MonthlyEnergy]
        /// Yearly production and consumption totals.
        public let productionAndConsumption: ProductionAndConsumption
        /// Where consumption comes from and production goes.
        public let productionConsumptionDetails: ProductionConsumptionDetails
        /// Where stored energy comes from and goes.
        public let storageEnergyBreakdownDetails: StorageEnergyBreakdown
        /// The financial analysis.
        public let detailedFinancialAnalysis: FinancialAnalysis
        /// The bills and savings per year.
        public let annualSavings: [AnnualSavings]
        /// Battery figures.
        public let storageReportData: StorageReportData
        /// The bill of materials.
        public let billOfMaterials: BillOfMaterials

        public init(installedSystem: InstalledSystem, projectDesign: ProjectDesign, simulationResults: SimulationResults,
                    estimatedMonthlyEnergy: [MonthlyEnergy], productionAndConsumption: ProductionAndConsumption,
                    productionConsumptionDetails: ProductionConsumptionDetails, storageEnergyBreakdownDetails: StorageEnergyBreakdown,
                    detailedFinancialAnalysis: FinancialAnalysis, annualSavings: [AnnualSavings],
                    storageReportData: StorageReportData, billOfMaterials: BillOfMaterials) {
            self.installedSystem = installedSystem
            self.projectDesign = projectDesign
            self.simulationResults = simulationResults
            self.estimatedMonthlyEnergy = estimatedMonthlyEnergy
            self.productionAndConsumption = productionAndConsumption
            self.productionConsumptionDetails = productionConsumptionDetails
            self.storageEnergyBreakdownDetails = storageEnergyBreakdownDetails
            self.detailedFinancialAnalysis = detailedFinancialAnalysis
            self.annualSavings = annualSavings
            self.storageReportData = storageReportData
            self.billOfMaterials = billOfMaterials
        }
    }

    /// The estimation of a site's default design, as returned by
    /// ``EstimationService/estimation(for:)``: either the estimation, or a
    /// message that the site is still being designed (e.g. by Auto Design).
    public enum SiteEstimation: Sendable, Hashable {
        /// The estimation.
        case ready(Estimation)
        /// The site is still in design. The message includes the progress,
        /// e.g. `Site is still in design. The progress is: 0.5.`
        case stillInDesign(message: String)
    }
}
