//
//  MenuManager.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/15/24.
//

import AppKit

class MenuManager {
    static let shared = MenuManager()
    
    private let apiService = FreeScoutService.shared
    private let configurator = Configurator.shared
    private var statusItem: NSStatusItem!
    
    private init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(named: "menu-icon")
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
                menuItem.target = self
                menuItem.indentationLevel = 1
                menuItem.badge = NSMenuItemBadge(string: conversation.createdBy.name().truncated(18))
                menuItem.tag = conversation.id
                menuItem.toolTip = conversation.preview
                menuItems.append(menuItem)
            }
        }
        
        updateMenu(with: menuItems)
    }
    
    func updateMenu(with menuItems: [NSMenuItem] = [NSMenuItem]()) {
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
        aboutMenuItem.target = self
        
        menu.addItem(aboutMenuItem)
        
        let configurationMenuItem = NSMenuItem(title: "Preferences",
                                               action: #selector(configurator.showPreferencesWindow),
                                               keyEquivalent: "")
        configurationMenuItem.target = configurator
        
        menu.addItem(configurationMenuItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    private func numberOfConversations(for folder: Folder, conversations: [ConversationPreview]) -> Int {
        var numberOfConversations = 0
        for conversation in conversations {
            if conversation.folderId == folder.id {
                numberOfConversations += 1
            }
        }
        
        return numberOfConversations
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
    
    func displayMessage(_ message: String) {
        statusItem.button?.title = message
    }
}
