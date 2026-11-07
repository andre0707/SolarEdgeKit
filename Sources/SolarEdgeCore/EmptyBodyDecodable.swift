//
//  EmptyBodyDecodable.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

/// A response type that also accepts a `200` without a body.
///
/// Use an optional DTO as an endpoint's `Response` when the API may answer
/// with or without a body, e.g. `typealias Response = StartDTO?`: an empty
/// body gives `nil`, a JSON body decodes as usual.
package protocol EmptyBodyDecodable {
    static var emptyBody: Self { get }
}

extension Optional: EmptyBodyDecodable where Wrapped: Decodable {
    package static var emptyBody: Self { nil }
}
