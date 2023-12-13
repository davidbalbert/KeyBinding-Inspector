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
    .deleteForward: "Delete Forward",
    .home: "Home",
    .begin: "Begin",
    .end: "End",
    .pageUp: "Page Up",
    .pageDown: "Page Down",
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
    .enter: "Enter",
    .backspace: "Backspace",
    .tab: "Tab",
    .newline: "Newline",
    .formFeed: "Form Feed",
    .carriageReturn: "Carriage Return",
    .backTab: "Back Tab",
    .delete: "Delete",
    .lineSeparator: "Line Separator",
    .paragraphSeparator: "Paragraph Separator",
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
    0x08: "Backspace",
    0x09: "Tab",
    0x0a: "Newline",
    0x0b: "Vt",
    0x0c: "Ff",
    0x0d: "Carriage Return",
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
    0x7f: "Delete",
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

struct KeyBinding: Identifiable, Equatable {
    var key: String
    var actions: [String]

    var id: String { key }

    var formattedActions: String {
        actions.joined(separator: ", ")
    }

    var modifiers: String {
        if key.isEmpty || key.count == 1 {
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

    var keyWithoutModifiers: String {
        if key.isEmpty {
            return ""
        }

        if let name = specialKeys[NSEvent.SpecialKey(rawValue: Int(key.unicodeScalars.last!.value))] {
            return name
        } else if let match = key.firstMatch(of: /\\(\d+)/) {
            // parse octal digit
            let octal = match.1
            let value = Int(octal, radix: 8)!
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

    var escapedRawKey: String {
        // print control characters either as ^C, or <CR>
        // print special keys as unicode sequences: e.g. "\u{f700}"

        if key.isEmpty {
            return "\"\""
        }

        var s = String(key.dropLast())

        if let match = s.firstMatch(of: /\\\d+/) {
            s += match.0
            return s
        }

        let scalar = key.unicodeScalars.last!.value

        if scalar >= 0xf700 && scalar <= 0xf8ff {
            s += "\\u{\(String(format: "%x", scalar))}"
        } else if let cc = escapedControlCharacters[Int(scalar)] {
            s += cc
        } else if key.last == "\"" {
            s += "\\\""
        } else {
            s += String(key.last!)
        }

        return "\"" + s + "\""
    }
}

