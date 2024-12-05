//
//  Configuration.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/29/24.
//

import Foundation

struct Configuration: Codable {
    let secret: Secret
    let fetchInterval: FetchInterval
    let mailboxID: Int
    let ignoredFolders: Set<String>?
}
