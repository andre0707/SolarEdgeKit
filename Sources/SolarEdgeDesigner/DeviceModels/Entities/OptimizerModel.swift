//
//  OptimizerModel.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// An optimizer model, as returned by
    /// ``DeviceModelsService/models(for:countryCode:stateCode:sector:)``.
    ///
    /// The spec documents neither meaning nor units of these values; names
    /// and types mirror it. Its `displayName` and `weightedEfficiency` are
    /// marked write-only, so the API does not return them.
    public struct OptimizerModel: Sendable, Hashable {
        /// The values of `type`.
        public enum OptimizerType: Sendable, Hashable, CaseIterable, RawRepresentable {
            /// `DEFAULT`.
            case `default`
            /// `S_SERIES`.
            case sSeries
            /// A value this version of the package does not know yet, as the
            /// API sent it. New values are added on the server over time.
            case unknown(String)

            /// The known values, without ``unknown(_:)``.
            public static let allCases: [OptimizerType] = [.`default`, .sSeries]

            /// The case for an API value, or ``unknown(_:)``. Never `nil`.
            public init(rawValue: String) {
                self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
            }

            /// The value as the API sends it.
            public var rawValue: String {
                switch self {
                case .default: "DEFAULT"
                case .sSeries: "S_SERIES"
                case .unknown(let rawValue): rawValue
                }
            }
        }

        /// The values of `mountLocation`.
        public enum MountLocation: Sendable, Hashable, CaseIterable, RawRepresentable {
            /// `ALL`.
            case all
            /// `GROUND`.
            case ground
            /// `ROOF`.
            case roof
            /// A value this version of the package does not know yet, as the
            /// API sent it. New values are added on the server over time.
            case unknown(String)

            /// The known values, without ``unknown(_:)``.
            public static let allCases: [MountLocation] = [.all, .ground, .roof]

            /// The case for an API value, or ``unknown(_:)``. Never `nil`.
            public init(rawValue: String) {
                self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
            }

            /// The value as the API sends it.
            public var rawValue: String {
                switch self {
                case .all: "ALL"
                case .ground: "GROUND"
                case .roof: "ROOF"
                case .unknown(let rawValue): rawValue
                }
            }
        }

        /// `OptimizerEfficiencyProperties`. The spec documents neither meaning nor units of
        /// these values.
        public struct Efficiency: Sendable, Hashable {
            /// Efficiency 5.
            public let efficiency5: Double
            /// Efficiency 10.
            public let efficiency10: Double
            /// Efficiency 20.
            public let efficiency20: Double
            /// Efficiency 30.
            public let efficiency30: Double
            /// Efficiency 50.
            public let efficiency50: Double
            /// Efficiency 100.
            public let efficiency100: Double
            /// Boost 5.
            public let boost5: Double
            /// Boost 10.
            public let boost10: Double
            /// Boost 20.
            public let boost20: Double
            /// Boost 30.
            public let boost30: Double
            /// Boost 50.
            public let boost50: Double
            /// Boost 100.
            public let boost100: Double
            /// Boost ratio.
            public let boostRatio: Double
            /// Buck 5.
            public let buck5: Double
            /// Buck 10.
            public let buck10: Double
            /// Buck 20.
            public let buck20: Double
            /// Buck 30.
            public let buck30: Double
            /// Buck 50.
            public let buck50: Double
            /// Buck 100.
            public let buck100: Double
            /// Buck ratio.
            public let buckRatio: Double
            /// Low power 0.
            public let lowPower0: Double
            /// Low power 3.
            public let lowPower3: Double
            /// Low power 4.
            public let lowPower4: Double
            /// Low power 6.
            public let lowPower6: Double
            /// Low power 8.
            public let lowPower8: Double
            /// Low power 10.
            public let lowPower10: Double
            /// Low power 15.
            public let lowPower15: Double
            /// Low power 20.
            public let lowPower20: Double
            /// Low power 25.
            public let lowPower25: Double
            /// Low power 30.
            public let lowPower30: Double
            /// Low power 35.
            public let lowPower35: Double
            /// Low power 40.
            public let lowPower40: Double

            public init(efficiency5: Double, efficiency10: Double, efficiency20: Double, efficiency30: Double, efficiency50: Double, efficiency100: Double, boost5: Double, boost10: Double, boost20: Double, boost30: Double, boost50: Double, boost100: Double, boostRatio: Double, buck5: Double, buck10: Double, buck20: Double, buck30: Double, buck50: Double, buck100: Double, buckRatio: Double, lowPower0: Double, lowPower3: Double, lowPower4: Double, lowPower6: Double, lowPower8: Double, lowPower10: Double, lowPower15: Double, lowPower20: Double, lowPower25: Double, lowPower30: Double, lowPower35: Double, lowPower40: Double) {
                self.efficiency5 = efficiency5
                self.efficiency10 = efficiency10
                self.efficiency20 = efficiency20
                self.efficiency30 = efficiency30
                self.efficiency50 = efficiency50
                self.efficiency100 = efficiency100
                self.boost5 = boost5
                self.boost10 = boost10
                self.boost20 = boost20
                self.boost30 = boost30
                self.boost50 = boost50
                self.boost100 = boost100
                self.boostRatio = boostRatio
                self.buck5 = buck5
                self.buck10 = buck10
                self.buck20 = buck20
                self.buck30 = buck30
                self.buck50 = buck50
                self.buck100 = buck100
                self.buckRatio = buckRatio
                self.lowPower0 = lowPower0
                self.lowPower3 = lowPower3
                self.lowPower4 = lowPower4
                self.lowPower6 = lowPower6
                self.lowPower8 = lowPower8
                self.lowPower10 = lowPower10
                self.lowPower15 = lowPower15
                self.lowPower20 = lowPower20
                self.lowPower25 = lowPower25
                self.lowPower30 = lowPower30
                self.lowPower35 = lowPower35
                self.lowPower40 = lowPower40
            }
        }

        /// ID.
        public let id: String
        /// Type.
        public let type: OptimizerType
        /// Embedded.
        public let embedded: Bool
        /// Minimum power.
        public let minPower: Double
        /// Maximum power.
        public let maxPower: Double
        /// Maximum input current.
        public let maxInputCurrent: Double
        /// Maximum output current.
        public let maxOutputCurrent: Double
        /// Maximum input voltage.
        public let maxInputVoltage: Double
        /// Maximum output voltage.
        public let maxOutputVoltage: Double
        /// Cost.
        public let cost: Double
        /// Maximum parallel ratio.
        public let maxParallelRatio: Int
        /// Maximum serial ratio.
        public let maxSerialRatio: Int
        /// Maximum ratio.
        public let maxRatio: Int
        /// Minimum requested ratio.
        public let minRequestedRatio: Int
        /// Discontinued.
        public let discontinued: Bool
        /// Deleted.
        public let deleted: Bool
        /// Number of inputs.
        public let numOfInputs: Int
        /// Number of primary inputs.
        public let numOfPrimaryInputs: Int
        /// Editable.
        public let editable: Bool
        /// Only equivalent modules allowed.
        public let onlyEquivalentModulesAllowed: Bool
        /// Minimum module cell count.
        public let minModuleCellCount: Int
        /// Mount location.
        public let mountLocation: MountLocation
        /// Mixing in inverter allowed.
        public let mixingInInverterAllowed: Bool
        /// Cable length.
        public let cableLength: Double
        /// Buck only.
        public let buckOnly: Bool
        /// Experimental.
        public let experimental: Bool
        /// Made in country.
        public let madeInCountry: String
        /// Detailed efficiency.
        public let detailedEfficiency: Efficiency
        /// Name.
        public let name: String
        /// Dual optimizer.
        public let dualOptimizer: Bool
        /// Quad optimizer.
        public let quadOptimizer: Bool
        /// Efficiency.
        public let efficiency: Double
        /// Single input.
        public let singleInput: Bool

        public init(id: String, type: OptimizerType, embedded: Bool, minPower: Double, maxPower: Double, maxInputCurrent: Double, maxOutputCurrent: Double, maxInputVoltage: Double, maxOutputVoltage: Double, cost: Double, maxParallelRatio: Int, maxSerialRatio: Int, maxRatio: Int, minRequestedRatio: Int, discontinued: Bool, deleted: Bool, numOfInputs: Int, numOfPrimaryInputs: Int, editable: Bool, onlyEquivalentModulesAllowed: Bool, minModuleCellCount: Int, mountLocation: MountLocation, mixingInInverterAllowed: Bool, cableLength: Double, buckOnly: Bool, experimental: Bool, madeInCountry: String, detailedEfficiency: Efficiency, name: String, dualOptimizer: Bool, quadOptimizer: Bool, efficiency: Double, singleInput: Bool) {
            self.id = id
            self.type = type
            self.embedded = embedded
            self.minPower = minPower
            self.maxPower = maxPower
            self.maxInputCurrent = maxInputCurrent
            self.maxOutputCurrent = maxOutputCurrent
            self.maxInputVoltage = maxInputVoltage
            self.maxOutputVoltage = maxOutputVoltage
            self.cost = cost
            self.maxParallelRatio = maxParallelRatio
            self.maxSerialRatio = maxSerialRatio
            self.maxRatio = maxRatio
            self.minRequestedRatio = minRequestedRatio
            self.discontinued = discontinued
            self.deleted = deleted
            self.numOfInputs = numOfInputs
            self.numOfPrimaryInputs = numOfPrimaryInputs
            self.editable = editable
            self.onlyEquivalentModulesAllowed = onlyEquivalentModulesAllowed
            self.minModuleCellCount = minModuleCellCount
            self.mountLocation = mountLocation
            self.mixingInInverterAllowed = mixingInInverterAllowed
            self.cableLength = cableLength
            self.buckOnly = buckOnly
            self.experimental = experimental
            self.madeInCountry = madeInCountry
            self.detailedEfficiency = detailedEfficiency
            self.name = name
            self.dualOptimizer = dualOptimizer
            self.quadOptimizer = quadOptimizer
            self.efficiency = efficiency
            self.singleInput = singleInput
        }
    }
}
