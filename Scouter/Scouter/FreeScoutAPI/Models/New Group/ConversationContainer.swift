//
//  ConversationContainer.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/29/24.
//

import Foundation

// swiftlint:disable identifier_name
struct ConversationContainer: Codable {
    let embedded: EmbeddedConversations
    let page: Page

    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case page
    }

    init(container: EmbeddedConversations, page: Page) {
        self.embedded = container
        self.page = page
    }
}

struct EmbeddedConversations: Codable {
    let conversations: [ConversationPreview]
}

struct ConversationPreview: Codable {
    let id: Int
    let number: Int
    let threadCount: Int?
    let type: ConversationType
    let folderId: Int
    let status: ConversationStatus
    let state: ConversationState
    let subject: String
    let preview: String
    let mailboxID: String?
    let assignee: Assignee?
    let createdBy: ConversationUser?
    let createdAt: String
    let updatedAt: String
    let closedBy: Int?
    let closedByUser: ConversationUser?
    let closedAt: String?
    let userUpdatedAt: String?
    let customerWaitingSince: TimeFrame
    let source: Source
    let cc: CCType
    let bcc: [String]
    let customer: ConversationUser?
}

enum CCType: Codable {
    case array([String])
    case dictionary([Int: String])

    var arrayValue: [String]? {
        switch self {
        case .array(let array): return array
        default: return nil
        }
    }

    var dictionaryValue: [Int: String]? {
        switch self {
        case .dictionary(let dictionary): return dictionary
        default: return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let data = try? container.decode([String].self) {
            self = .array(data)
            return
        }

        if let data = try? container.decode([Int: String].self) {
            self = .dictionary(data)
            return
        }

        throw DecodingError.typeMismatch(
            CCType.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "ccType Mismatch"
            )
        )
    }
}
