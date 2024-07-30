//
//  Page.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import Foundation

struct Page: Codable {
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let number: Int
}
