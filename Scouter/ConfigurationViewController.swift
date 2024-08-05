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
    
    let networking = Networking.shared
    let configurator = Configurator.shared
    var url: URL?
    var apiKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")
        guard configurator.getConfiguration() != nil else {
            configureFetchIntervalButton()
            return
        }
        
        showConfiguration()
    }
    
    @IBAction func getMailboxesPressed(_ sender: Any) {
        print("Get mailboxes pressed")
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
    
    @IBAction func save(_ sender: Any) {
        guard let fetchInterval = FetchInterval(rawValue: TimeInterval(fetchIntervalPopupButton.selectedTag())) else { return }
        guard let id = mailboxesPopUpButton.selectedItem?.tag else { return }
        
        let configuration = Configuration(secret: Secret(url: url!, key: apiKey!),
                                          fetchInterval: fetchInterval,
                                          mailboxID: id)
        
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
        let mailboxURL = URL(string: Endpoint.mailbox.path, relativeTo: url)
        guard let fetchURL = mailboxURL else { return }
        
        Task {
            do {
                let data = try await networking.fetch(url: fetchURL, APIKey: apiKey)
                                
                guard
                    let mailboxes = try? JSONDecoder().decode(MailboxContainer.self, from: data)
                else { throw NetworkingError.unableToDecode }
                
                self.url = url
                self.apiKey = apiKey
                                
                configureMailboxesPopupButton(boxes: mailboxes.embeddedMailboxes.mailboxes)
            } catch {
                guard let error = error as? NetworkingError else {
                    errorLabel.stringValue = error.localizedDescription
                    errorLabel.isHidden = false
                    return
                }
                self.handle(error: error)
                
            }
        }
    }
    
    private func configureMailboxesPopupButton(boxes: [Mailbox]) {
        for box in boxes {
            mailboxesPopUpButton.addItem(withTitle: box.name)
            mailboxesPopUpButton.itemArray.last!.tag = box.id
        }
        
        guard let selected = configurator.getConfiguration()?.mailboxID else { return }
        
        mailboxesPopUpButton.selectItem(withTag: selected)
        mailboxesPopUpButton.isEnabled = true
    }
    
    private func handle(error: NetworkingError) {
        switch error {
        case .invalidURL: errorLabel.stringValue = "Invalid URL"
        case .noData: errorLabel.stringValue = "No Data"
        case .unableToDecode: errorLabel.stringValue = "Unable to Decode"
        case .invalidResponse: errorLabel.stringValue = "Invalid Response"
        case .requestFailed:  errorLabel.stringValue = "Request Failed"
        case .unauthorized: errorLabel.stringValue = "Unauthorized"
        }
        
        errorLabel.isHidden = false
    }
}
