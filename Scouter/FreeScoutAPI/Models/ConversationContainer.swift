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
    // TODO: Make this a special type that can be either Array or Dictionary
    // [String} || [Int: String]
    let cc: CCType
    let bcc: [String]
    let customer: User
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
