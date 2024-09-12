//
//  Scouter.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import AppKit

enum ConfigurationIssue {
    case invalidConfigruation
    case noConfiguration
}

protocol ScouterDelegate: AnyObject {
    func active(tickets: Int)
    func offline()
    func showConfigurationWindow(_ reason: ConfigurationIssue)
    func updateMenu(folders: [Folder], conversations: [ConversationPreview])
}

class Scouter {
    static let shared = Scouter()
    
    var cachedConversationID: Int?
    var timer: Timer?
    weak var delegate: ScouterDelegate?
    
    let apiService = FreeScoutService.shared
        
    private init() { start() }
    
    private func start() {
        guard
            apiService.isConfigured(),
            let interval = apiService.timeInterval()
        else {
            delegate?.showConfigurationWindow(.noConfiguration)
            return
        }
        
        setFetchTimer(at: interval)
    }
    
    private func setFetchTimer(at interval: FetchInterval) {
        if timer != nil {
            timer?.invalidate()
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: interval.rawValue,
                                          target: self,
                                          selector: #selector(updateConversations),
                                          userInfo: nil,
                                          repeats: true)
        timer?.fire()
    }
    
    @objc private func updateConversations() {
        Task {
            do {
                let folders = try await apiService.fetchFolders()
                await parseForActiveTickets(folders)
                apiService.set(folders)
                
                let container = try await apiService.fetchConversations()
                let conversations = container.container.conversations
                
                checkForNew(conversations)
                await filterAndUpdate(folders: folders.container.folders, conversations: conversations)
            } catch {
                guard let apiError = error as? APIManagerError else {
                    print(error)
                    return
                }
                
                print(apiError.errorDescription)
            }
        }
    }
    
    func restart() {
        guard let interval = apiService.timeInterval() else {
            delegate?.showConfigurationWindow(.invalidConfigruation)
            return
        }
        
        setFetchTimer(at: interval)
    }
    
    @MainActor private func parseForActiveTickets(_ folders: Folders) {
        for (_, folder) in folders.container.folders.enumerated()
            where folder.name == "Unassigned" {
            delegate?.active(tickets: folder.activeCount)
        }
    }
    
    @MainActor private func filterAndUpdate(folders: [Folder],
                                            conversations: [ConversationPreview]) {
        var filteredConversations = [ConversationPreview]()

        for folder in folders {
            let filtered = conversations.filter { $0.folderId == folder.id }
            
            for conversation in filtered {
                let index = filtered.firstIndex { $0.id == conversation.id }
                if index == 5 { break }
                
                filteredConversations.append(conversation)
            }
        }
        
        self.delegate?.updateMenu(folders: apiService.mainFolders(),
                                  conversations: filteredConversations)
    }
    
    private func checkForNew(_ conversations: [ConversationPreview]) {
        // Grab the latest conversation ID
        guard let conversationID = conversations.first?.id else { return }

        // Check if cached ID is not empty
        guard cachedConversationID != nil else {
            // Cache is empty, this is the first fetch. Set our cache to the conversationID
            cachedConversationID = conversationID
            return
        }
        
        guard conversationID > cachedConversationID! else {
            // Latest conversation ID is smaller than cached, set cache to the latest
            cachedConversationID = conversationID
            return
        }
        
        // Latest ID is greater than cached, update cache and alert user of new conversation
        alert()
        cachedConversationID = conversationID
    }
        
    private func alert() {
        guard let url = Bundle.main.url(forResource: "alert", withExtension: "mp3") else {
            fatalError("Sound file missing")
        }
        
        let alert = NSSound(contentsOf: url, byReference: false)
        
        alert?.play()
    }
    
    func urlFor(conversation: Int) -> URL? {
        return apiService.urlFor(conversation)
    }
    
    private func errorHandler() {
        // TODO: Handle errors and show configuration window
    }
}

extension Scouter: ConfiguratorDelegate {
    func configurationChanged() {
        timer?.invalidate()
        restart()
    }
}
