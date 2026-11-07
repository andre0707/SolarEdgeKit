//
//  SiteSequence.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

import Foundation
import SolarEdgeCore

extension Monitoring {
    /// All sites matching a filter, fetched page by page as you iterate.
    ///
    /// A page is requested only when the sites of the previous one are used
    /// up, so leaving the loop early costs no further requests. Returned by
    /// ``SitesService/all(filter:pageSize:)``.
    ///
    /// The sequence ends when a page is the last one by ``SitePage/mayHaveMore``,
    /// or when a page is empty. If a page returns exactly the sites of the
    /// page before, the server ignores the page number; the sequence then
    /// throws instead of requesting the same page forever.
    public struct SiteSequence: AsyncSequence, Sendable {
        public typealias Element = Site

        let service: SitesService
        let filter: SiteFilter
        let pageSize: Int

        public func makeAsyncIterator() -> AsyncIterator {
            AsyncIterator(service: service, filter: filter, pageSize: pageSize)
        }

        public struct AsyncIterator: AsyncIteratorProtocol {
            let service: SitesService
            let filter: SiteFilter
            let pageSize: Int

            private var buffer: [Site] = []
            private var index = 0
            private var nextPage = 1
            private var finished = false
            private var previousIDs: [Site.ID] = []

            init(service: SitesService, filter: SiteFilter, pageSize: Int) {
                self.service = service
                self.filter = filter
                self.pageSize = pageSize
            }

            public mutating func next() async throws -> Site? {
                while index >= buffer.count {
                    guard !finished else { return nil }
                    do {
                        try await loadNextPage()
                    } catch {
                        finished = true
                        throw error
                    }
                }
                defer { index += 1 }
                return buffer[index]
            }

            private mutating func loadNextPage() async throws {
                let page = try await service.list(filter: filter, page: nextPage, pageSize: pageSize)
                let ids = page.sites.map(\.id)

                if ids.isEmpty {
                    finished = true
                    return
                }
                if ids == previousIDs {
                    throw SolarEdgeError.decodingWithMessage(
                        message: "Page \(nextPage) returned the same sites as page \(nextPage - 1); the server seems to ignore the page number"
                    )
                }

                previousIDs = ids
                buffer = page.sites
                index = 0
                finished = !page.mayHaveMore
                nextPage += 1
            }
        }
    }
}
