//
//  AppDelegate.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/26/24.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private let scouter = Scouter.shared
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // nothing
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
