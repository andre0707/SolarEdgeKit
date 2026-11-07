//
//  AutoDesignStatus.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation

extension Designer {
    /// A started Auto Design, as returned by ``AutoDesignService/start(_:)``.
    public struct AutoDesignRequest: Sendable, Hashable {
        /// The ID of an Auto Design request, for
        /// ``AutoDesignService/status(of:)``.
        ///
        /// String literals work directly.
        public struct ID: Sendable, Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {
            /// The ID as used by the API.
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
            public init(stringLiteral value: String) { self.rawValue = value }
            public var description: String { rawValue }
        }

        /// The request, for ``AutoDesignService/status(of:)``.
        public let requestID: ID
        /// The new site.
        public let siteID: SiteID

        public init(requestID: ID, siteID: SiteID) {
            self.requestID = requestID
            self.siteID = siteID
        }
    }

    /// The latest status of an Auto Design (`AutoDesignStatusResponse`), as
    /// returned by ``AutoDesignService/status(of:)``.
    public struct AutoDesignStatus: Sendable, Hashable {
        /// Why an Auto Design failed.
        public enum ErrorCode: Sendable, Hashable, CaseIterable, RawRepresentable {
            /// `UNKNOWN_ERROR`.
            case unknownError
            /// `SITE_NAME_ALREADY_EXISTS`.
            case siteNameAlreadyExists
            /// `UNABLE_TO_CREATE_SITE`.
            case unableToCreateSite
            /// `PARSING_ERROR`.
            case parsingError
            /// `MISSING_PV_MODEL_ID`: no module model given, and the account
            /// has no favourite PV module.
            case missingPvModelID
            /// `INVALID_PHASE`.
            case invalidPhase
            /// A value this version of the package does not know yet, as the
            /// API sent it. New values are added on the server over time.
            case unknown(String)

            /// The known values, without ``unknown(_:)``.
            public static let allCases: [ErrorCode] = [.unknownError, .siteNameAlreadyExists, .unableToCreateSite, .parsingError, .missingPvModelID, .invalidPhase]

            /// The case for an API value, or ``unknown(_:)``. Never `nil`.
            public init(rawValue: String) {
                self = Self.allCases.first { $0.rawValue == rawValue } ?? .unknown(rawValue)
            }

            /// The value as the API sends it.
            public var rawValue: String {
                switch self {
                case .unknownError: "UNKNOWN_ERROR"
                case .siteNameAlreadyExists: "SITE_NAME_ALREADY_EXISTS"
                case .unableToCreateSite: "UNABLE_TO_CREATE_SITE"
                case .parsingError: "PARSING_ERROR"
                case .missingPvModelID: "MISSING_PV_MODEL_ID"
                case .invalidPhase: "INVALID_PHASE"
                case .unknown(let rawValue): rawValue
                }
            }
        }

        /// The site being designed.
        public let siteID: SiteID
        /// The steps executed so far, with a number each. The spec does not
        /// name the steps or say what the number means.
        public let executedSteps: [String: Double]
        /// The error code.
        public let errorCode: ErrorCode

        public init(siteID: SiteID, executedSteps: [String: Double], errorCode: ErrorCode) {
            self.siteID = siteID
            self.executedSteps = executedSteps
            self.errorCode = errorCode
        }
    }
}
