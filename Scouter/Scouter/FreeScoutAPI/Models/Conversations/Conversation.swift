//
//  Conversation.swift
//  Kami
//
//  Created by Jon Alaniz on 12/1/24.
//

import Foundation

// swiftlint:disable identifier_name
struct Conversation: Codable {
    let id, number, threadsCount: Int
    let type: ConversationType
    let folderID: Int
    let status: ConversationStatus
    let state: ConversationState
    let subject, preview: String
    let mailboxID: Int
    let assignee: Assignee
    let createdBy: ConversationUser?
    let createdAt: String
    let updatedAt: String?
    let closedBy: Int?
    let closedByUser: ConversationUser?
    let closedAt: String?
    let userUpdatedAt: String?
    let customerWaitingSince: TimeFrame
    let source: Source
    let cc, bcc: CCType
    let customer: ConversationUser
    let embedded: EmbeddedThreads
    let customFields: [CustomField]?

    enum CodingKeys: String, CodingKey {
        case id, number, threadsCount, type
        case folderID = "folderId"
        case status, state, subject, preview
        case mailboxID = "mailboxId"
        case assignee, createdBy, createdAt, updatedAt
        case closedBy, closedByUser, closedAt, userUpdatedAt
        case customerWaitingSince, source, cc, bcc, customer
        case embedded = "_embedded"
        case customFields
    }
}

struct Assignee: Codable {
    let id: Int
    let type: String?
    let firstName: String?
    let lastName: String?
    let email: String

    func name() -> String {
        var name = ""
        if let firstName = firstName {
            name += firstName
        }

        if let lastName = lastName {
            name += " " + lastName
        }

        if name == "" {
            name += email
        }

        return name
    }
}

struct ConversationUser: Codable {
    let id: Int
    let type: String?
    let firstName: String?
    let lastName: String?
    let photoUrl: String?
    let email: String

    func name() -> String {
        var name = ""
        if let firstName = firstName {
            name += firstName
        }

        if let lastName = lastName {
            name += " " + lastName
        }

        if name == "" {
            name += email
        }

        return name
    }
}

struct EmbeddedThreads: Codable {
    let threads: [Thread]
    let timelogs: [Timelog]
    let tags: [Tag]
}

struct Thread: Codable {
    let id: Int
    let type, status, state: String
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

struct Action: Codable {
    let type, text: String
//    let associatedEntities: [Any]
}

struct EmbeddedAttachments: Codable {
    let attachments: [Attachment]
}

struct Attachment: Codable {
    let id: Int
    let fileName: String
    let fileURL: String
    let mimeType: String
    let size: Int

    enum CodingKeys: String, CodingKey {
        case id, fileName
        case fileURL = "fileUrl"
        case mimeType, size
    }
}
