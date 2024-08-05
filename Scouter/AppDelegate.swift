//
//  AppDelegate.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/26/24.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let scouter = Scouter.shared
    let windowController = NSWindowController(windowNibName: "ConfigurationWindow")
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize Status Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.title = "Scouter"
            button.image = NSImage(named: "menu-icon")
        }
        
        // Initialize menu
        setupMenus()
        
        scouter.delegate = self
        }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func setupMenus(with menuItems: [NSMenuItem] = [NSMenuItem]()) {
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
        guard let url = scouter.urlFor(conversation: sender.tag) else { return }
        
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")
        }
    }
    
    @objc func openPreferences() {
        windowController.showWindow(nil)
    }

}

extension AppDelegate: ScouterDelegate {
    func active(tickets: Int) {
        statusItem.button?.imageHugsTitle = true
        statusItem.button?.title = " \(tickets)"
    }
    
    func showConfigurationWindow(_ reason: ConfigurationIssue) {
        windowController.showWindow(nil)
    }
    
    func updateMenu(folders: [Folder], conversations: [ConversationPreview]) {
        var menuItems = [NSMenuItem]()
        
        for folder in folders {
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
                menuItems.append(menuItem)
            }
        }
        
        setupMenus(with: menuItems)
    }
}
