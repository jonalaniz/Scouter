//
//  Configurator.swift
//  Scouter
//
//  Created by Jon Alaniz on 7/28/24.
//

import Foundation

class Configurator {
    static let shared = Configurator()
    
    private let networking = Networking.shared
    
    private var configuration: Configuration?
    
    private init() {
        loadConfiguration()
    }
    
    private func setupConfig() {
        let config = Configuration(secret: Secret(url: URL(string: "https://help.bmhd.org")!,
                                                  key: "a7c3c3aa705384a83d6f56edaef227d7"),
                                   fetchInterval: .oneMinute,
                                   mailboxID: 1)
        do {
            UserDefaults.standard.set(try PropertyListEncoder().encode(config), forKey: "configuration")
        } catch {
            fatalError("Could not encode configuration \(error)")
        }
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
    
    func getConfiguration() -> Configuration? {
        return configuration
    }
    
    func saveConfiguration(_ configuration: Configuration) {
        self.configuration = configuration
        saveConfiguration()
    }
}
