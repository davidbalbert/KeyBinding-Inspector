//
//  KeyBinding.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import Cocoa

let specialKeys: [NSEvent.SpecialKey: String] = [
    .upArrow: "Up Arrow",
    .downArrow: "Down Arrow",
    .leftArrow: "Left Arrow",
    .rightArrow: "Right Arrow",
    .f1: "F1",
    .f2: "F2",
    .f3: "F3",
    .f4: "F4",
    .f5: "F5",
    .f6: "F6",
    .f7: "F7",
    .f8: "F8",
    .f9: "F9",
    .f10: "F10",
    .f11: "F11",
    .f12: "F12",
    .f13: "F13",
    .f14: "F14",
    .f15: "F15",
    .f16: "F16",
    .f17: "F17",
    .f18: "F18",
    .f19: "F19",
    .f20: "F20",
    .f21: "F21",
    .f22: "F22",
    .f23: "F23",
    .f24: "F24",
    .f25: "F25",
    .f26: "F26",
    .f27: "F27",
    .f28: "F28",
    .f29: "F29",
    .f30: "F30",
    .f31: "F31",
    .f32: "F32",
    .f33: "F33",
    .f34: "F34",
    .f35: "F35",
    .insert: "Insert",
    .deleteForward: "⌦ (Fn-Delete)",
    .home: "Home (Fn-Left Arrow)",
    .begin: "Begin",
    .end: "End (Fn-Right Arrow)",
    .pageUp: "Page Up (Fn-Up Arrow)",
    .pageDown: "Page Down (Fn-Down Arrow)",
    .printScreen: "Print Screen",
    .scrollLock: "Scroll Lock",
    .pause: "Pause",
    .sysReq: "Sys Req",
    .`break`: "Break",
    .reset: "Reset",
    .stop: "Stop",
    .menu: "Menu",
    .user: "User",
    .system: "System",
    .print: "Print",
    .clearLine: "Clear Line",
    .clearDisplay: "Clear Display",
    .insertLine: "Insert Line",
    .deleteLine: "Delete Line",
    .insertCharacter: "Insert Character",
    .deleteCharacter: "Delete Character",
    .prev: "Prev",
    .next: "Next",
    .select: "Select",
    .execute: "Execute",
    .undo: "Undo",
    .redo: "Redo",
    .find: "Find",
    .help: "Help",
    .modeSwitch: "Mode Switch",
]

let controlCharacters: [Int: String] = [
    0x00: "Nul",
    0x01: "Soh",
    0x02: "Stx",
    0x03: "Etx",
    0x04: "Eot",
    0x05: "Enq",
    0x06: "Ack",
    0x07: "Bel",
    0x08: "⌫",
    0x09: "Tab",
    0x0a: "Return",
    0x0b: "Vt",
    0x0c: "Ff",
    0x0d: "Return",
    0x0e: "So",
    0x0f: "Si",
    0x10: "Dle",
    0x11: "Dc1",
    0x12: "Dc2",
    0x13: "Dc3",
    0x14: "Dc4",
    0x15: "Nak",
    0x16: "Syn",
    0x17: "Etb",
    0x18: "Can",
    0x19: "Em",
    0x1a: "Sub",
    0x1b: "Esc",
    0x1c: "Fs",
    0x1d: "Gs",
    0x1e: "Rs",
    0x1f: "Us",
    0x20: "Space",
    0x7f: "⌫",
]

let escapedControlCharacters: [Int: String] = [
    0x00: "<NUL>",
    0x01: "<SOH>",
    0x02: "<STX>",
    0x03: "^C",
    0x04: "<EOT>",
    0x05: "<ENQ>",
    0x06: "<ACK>",
    0x07: "<BEL>",
    0x08: "\\b",
    0x09: "\\t",
    0x0a: "\\n",
    0x0b: "\\v",
    0x0c: "\\f",
    0x0d: "\\r",
    0x0e: "<SO>",
    0x0f: "<SI>",
    0x10: "<DLE>",
    0x11: "<DC1>",
    0x12: "<DC2>",
    0x13: "<DC3>",
    0x14: "<DC4>",
    0x15: "<NAK>",
    0x16: "<SYN>",
    0x17: "<ETB>",
    0x18: "<CAN>",
    0x19: "<EM>",
    0x1a: "<SUB>",
    0x1b: "<ESC>",
    0x1c: "<FS>",
    0x1d: "<GS>",
    0x1e: "<RS>",
    0x1f: "<US>",
    0x20: " ",
    0x7f: "<DEL>",
]

fileprivate func modifierCount(_ key: String) -> Int {
    key.filter { "^~$@".contains($0) }.count
}

