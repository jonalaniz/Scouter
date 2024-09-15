//
//  MailboxContainer.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import Foundation

struct MailboxContainer: Codable {
    let embeddedMailboxes: EmbeddedMailboxes
    let page: Page
    
    enum CodingKeys: String, CodingKey {
        case embeddedMailboxes = "_embedded"
        case page
    }

    init(embeddedMailboxes: EmbeddedMailboxes, page: Page) {
        self.embeddedMailboxes = embeddedMailboxes
        self.page = page
    }
}

struct EmbeddedMailboxes: Codable {
    let mailboxes: [Mailbox]
}

struct Mailbox: Codable {
    let id: Int
    let name: String
    let email: String
    let createdAt: String
    let updatedAt: String
}
