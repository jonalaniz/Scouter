//
//  Folders.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import Foundation

// swiftlint:disable identifier_name
struct Folders: Codable {
    let container: FoldersContainer
    let page: Page

    enum CodingKeys: String, CodingKey {
        case container = "_embedded"
        case page
    }

    init(container: FoldersContainer, page: Page) {
        self.container = container
        self.page = page
    }
}

struct FoldersContainer: Codable {
    let folders: [Folder]
}

struct Folder: Codable {
    let id: Int
    let name: String
    let type: Int
    let userId: Int?
    let totalCount: Int
    let activeCount: Int
    // let meta
}
