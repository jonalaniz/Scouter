//
//  Scouter.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import AppKit

class Scouter {
    static let shared = Scouter()
    
    var cachedConversationID: Int?
    var timer: Timer?
    
    let apiService = FreeScoutService.shared
    let menuManager = MenuManager.shared
    let configurator = Configurator.shared
        
    private init() { start() }
    
    private func start() {
        configurator.delegate = self
        
        guard
            apiService.isConfigured(),
            let interval = apiService.timeInterval()
        else {
            menuManager.updateMenu()
            configurator.showPreferencesWindow()
            return
        }

        menuManager.updateMenu()
        setFetchTimer(at: interval)
    }
    
    private func setFetchTimer(at interval: FetchInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval.rawValue,
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
                    await errorHandler(error)
                    return
                }

                await errorHandler(apiError)
            }
        }
    }
    
    func restart() {
        guard let interval = apiService.timeInterval() else {
            configurator.showPreferencesWindow()
            return
        }
        
        setFetchTimer(at: interval)
    }
    
    @MainActor private func parseForActiveTickets(_ folders: Folders) {
        for (_, folder) in folders.container.folders.enumerated()
            where folder.name == "Unassigned" {
            menuManager.displayMessage(" \(folder.activeCount)")
        }
    }
    
    @MainActor private func filterAndUpdate(folders: [Folder],
                                            conversations: [ConversationPreview]) {
        var filteredConversations = [ConversationPreview]()
        
        for folder in folders {
            let filtered = conversations.filter { $0.folderId == folder.id }
            filtered.forEach { filteredConversations.append($0) }
        }
        
        menuManager.buildMenuFrom(folders: apiService.mainFolders(), conversations: filteredConversations)
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
        alert?.volume = 0.5
        
        
        alert?.play()
    }
    
    @MainActor private func displayMessage(_ message: String) {
        menuManager.displayMessage(message)
    }
    
    private func errorHandler(_ error: Error) async {
        guard let error = error as? URLError else {
            return
        }
        
        switch error.code {
        case .notConnectedToInternet: await displayMessage("Offline")
        default: await displayMessage(error.localizedDescription)
        }
    }
    
    private func errorHandler(_ error: APIManagerError) async {
        switch error {
        case .configurationMissing:
            configurator.showPreferencesWindow()
        case .conversionFailedToHTTPURLResponse:
            await displayMessage("No Response")
        case .invalidResponse(let statuscode):
            await displayMessage("Error: \(statuscode)")
        case .invalidURL:
            await displayMessage("Invalid URL")
            configurator.showPreferencesWindow()
        case .serializaitonFailed:
            await displayMessage("Serialization Failed")
        case .somethingWentWrong(let error):
            await displayMessage("Error")
            print("Error: \(error?.localizedDescription ?? "Unknown")")
        }
    }
}
