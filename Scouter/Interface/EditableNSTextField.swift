//
//  EditableNSTextField.swift
//  Scouter
//
//  Created by Jon Alaniz on 12/2/24.
//

import AppKit

// swiftlint:disable cyclomatic_complexity
final class EditableNSTextField: NSTextField {
    private let commandKey = NSEvent.ModifierFlags.command.rawValue

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard
            event.type == .keyDown,
            (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey
        else { return super.performKeyEquivalent(with: event) }

        switch event.charactersIgnoringModifiers! {
        case "x": if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
        case "c": if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return true }
        case "v": if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
        case "z": if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
        case "a": if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
        default: break
        }

        return super.performKeyEquivalent(with: event)
    }
}

final class EditableNSSecureTextField: NSSecureTextField {
    private let commandKey = NSEvent.ModifierFlags.command.rawValue

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard
            event.type == .keyDown,
            (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == commandKey
        else { return super.performKeyEquivalent(with: event) }

        switch event.charactersIgnoringModifiers! {
        case "x": if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
        case "v": if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
        case "z": if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
        case "a": if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
        default: break
        }

        return super.performKeyEquivalent(with: event)
    }
}
