//
//  Configurator.swift
//  Scouter
//
//  Created by Jon Alaniz on 7/28/24.
//

import AppKit

protocol ConfiguratorDelegate: AnyObject {
    func configurationChanged()
}

class Configurator {
    static let shared = Configurator()
    
    weak var delegate: ConfiguratorDelegate?
        
    private let windowController = NSWindowController(windowNibName: "ConfigurationWindow")
    private var configuration: Configuration?
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        guard
            let data = UserDefaults.standard.data(forKey: "configuration"),
            let configuration = try? PropertyListDecoder().decode(Configuration.self, from: data)
        else  { return }
                
        self.configuration = configuration
    }
    
    private func saveConfiguration() {
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(configuration), forKey: "configuration")
        } catch {
            fatalError("Could not encode configuration")
        }
    }
    
    @objc func showPreferencesWindow() {
        windowController.showWindow(nil)
    }
    
    func getConfiguration() -> Configuration? {
        return configuration
    }
    
    func saveConfiguration(_ configuration: Configuration) {
        self.configuration = configuration
        saveConfiguration()
        delegate?.configurationChanged()
    }
}
