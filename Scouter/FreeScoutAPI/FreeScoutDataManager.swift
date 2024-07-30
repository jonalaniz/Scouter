//
//  FreeScoutDataManager.swift
//  Scouter
//
//  Created by Jon Alaniz on 7/21/24.
//

import Foundation

enum FreeScoutDataManagerStatus {
    case ready
    case needsFolders
}

protocol FreeScoutDataManagerDelegate: AnyObject {
    func updated(_ conversations: [ConversationPreview])
    func dataManagerStatusChanged(_ status: FreeScoutDataManagerStatus)
}

class FreeScoutDataManager {
    weak var delegate: FreeScoutDataManagerDelegate?
    
    var status = FreeScoutDataManagerStatus.needsFolders
    
    private var mailboxes = [Mailbox]()
    
    private var folders = [Folder]() {
        didSet {
            if status == .needsFolders {
                status = .ready
                delegate?.dataManagerStatusChanged(status)
            }
        }
    }
    
    private var conversationsPreviews = [ConversationPreview]()
    
    func getStatus() {
        delegate?.dataManagerStatusChanged(status)
    }
    
    func canFetchConversations() -> Bool {
        guard !folders.isEmpty else { return false }
        
        return true
    }
    
    func set(_ folders: Folders) {
        self.folders = folders.container.folders.sorted(by: { $0.id < $1.id })
    }
    
    func set(_ mailboxes: MailboxContainer) {
        self.mailboxes = mailboxes.embeddedMailboxes.mailboxes
    }
    
    func set(_ conversations: ConversationContainer) {
        self.conversationsPreviews = conversations.embeddedd.conversations
                
        delegate?.updated(conversationsPreviews)
    }
    
    func mainFolders() -> [Folder] {
        return folders.filter { $0.userId == nil }
    }
    
    func userFolders() -> [Folder] {
        return folders.filter { $0.userId != nil }
    }
    
}
