//
//  main.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/26/24.
//

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
//app.mainMenu = menu

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
