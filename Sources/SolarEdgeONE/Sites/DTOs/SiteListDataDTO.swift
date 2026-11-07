//
//  SiteListDataDTO.swift
//  SolarEdgeKit
//
//  Created by Andre Albach on 07.11.26.
//

struct SiteListDataDTO: Codable {
    let count: Int
    let site: [SiteMetadataDTO]
}
