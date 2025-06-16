//
//  ConversationStatus.swift
//  Kami
//
//  Created by Jon Alaniz on 6/15/25.
//

import Foundation

// Conversation Statys type (equals thread status).
enum ConversationStatus: String, Codable {
    case active
    case pending
    case closed
    case spam

    // Unused status type
    case open
}
