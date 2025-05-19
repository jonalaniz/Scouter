//
//  MenuManager.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/15/24.
//

import AppKit
import Sparkle

class MenuManager {
    static let shared = MenuManager()
    private let updaterController: SPUStandardUpdaterController

    private let apiService = FreeScoutService.shared
    private let configurator = Configurator.shared
    private var statusItem: NSStatusItem!

    private init() {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        statusItem.button?.image = NSImage(named: "menu-icon")
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil)
    }

    func buildMenuFrom(folders: [Folder],
                       conversations: [ConversationPreview]) {
        var menuItems = [NSMenuItem]()
        var filteredFolders: [Folder]

        let ignoredFolders = configurator.getConfiguration()?.ignoredFolders ?? []
        filteredFolders = folders.filter { !ignoredFolders.contains($0.name) }

        for folder in filteredFolders {
            // Check folder for conversations
            guard has(conversations, in: folder) else { continue }

            // Create our section header
            menuItems.append(NSMenuItem.sectionHeader(title: folder.name))

            // Filter out the conversations by folder ID
            let folderConversations = conversations.filter { $0.folderId == folder.id }

            if folderConversations.count <= 5 {
                // Add all conversations as menu items if less than 5
                menuItems.append(contentsOf: buildMenuitems(from: folderConversations))
            } else {
                // Add first 5 convserations as menu items
                let firstFive = Array(folderConversations.prefix(5))
                menuItems.append(contentsOf: buildMenuitems(from: firstFive))

                // Add remaining conversations in a sumbenu
                let remaining = Array(folderConversations.dropFirst(5))
                menuItems.append(buildSubmenu(from: remaining))
            }
        }

        updateMenu(with: menuItems)
    }

    private func buildSubmenu(from conversations: [ConversationPreview]) -> NSMenuItem {
        let submenuItem = NSMenuItem(title: "More",
                                     action: nil,
                                     keyEquivalent: "")
        submenuItem.indentationLevel = 1
        let submenu = NSMenu()

        conversations.forEach {
            submenu.addItem(createConversationMenuItem(for: $0))
        }

        submenuItem.submenu = submenu

        return submenuItem
    }

    private func buildMenuitems(from conversations: [ConversationPreview]) -> [NSMenuItem] {
        return conversations.map { createConversationMenuItem(for: $0) }
    }

    private func createConversationMenuItem(for conversation: ConversationPreview) -> NSMenuItem {
        let menuItem = NSMenuItem(
            title: conversation.subject.truncated(25),
            action: #selector(openConversation),
            keyEquivalent: ""
        )
        menuItem.target = self
        menuItem.indentationLevel = 1
        if conversation.createdBy != nil {
            menuItem.badge = NSMenuItemBadge(string: conversation.createdBy!.name().truncated(18))
        }
        menuItem.tag = conversation.id
        menuItem.toolTip = toolTipFor(conversation)

        return menuItem
    }

    // Updates the menu with the menuItems that were created
    func updateMenu(with menuItems: [NSMenuItem] = [NSMenuItem]()) {
        let menu = NSMenu()
        menu.autoenablesItems = false

        if !menuItems.isEmpty {
            menuItems.forEach { menu.addItem($0) }
        }

        menu.addItem(NSMenuItem.separator())

        addStaticMenuItems(to: menu)

        statusItem.menu = menu
    }

    private func has(_ conversations: [ConversationPreview], in folder: Folder) -> Bool {
        conversations.contains { $0.folderId == folder.id }
    }

    private func addStaticMenuItems(to menu: NSMenu) {
        let checkForUpdatesMenuItem = NSMenuItem(
            title: "Check for Updates",
            action: #selector(SPUStandardUpdaterController.checkForUpdates(_:)),
            keyEquivalent: "")
        checkForUpdatesMenuItem.target = updaterController
        menu.addItem(checkForUpdatesMenuItem)

        let configurationMenuItem = NSMenuItem(
            title: "Preferences",
            action: #selector(configurator.showPreferencesWindow),
            keyEquivalent: ""
        )
        configurationMenuItem.target = configurator
        menu.addItem(configurationMenuItem)

        menu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(NSApplication.terminate(_:)),
                keyEquivalent: "q"
            )
        )
    }

    private func toolTipFor(_ conversation: ConversationPreview) -> String {
        let toolTip = "\(conversation.preview)\n- \(conversation.customerWaitingSince.friendly)"

        guard let assignee = conversation.assignee else { return toolTip }

        return toolTip + " | Assigned to \(assignee.name())"
    }

    @objc func openConversation(sender: NSMenuItem) {
        guard let url = apiService.urlFor(sender.tag) else { return }

        NSWorkspace.shared.open(url)
    }

    func displayMessage(_ message: String) {
        statusItem.button?.title = message.truncated(25)
    }
}
