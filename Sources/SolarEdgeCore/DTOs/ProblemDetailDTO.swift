//
//  ProblemDetailDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

/// RFC 9457 `problem+json` error body, for `400`, `403` and `404`.
///
/// Error bodies are read best-effort, so every field is optional: a strict
/// decode failure would lose the server's reason. The spec's free-form
/// `properties` object is not decoded.
struct ProblemDetailDTO: Decodable {
    let type: String?
    let title: String?
    let status: Int?
    let detail: String?
    let instance: String?
    let traceId: String?
    /// Field-level validation errors keyed by parameter name.
    let errors: [String: String]?
}


extension ProblemDetailDTO {
    /// `nil` if the body carries none of the fields used here.
    var entity: SolarEdgeError.ErrorDetails? {
        let details = SolarEdgeError.ErrorDetails(message: detail ?? title,
                                                  code: nil,
                                                  requestID: traceId,
                                                  fieldErrors: errors ?? [:])
        return details.isEmpty ? nil : details
    }
}
