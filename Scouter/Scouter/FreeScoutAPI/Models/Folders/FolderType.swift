//
//  FolderType.swift
//  Kami
//
//  Created by Jon Alaniz on 6/16/25.
//

import Foundation

/// Represents the different types of folders used within the application.
///
/// Folders may be either global or specific to an individual user, depending on
/// the folder type. The raw integer values match those defined by the backend API.
enum FolderType: Int, Codable {
    // MARK: - Public (Non-user specific) Folder Types

    /// Unassigned conversations.
    case unassigned = 1

    /// Draft messages saved but not sent.
    case drafts = 30

    /// Conversations that have been assigned to any user.
    case assigned = 40

    /// Conversations that have been closed.
    case closed = 60

    /// Conversations that have been deleted.
    case deleted = 70

    /// Conversations identified as spam.
    case spam = 80

    // MARK: - User-specific Folder Types

    /// Conversations assigned specifically to the current user.
    ///
    /// This folder contains an associated `userId`.
    case mine = 20

    /// Conversations manually starred by the current user.
    ///
    /// This folder requires an associated `userId`.
    case starred = 25

    /// A human-readable name for the folder type.
    var name: String {
        switch self {
        case .unassigned: return "Unassigned"
        case .drafts: return "Drafts"
        case .assigned: return "Assigned"
        case .closed: return "Closed"
        case .deleted: return "Deleted"
        case .spam: return "Spam"
        case .mine: return "Mine"
        case .starred: return "Starred"
        }
    }
}
