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
