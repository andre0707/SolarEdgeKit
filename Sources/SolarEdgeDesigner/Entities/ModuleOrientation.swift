//
//  ModuleOrientation.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// How PV modules are turned.
    public enum ModuleOrientation: String, Sendable, Hashable, CaseIterable {
        /// `PORTRAIT`.
        case portrait = "PORTRAIT"
        /// `LANDSCAPE`.
        case landscape = "LANDSCAPE"
    }
}
