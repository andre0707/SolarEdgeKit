import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import SolarEdgeONE
import SolarEdgeCore

/// `sites.all()`: on-demand paging and when it stops.
struct SiteSequenceTests {

    /// Answers each page request with the IDs from `pages` (1-based), and
    /// records the page numbers asked for. A page without an entry is empty;
    /// a page listed in `failing` answers with a 500.
    actor PagingTransport: HTTPTransport {
        let pages: [Int: [Int]]
        let totalCount: Int
        let failing: Set<Int>
        var requestedPages: [Int] = []

        init(pages: [Int: [Int]], totalCount: Int = Int(Int32.min), failing: Set<Int> = []) {
            self.pages = pages
            self.totalCount = totalCount
            self.failing = failing
        }

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            let items = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems ?? []
            let page = Int(items.first { $0.name == "page" }?.value ?? "") ?? 0
            requestedPages.append(page)

            let status = failing.contains(page) ? 500 : 200
            let sites = (pages[page] ?? []).map { id in
                """
                {"siteId": \(id), "name": "Site \(id)", "peakPower": 10, "installationDate": "2026-03-10",
                 "location": {"address": "", "city": "", "state": "", "zip": null, "country": ""},
                 "activationStatus": "Active", "note": ""}
                """
            }
            let body = #"{"sites": {"count": \#(totalCount), "site": [\#(sites.joined(separator: ","))]}}"#
            return (Data(body.utf8), HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!)
        }
    }

    func sites(_ transport: PagingTransport) -> SitesService {
        SitesService(client: APIClient(baseURL: URL(string: "https://example.invalid")!, credentials: .apiKey("123"), transport: transport))
    }

    func ids(_ sequence: Monitoring.SiteSequence) async throws -> [Int] {
        var result: [Int] = []
        for try await site in sequence { result.append(site.id.rawValue) }
        return result
    }

    @Test
    func pagesAreFetchedOnlyWhenNeeded() async throws {
        let transport = PagingTransport(pages: [1: [1, 2], 2: [3, 4]])

        for try await site in sites(transport).all(pageSize: 2) {
            if site.id == 1 { break }
        }
        #expect(await transport.requestedPages == [1])
    }

    @Test
    func stopsAtTheTotalCount() async throws {
        let transport = PagingTransport(pages: [1: [1, 2], 2: [3, 4], 3: [5, 6]], totalCount: 4)

        #expect(try await ids(sites(transport).all(pageSize: 2)) == [1, 2, 3, 4])
        #expect(await transport.requestedPages == [1, 2])
    }

    @Test
    func withoutATotalStopsAtAShortPage() async throws {
        let transport = PagingTransport(pages: [1: [1, 2], 2: [3]])

        #expect(try await ids(sites(transport).all(pageSize: 2)) == [1, 2, 3])
        #expect(await transport.requestedPages == [1, 2])
    }

    @Test
    func anEmptyPageEndsTheSequenceEvenIfTheTotalSaysMore() async throws {
        let transport = PagingTransport(pages: [1: [1, 2]], totalCount: 10)

        #expect(try await ids(sites(transport).all(pageSize: 2)) == [1, 2])
        #expect(await transport.requestedPages == [1, 2])
    }

    @Test
    func aRepeatedPageThrowsInsteadOfLooping() async throws {
        let transport = PagingTransport(pages: [1: [1, 2], 2: [1, 2], 3: [1, 2]])

        await #expect {
            _ = try await ids(sites(transport).all(pageSize: 2))
        } throws: { error in
            guard case SolarEdgeError.decodingWithMessage = error else { return false }
            return true
        }
        #expect(await transport.requestedPages == [1, 2])
    }

    @Test
    func anErrorOnALaterPageReachesTheCallerAfterTheEarlierSites() async throws {
        let transport = PagingTransport(pages: [1: [1, 2], 2: [3, 4]], failing: [2])
        var iterator = sites(transport).all(pageSize: 2).makeAsyncIterator()

        #expect(try await iterator.next()?.id == 1)
        #expect(try await iterator.next()?.id == 2)
        await #expect(throws: SolarEdgeError.self) { _ = try await iterator.next() }
        // After an error the iterator is finished.
        #expect(try await iterator.next() == nil)
        #expect(await transport.requestedPages == [1, 2])
    }

    @Test
    func anInvalidPageSizeIsThrownByTheFirstIteration() async throws {
        let transport = PagingTransport(pages: [:])

        await #expect(throws: SolarEdgeError.self) { _ = try await ids(sites(transport).all(pageSize: 0)) }
        #expect(await transport.requestedPages.isEmpty)
    }
}
