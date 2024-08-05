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
    
    let networking = Networking.shared
    var status = FreeScoutDataManagerStatus.needsFolders
        
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
    
    func fetchConversations(configuration: Configuration, url: URL) {
        Task {
            do {
                let data = try await networking.fetch(url: url, APIKey: configuration.secret.key)
                print("Conversations recieved")
                
                guard
                    let conversation = try? JSONDecoder().decode(ConversationContainer.self, from: data)
                else { throw NetworkingError.unableToDecode }
                
                set(conversation)
            }
        }
    }
    
    func set(_ folders: Folders) {
        self.folders = folders.container.folders.sorted(by: { $0.id < $1.id })
    }
        
    private func set(_ conversations: ConversationContainer) {
        self.conversationsPreviews = conversations.embeddedd.conversations
                
        delegate?.updated(conversationsPreviews)
    }
    
    func mainFolders() -> [Folder] {
        return folders.filter { $0.userId == nil }
    }
}
