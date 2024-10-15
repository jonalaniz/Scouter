//
//  AppDelegate.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/26/24.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private let scouter = Scouter.shared
    private let notificationCenter = NSWorkspace.shared.notificationCenter

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        notificationCenter.addObserver(self,
                               selector: #selector(handleSystemSleep),
                               name: NSWorkspace.willSleepNotification,
                               object: nil)
        notificationCenter.addObserver(self,
                               selector: #selector(handleSystemWake),
                               name: NSWorkspace.didWakeNotification,
                               object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        notificationCenter.removeObserver(self)
        scouter.timer?.invalidate()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @objc private func handleSystemSleep(notification: Notification) {
        scouter.timer?.invalidate()
    }

    @objc private func handleSystemWake(notification: Notification) {
        scouter.restart()
    }
}
