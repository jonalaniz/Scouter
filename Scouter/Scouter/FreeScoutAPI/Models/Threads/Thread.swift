//
//  Threads.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/16/25.
//

import Foundation

// swiftlint:disable identifier_name
struct Thread: Codable {
    let id: Int
    let type: ThreadType
    let status: ThreadStatus
    let state: ThreadState
    let action: Action
    let body: String?
    let source: Source
    let customer, createdBy, assignedTo: ConversationUser?
    let to: [String]
    let cc, bcc: CCType
    let createdAt: String
    let openedAt: String?
    let embedded: EmbeddedAttachments

    enum CodingKeys: String, CodingKey {
        case id, type, status, state, action, body, source, customer
        case createdBy, assignedTo, to, cc, bcc, createdAt, openedAt
        case embedded = "_embedded"
    }
}
