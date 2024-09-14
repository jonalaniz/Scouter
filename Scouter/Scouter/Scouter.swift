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
    let windowController = NSWindowController(windowNibName: "ConfigurationWindow")
    
    private var statusItem: NSStatusItem!
        
    private init() { start() }
    
    private func start() {
        guard
            apiService.isConfigured(),
            let interval = apiService.timeInterval()
        else {
            errorHandler(.configurationMissing)
            return
        }
        
        initializeMenu()
        
        updateMenu()
        setFetchTimer(at: interval)
    }
    
    private func initializeMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "Scouter"
            button.image = NSImage(named: "menu-icon")
        }
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
                    errorHandler(error)
                    return
                }
                
                print("APIERROR:")
                print(apiError.errorDescription)
            }
        }
    }
    
    func restart() {
        guard let interval = apiService.timeInterval() else {
            showPreferencesWindow()
            return
        }
        
        setFetchTimer(at: interval)
    }
    
    @MainActor private func parseForActiveTickets(_ folders: Folders) {
        for (_, folder) in folders.container.folders.enumerated()
            where folder.name == "Unassigned" {
            active(tickets: folder.activeCount)
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
        
        updateMenu(folders: apiService.mainFolders(), conversations: filteredConversations)
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
    
    private func errorHandler(_ error: Error) {
        guard let error = error as? URLError else {
            print("Not URLError")
            return
        }
        
        switch error.code {
        case .notConnectedToInternet: displayMessage("Offline")
        default: displayMessage(error.localizedDescription)
        }
    }
    
    private func errorHandler(_ error: APIManagerError) {
        // TODO: Handle errors and show configuration window
        // TODO: Have a way for the menu handler to show a status message
        switch error {
            // MARK: ShowConfigurationWindow
        case .configurationMissing:
            openPreferences()
        case .conversionFailedToHTTPURLResponse:
            print("Failed to respond")
        case .invalidResponse(let statuscode):
            print(statuscode)
        case .invalidURL: return
        case .serializaitonFailed: return
        case .somethingWentWrong(let error): return
        }
        print("ERROR:")
    }
}

// MARK: - Menu Functions
extension Scouter {
    private func showPreferencesWindow() {
        windowController.showWindow(nil)
    }
    
    func updateMenu(with menuItems: [NSMenuItem] = [NSMenuItem]()) {
        print("setting Up Menus")
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        if !menuItems.isEmpty {
            for item in menuItems {
                menu.addItem(item)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let aboutMenuItem = NSMenuItem(title: "About",
                                       action: #selector(about),
                                       keyEquivalent: "")
        menu.addItem(aboutMenuItem)
        
        let configurationMenuItem = NSMenuItem(title: "Preferences",
                                               action: #selector(openPreferences),
                                               keyEquivalent: "")
        menu.addItem(configurationMenuItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func about(sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel()
    }
    
    @objc func openConversation(sender: NSMenuItem) {
        guard let url = apiService.urlFor(sender.tag) else { return }
        
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
    
    @objc func openPreferences() {
        print("opened pressed")
        showPreferencesWindow()
    }
    
    func active(tickets: Int) {
        statusItem.button?.imageHugsTitle = true
        statusItem.button?.title = " \(tickets)"
    }
    
    func displayMessage(_ message: String) {
        statusItem.button?.title = message
    }
    
    func updateMenu(folders: [Folder], conversations: [ConversationPreview]) {
        var menuItems = [NSMenuItem]()
        
        for folder in folders {
            if numberOfConversations(for: folder, conversations: conversations) == 0 {
                continue
            }
            
            let header = NSMenuItem.sectionHeader(title: folder.name)
            menuItems.append(header)
            
            let filtered = conversations.filter { $0.folderId == folder.id }
            
            for conversation in filtered {
                let menuItem = NSMenuItem(title: conversation.subject.truncated(25),
                                          action: #selector(openConversation),
                                          keyEquivalent: "")
                menuItem.indentationLevel = 1
                menuItem.badge = NSMenuItemBadge(string: conversation.createdBy.name().truncated(18))
                menuItem.tag = conversation.id
                menuItem.toolTip = conversation.preview
                menuItems.append(menuItem)
            }
        }
        
        updateMenu(with: menuItems)
    }
    
    func numberOfConversations(for folder: Folder, conversations: [ConversationPreview]) -> Int {
        var numberOfConversations = 0
        for conversation in conversations {
            if conversation.folderId == folder.id {
                numberOfConversations += 1
            }
        }
        
        return numberOfConversations
    }
}
