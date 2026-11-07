//
//  SharableLinks.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// Public links to a design's report and proposal, and how complete the
    /// design is, as returned by ``SharableLinksService``.
    public struct SharableLinks: Sendable, Hashable {
        /// Which parts of a design are defined.
        public struct CompletionState: Sendable, Hashable {
            /// Whether the design has defined system pricing.
            public let hasSystemPricing: Bool
            /// Whether the design has a defined import utility rate.
            public let hasImportRate: Bool
            /// Whether the design has a defined export utility rate.
            public let hasExportRate: Bool
            /// Whether the design has a defined consumption profile.
            public let hasConsumptionProfile: Bool
            /// Whether the electrical design is valid.
            public let isElectricalDesignValid: Bool

            public init(hasSystemPricing: Bool, hasImportRate: Bool, hasExportRate: Bool,
                        hasConsumptionProfile: Bool, isElectricalDesignValid: Bool) {
                self.hasSystemPricing = hasSystemPricing
                self.hasImportRate = hasImportRate
                self.hasExportRate = hasExportRate
                self.hasConsumptionProfile = hasConsumptionProfile
                self.isElectricalDesignValid = isElectricalDesignValid
            }
        }

        /// The public URL of the design's report.
        public let reportURL: URL
        /// The public URL of the design's proposal.
        public let proposalURL: URL
        /// Which parts of the design are defined.
        public let siteCompletionState: CompletionState

        public init(reportURL: URL, proposalURL: URL, siteCompletionState: CompletionState) {
            self.reportURL = reportURL
            self.proposalURL = proposalURL
            self.siteCompletionState = siteCompletionState
        }
    }
}
