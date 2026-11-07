//
//  GatewayErrorDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

/// Error body of the API gateway, for `401` and `429`.
///
/// Error bodies are read best-effort, so every field is optional: a strict
/// decode failure would lose the server's reason. The spec also says the
/// fields come in pairs: `message` and `request_id` for a wrong key or a
/// limit, `error` and `error_description` for a missing key or token.
struct GatewayErrorDTO: Decodable {
    let message: String?
    let requestId: String?
    let error: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case message
        case requestId = "request_id"
        case error
        case errorDescription = "error_description"
    }
}


extension GatewayErrorDTO {
    /// `nil` if the body carries none of the fields.
    var entity: SolarEdgeError.ErrorDetails? {
        let details = SolarEdgeError.ErrorDetails(message: errorDescription ?? message,
                                                  code: error,
                                                  requestID: requestId,
                                                  fieldErrors: [:])
        return details.isEmpty ? nil : details
    }
}
