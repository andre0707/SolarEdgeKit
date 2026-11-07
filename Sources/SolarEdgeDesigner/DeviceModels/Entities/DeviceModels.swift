//
//  DeviceModels.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// The inverters, optimizers and batteries available for a region, grid
    /// and sector, as returned by
    /// ``DeviceModelsService/models(for:countryCode:stateCode:sector:)``.
    ///
    /// The design rules are part of the inverters.
    public struct DeviceModels: Sendable, Hashable {
        /// The sector to filter device models by.
        public enum Sector: String, Sendable, Hashable, CaseIterable {
            /// Residential models.
            case residential
            /// Commercial models.
            case commercial
            /// Models of both sectors.
            case all
        }

        /// The inverter models, keyed as the API sends them. The spec does
        /// not say what the keys are.
        public let inverters: [String: InverterModel]
        /// The optimizer models, keyed as the API sends them.
        public let optimizers: [String: OptimizerModel]
        /// The battery models, keyed as the API sends them.
        public let batteries: [String: BatteryModel]

        public init(inverters: [String: InverterModel], optimizers: [String: OptimizerModel], batteries: [String: BatteryModel]) {
            self.inverters = inverters
            self.optimizers = optimizers
            self.batteries = batteries
        }
    }
}
