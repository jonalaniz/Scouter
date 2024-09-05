//
//  ConversationContainer.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/29/24.
//

import Foundation

struct ConversationContainer: Codable {
    let container: ConversationsContainer
    let page: Page

    enum CodingKeys: String, CodingKey {
        case container = "_embedded"
        case page
    }
    
    init(container: ConversationsContainer, page: Page) {
        self.container = container
        self.page = page
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.embeddedd = try container.decode(EmbeddedConversations.self, forKey: .embedded)
//        self.page = try container.decode(Page.self, forKey: .page)
//    }
}

struct ConversationsContainer: Codable {
    let conversations: [ConversationPreview]
}

struct ConversationPreview: Codable {
    let id: Int
    let number: Int
    let threadCount: Int?
    let type: String
    let folderId: Int
    let status: String
    let state: String
    let subject: String
    let preview: String
    let mailboxID: String?
    let assignee: User?
    let createdBy: User
    let createdAt: String
    let updatedAt: String
    let closedBy: Int?
    let closedByUser: User?
    let closedAt: String?
    let userUpdatedAt: String?
    let customerWaitingSince: TimeFrame
    let source: Source
    let cc: [String]
    let bcc: [String]
    let customer: User
}
