//
//  ConfigurationViewController.swift
//  Scouter
//
//  Created by Jon Alaniz on 7/28/24.
//

import Cocoa

// swiftlint:disable identifier_name
class ConfigurationViewController: NSViewController {
    @IBOutlet var urlField: NSTextField!
    @IBOutlet var apiKeyField: NSSecureTextField!
    @IBOutlet var errorLabel: NSTextField!
    @IBOutlet var mailboxesPopUpButton: NSPopUpButton!
    @IBOutlet var fetchIntervalPopupButton: NSPopUpButton!
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var folderTableView: NSTableView!

    let apiService = FreeScoutService.shared
    let configurator = Configurator.shared
    var url: URL?
    var apiKey: String?
    var ignoredFolders: Set<String> = []
    var folders = [Folder]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showConfiguration()
    }

    private func setupUI() {
        versionLabel.stringValue = appVersion()
        folderTableView.delegate = self
        folderTableView.dataSource = self
        folderTableView.usesAlternatingRowBackgroundColors = true
    }

    private func showConfiguration() {
        // check if there is a configuration saved
        guard let config = configurator.getConfiguration() else { return }

        configureFetchIntervalButton()
        urlField.stringValue = config.secret.url.absoluteString
        apiKeyField.stringValue = (config.secret.key)
        ignoredFolders = config.ignoredFolders
        getMailboxes(url: config.secret.url, apiKey: config.secret.key)
    }

    private func getMailboxes(url: URL, apiKey: String) {
        Task {
            do {
                let mailboxes = try await apiService.fetchMailboxes(key: apiKey, url: url)
                self.url = url
                self.apiKey = apiKey

                configureMailboxesPopupButton(boxes: mailboxes.embeddedMailboxes.mailboxes)
                configureFetchIntervalButton()
            } catch {
                guard let error = error as? APIManagerError else {
                    errorLabel.stringValue = error.localizedDescription
                    errorLabel.isHidden = false
                    return
                }

                self.handle(error: error)
            }
        }
    }

    private func save() {
        let fetchInterval = FetchInterval(
            rawValue: TimeInterval(
                fetchIntervalPopupButton.selectedTag()
            )
        ) ?? FetchInterval.oneMinute

        guard let id = mailboxesPopUpButton.selectedItem?.tag else { return }
        guard let url = url, let apiKey = apiKey
        else { return }

        configurator.updateConriguration(
            url: url,
            key: apiKey,
            fetchInterval: fetchInterval,
            id: id,
            ignoredFolders: ignoredFolders
        )
    }

    @MainActor
    private func configureMailboxesPopupButton(boxes: [Mailbox]) {
        mailboxesPopUpButton.removeAllItems()

        for box in boxes {
            mailboxesPopUpButton.addItem(withTitle: box.name)
            mailboxesPopUpButton.itemArray.last!.tag = box.id
        }

        let selected = configurator.getConfiguration()?.mailboxID ?? boxes[0].id

        mailboxesPopUpButton.selectItem(withTag: selected)
        mailboxesPopUpButton.isEnabled = true

        save()

        configureFolderTableView(with: selected)
    }

    private func configureFetchIntervalButton() {
        for item in FetchInterval.allCases {
            fetchIntervalPopupButton.addItem(withTitle: item.title)
            fetchIntervalPopupButton.itemArray.last!.tag = Int(item.rawValue)
        }

        if let selected = configurator.getConfiguration()?.fetchInterval {
            fetchIntervalPopupButton.selectItem(withTag: Int(selected.rawValue))
        }
    }

    private func configureFolderTableView(with mailbox: Int) {
        Task {
            do {
                let object = try await apiService.fetchFolders()
                folders = object.container.folders.filter { $0.userId == nil }
                reloadTable()
            } catch {
                errorLabel.stringValue = error.localizedDescription
            }
        }
    }

    @IBAction func getMailboxesPressed(_ sender: Any) {
        guard let url = URL(string: urlField.stringValue) else {
            errorLabel.isHidden = false
            errorLabel.stringValue = "Invalid URL"
            return
        }

        guard apiKeyField.stringValue != "" else {
            errorLabel.isHidden = false
            errorLabel.stringValue = "Invalid API key"
            return
        }

        errorLabel.isHidden = true
        getMailboxes(url: url, apiKey: apiKeyField.stringValue)
        ignoredFolders.removeAll()
    }

    @IBAction func selectionMade(_ sender: NSPopUpButton) {
        if sender == mailboxesPopUpButton {
            ignoredFolders.removeAll()
            reloadTable()
        }

        save()
    }

    // MARK: - Helper Functions
    private func handle(error: APIManagerError) {
        // TODO: Handle these errors
        switch error {
        case .somethingWentWrong(let error): // TODO: Change this to pass actual error
            print(error?.localizedDescription ?? "Something went wrong...")
        default:
            print(error.errorDescription)
        }
    }

    private func appVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else { return "Scouter v.Unknown" }
        return "Scouter v.\(version)"
    }

    @objc func boxChecked(_ sender: NSButton) {
        switch sender.state {
        case .on: ignoredFolders.remove(sender.title)
        case .off: ignoredFolders.insert(sender.title)
        default: break
        }
        save()
    }

    @MainActor
    private func reloadTable() {
        folderTableView.reloadData()
    }
}

extension ConfigurationViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return folders.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = NSButton(
            checkboxWithTitle: folders[row].name,
            target: self,
            action: #selector(boxChecked)
        )
        cell.state = ignoredFolders.contains(folders[row].name) ? .off : .on

        return cell
    }
}
