//
//  Source.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import Foundation

enum SourceType: String, Codable {
    case email
    case web
    case api
}

struct Source: Codable {
    let type: SourceType
    let via: Person
}