fileprivate func parseModifiers(_ key: String) -> String {
    if key.isEmpty {
        return ""
    }

    // "Text System Defaults and Key Bindings" says "One or more key modifiers, which
    // must precede one of the other key-identifier elements."
    //
    // But StandardKeyBinding.dict includes "^" and "@" bound to noop:, both which are
    // modifiers and don't precede anything.
    //
    // I'm not sure what this means, but I'm treating them as if they have no modifiers
    // and I highlight them in red to show that I'm confused.
    //
    // Ref: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/TextDefaultsBindings/TextDefaultsBindings.html
    if modifierCount(key) == key.count {
        return ""
    }

    var s = ""

    if key.contains("^") {
        s += "⌃"
    }
    if key.contains("~") {
        s += "⌥"
    }
    if key.contains("$") || key.last!.isUppercase {
        s += "⇧"
    }
    if key.contains("@") {
        s += "⌘"
    }

    return s
}

fileprivate func parseKeyWithoutModifiers(_ key: String) -> String {
    if key.isEmpty {
        return ""
    }

    if let name = specialKeys[NSEvent.SpecialKey(rawValue: Int(key.unicodeScalars.last!.value))] {
        return name
    } else if let match = key.firstMatch(of: /\\(\d+)/) {
        // parse octal digit
        let octal = match.1
        guard let value = Int(octal, radix: 8) else {
            return "\\(octal)"
        }
        let scalar = Unicode.Scalar(value)!

        assert(scalar.isASCII)

        if let name = scalar.properties.name, name != "" {
            return name
        }

        return controlCharacters[value] ?? "\\(octal)"
    } else if key.contains("#") {
        return "Num \(key.last!.uppercased())"
    } else {
        return controlCharacters[Int(key.unicodeScalars.last!.value)] ?? key.last!.uppercased()
    }
}

fileprivate func parseRawKey(_ key: String) -> String {
    if key.isEmpty {
        return "\"\""
    }

    let scalar = key.unicodeScalars.last!.value

    let s: String
    if let match = key.dropLast().firstMatch(of: /\\\d+/) {
        s = String(match.0)
    } else if scalar >= 0xf700 && scalar <= 0xf8ff {
        s = "\\u{\(String(format: "%x", scalar))}"
    } else if let cc = escapedControlCharacters[Int(scalar)] {
        s = cc
    } else if key.last == "\"" {
        s = "\\\""
    } else {
        s = String(key.last!)
    }

    return "\"" + key.dropLast() + s + "\""
}

fileprivate func parseAttributedRawKey(_ key: String) -> AttributedString {
    if key.isEmpty {
        var attrStr = AttributedString("\"\"")
        attrStr.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        return attrStr
    }

    let scalar = key.unicodeScalars.last!.value

    let s: String
    if let match = key.dropLast().firstMatch(of: /\\\d+/) {
        s = String(match.0)
    } else if scalar >= 0xf700 && scalar <= 0xf8ff {
        s = "\\u{\(String(format: "%x", scalar))}"
    } else if let cc = escapedControlCharacters[Int(scalar)] {
        s = cc
    } else if key.last == "\"" {
        s = "\\\""
    } else {
        var k = AttributedString(key)
        if modifierCount(key) == key.count {
            k.backgroundColor = .systemRed.withSystemEffect(.disabled)
        }

        let q = AttributedString("\"")
        var attrStr = q + k + q
        attrStr.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        return attrStr
    }

    var special = AttributedString(s)
    if s != " " {
        special.backgroundColor = .quaternaryLabelColor
    }

    let prefix = AttributedString("\"" + key.dropLast())
    let suffix = AttributedString("\"")
    var attrStr = prefix + special + suffix
    attrStr.font = .monospacedSystemFont(ofSize: 12, weight: .regular)

    return attrStr
}

struct KeyBinding {
    let key: String
    let actions: [String]
    let modifiers: String
    let keyWithoutModifiers: String
    let rawKey: String
    let attributedRawKey: AttributedString
    let formattedActions: String

    init(key: String, actions: [String]) {
        self.key = key
        self.actions = actions
        self.modifiers = parseModifiers(key)
        self.keyWithoutModifiers = parseKeyWithoutModifiers(key)
        self.rawKey = parseRawKey(key)
        self.attributedRawKey = parseAttributedRawKey(key)
        self.formattedActions = actions.joined(separator: ", ")
    }
}

extension KeyBinding: Identifiable {
    var id: String { key }
}

extension KeyBinding: Equatable {
    static func == (lhs: KeyBinding, rhs: KeyBinding) -> Bool {
        return lhs.key == rhs.key
    }
}

extension Array<KeyBinding> {
    init(contentsOf data: Data) throws {
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        guard let dict = plist as? [String: Any] else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let keyBindings = dict.map { (key, value) in
            let actions: [String]
            if let s = value as? String {
                actions = [s]
            } else if let a = value as? [String] {
                actions = a
            } else {
                actions = []
            }
            return KeyBinding(key: key, actions: actions)
        }

        self.init(keyBindings)
    }
}

