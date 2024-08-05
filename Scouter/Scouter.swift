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
    func updateMenu(folders: [Folder], conversations: [ConversationPreview])
    func showConfigurationWindow(_ reason: ConfigurationIssue)
}

class Scouter {
    static let shared = Scouter()
    
    let configurator = Configurator.shared
    let networking = Networking.shared
    var cachedConversationID: Int? // This should be saved
    var timer: Timer?
    weak var delegate: ScouterDelegate?
    
    let dataManager = FreeScoutDataManager()
    
    var configuration: Configuration?
    
    private init() {
        guard let configuration = configurator.getConfiguration() else {
            delegate?.showConfigurationWindow(.noConfiguration)
            return
        }
        
        self.configuration = configuration
        
        start()
    }
    
    private func start() {
        guard configuration != nil else {
            delegate?.showConfigurationWindow(.noConfiguration)
            return
        }
        
        configurator.delegate = self
        dataManager.delegate = self
        dataManager.getStatus()
    }
    
    func restart() {
        guard let configuration = configurator.getConfiguration() else {
            delegate?.showConfigurationWindow(.noConfiguration)
            return
        }
        
        self.configuration = configuration
        fetch(interval: configuration.fetchInterval)
    }
    
    private func beginTimer() {
        guard let config = configuration else {
            delegate?.showConfigurationWindow(.noConfiguration)
            return
        }
        
        fetch(interval: config.fetchInterval)
    }
    
    private func fetch(interval: FetchInterval) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: interval.rawValue, target: self, selector: #selector(self.fetchData), userInfo: nil, repeats: true)
            self.timer?.fire()
        }
    }
    
    @objc private func fetchData() {
        fetchFolders()
        fetchConversations()
    }
    
    private func fetchConversations() {
        guard let config = configuration else {
            // here we need to create a state where we call the window, but only make it shown...
            return
        }
        
        var components = URLComponents(url: config.secret.url, resolvingAgainstBaseURL: false)!
        components.path += Endpoint.conversations.path
        components.query = "pageSize=200"
        
        guard let url = components.url else {
            // call that same configurator window to redo the configuration
            return
        }
        
        dataManager.fetchConversations(configuration: config, url: url)
    }
    
    private func fetchFolders() {
        guard let config = configuration else {
            delegate?.showConfigurationWindow(.noConfiguration)
            return
        }
        
        let url = URL(string: Endpoint.folders(config.mailboxID).path, relativeTo: config.secret.url)
        guard let fetchURL = url?.absoluteURL else { return }

        Task {
            do {
                let data = try await networking.fetch(url: fetchURL, APIKey: config.secret.key)
                
                print("Folders recieved")
                
                guard
                    let folders = try? JSONDecoder().decode(Folders.self, from: data)
                else { throw NetworkingError.unableToDecode }
                
                dataManager.set(folders)
                
                await parse(folders)
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.delegate?.showConfigurationWindow(.invalidConfigruation)
                }
            }
        }
    }
    
    @MainActor private func parse(_ folders: Folders) {
        for (_, folder) in folders.container.folders.enumerated()
            where folder.name == "Unassigned" {
            delegate?.active(tickets: folder.activeCount)
        }
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
            // Somehow the latest conversation ID is lesser than our cached one, set cache to the latest
            cachedConversationID = conversationID
            return
        }
        
        // The latest ID is greater than our cache, update our cache and alert the user of the new conversation
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
        guard let config = configuration else { return nil }
                
        var components = URLComponents(url: config.secret.url, resolvingAgainstBaseURL: false)!
        components.path += "/conversation/\(conversation)"
        
        return components.url
    }
}

extension Scouter: FreeScoutDataManagerDelegate {
    func updated(_ conversations: [ConversationPreview]) {
        checkForNew(conversations)
        
        var filteredConversations = [ConversationPreview]()

        for folder in dataManager.mainFolders() {
            let filtered = conversations.filter { $0.folderId == folder.id }
            
            for conversation in filtered {
                let index = filtered.firstIndex { $0.id == conversation.id }
                if index == 5 { break }
                
                filteredConversations.append(conversation)
            }
        }
        
        DispatchQueue.main.async {
            self.delegate?.updateMenu(folders: self.dataManager.mainFolders(), conversations: filteredConversations)
        }
    }
    
    func dataManagerStatusChanged(_ status: FreeScoutDataManagerStatus) {
        switch status {
        case .needsFolders: fetchFolders()
        case .ready: beginTimer()
        }
    }
}

extension Scouter: ConfiguratorDelegate {
    func configurationChanged() {
        timer?.invalidate()
        restart()
    }
}
