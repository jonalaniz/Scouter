//
//  ConfigurationViewController.swift
//  Scouter
//
//  Created by Jon Alaniz on 7/28/24.
//

import Cocoa

class ConfigurationViewController: NSViewController {
    @IBOutlet var urlField: NSTextField!
    @IBOutlet var apiKeyField: NSSecureTextField!
    @IBOutlet var errorLabel: NSTextField!
    @IBOutlet var mailboxesPopUpButton: NSPopUpButton!
    @IBOutlet var fetchIntervalPopupButton: NSPopUpButton!
    
    let apiService = FreeScoutService.shared
    let configurator = Configurator.shared
    var url: URL?
    var apiKey: String?
    var ignoredFolders: Set<String>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard configurator.getConfiguration() != nil else {
            configureFetchIntervalButton()
            return
        }
        
        showConfiguration()
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
    }

    @IBAction func selectionMade(_ sender: NSPopUpButton) {
        save()
    }
    
    func save() {
        guard let fetchInterval = FetchInterval(rawValue: TimeInterval(fetchIntervalPopupButton.selectedTag())) else { return }
        guard let id = mailboxesPopUpButton.selectedItem?.tag else { return }
        
        let configuration = Configuration(secret: Secret(url: url!, key: apiKey!),
                                          fetchInterval: fetchInterval,
                                          mailboxID: id,
                                          ignoredFolders: ignoredFolders)

        configurator.saveConfiguration(configuration)
    }
    
    private func showConfiguration() {
        guard let config = configurator.getConfiguration() else { return }
        
        urlField.stringValue = config.secret.url.absoluteString
        apiKeyField.stringValue = (config.secret.key)
        
        getMailboxes(url: config.secret.url, apiKey: config.secret.key)
        
        configureFetchIntervalButton()
        fetchIntervalPopupButton.selectItem(withTag: Int(config.fetchInterval.rawValue))
    }
    
    private func configureFetchIntervalButton() {
        for item in FetchInterval.allCases {
            fetchIntervalPopupButton.addItem(withTitle: item.title)
            fetchIntervalPopupButton.itemArray.last!.tag = Int(item.rawValue)
        }
    }
    
    private func getMailboxes(url: URL, apiKey: String) {
        Task {
            do {
                let mailboxes = try await apiService.fetchMailboxes(key: apiKey, url: url)
                self.url = url
                self.apiKey = apiKey

                configureMailboxesPopupButton(boxes: mailboxes.embeddedMailboxes.mailboxes)
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
    
    private func configureMailboxesPopupButton(boxes: [Mailbox]) {
        mailboxesPopUpButton.removeAllItems()

        for box in boxes {
            mailboxesPopUpButton.addItem(withTitle: box.name)
            mailboxesPopUpButton.itemArray.last!.tag = box.id
        }
        
        guard let selected = configurator.getConfiguration()?.mailboxID else { return }
        
        mailboxesPopUpButton.selectItem(withTag: selected)
        mailboxesPopUpButton.isEnabled = true

        save()
    }
    
    private func handle(error: APIManagerError) {
        // TODO: Handle these errors
        switch error {
        case .somethingWentWrong(let error): // TODO: Change this to pass actual error
            print(error?.localizedDescription ?? "Something went wrong...")
        default:
            print(error.errorDescription)
        }
    }
}
