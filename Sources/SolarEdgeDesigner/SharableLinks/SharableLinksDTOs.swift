//
//  SharableLinksDTOs.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

/// `SharableLinksResponse`.
struct SharableLinksResponseDTO: Codable {
    let reportUrl: String
    let proposalUrl: String
    let siteCompletionState: SiteCompletionStateDTO
}

/// `SiteCompletionState`.
struct SiteCompletionStateDTO: Codable {
    let hasSystemPricing: Bool
    let hasImportRate: Bool
    let hasExportRate: Bool
    let hasConsumptionProfile: Bool
    let isElectricalDesignValid: Bool
}


extension SharableLinksResponseDTO {
    var entity: Designer.SharableLinks {
        get throws {
            guard let reportURL = URL(string: reportUrl) else {
                throw SolarEdgeError.decodingWithMessage(message: "Invalid URL for field 'reportUrl'. Value: \(reportUrl)")
            }
            guard let proposalURL = URL(string: proposalUrl) else {
                throw SolarEdgeError.decodingWithMessage(message: "Invalid URL for field 'proposalUrl'. Value: \(proposalUrl)")
            }

            return Designer.SharableLinks(
                reportURL: reportURL,
                proposalURL: proposalURL,
                siteCompletionState: Designer.SharableLinks.CompletionState(
                    hasSystemPricing: siteCompletionState.hasSystemPricing,
                    hasImportRate: siteCompletionState.hasImportRate,
                    hasExportRate: siteCompletionState.hasExportRate,
                    hasConsumptionProfile: siteCompletionState.hasConsumptionProfile,
                    isElectricalDesignValid: siteCompletionState.isElectricalDesignValid
                )
            )
        }
    }
}
