//
//  KeyBindingInspectorApp.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let keyBindings = UTType(exportedAs: "is.dave.keybinding-inspector.key-bindings")
}

struct KeyBindingsDocument: FileDocument {
    var keyBindings: [KeyBinding]

    enum Errors: Error {
        case readError
        case parseError
        case invalidBindings
        case missingAction
    }

    static var readableContentTypes: [UTType] = [.keyBindings]

    init() {
        self.keyBindings = []
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        guard let dict = plist as? [String: Any] else {
            throw CocoaError(.fileReadCorruptFile)
        }

        self.keyBindings = dict.map { (key, value) in
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
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let seq = try keyBindings.map { b in
            let value: Any
            if b.actions.isEmpty {
                throw Errors.missingAction
            } else if b.actions.count == 1 {
                value = b.actions[0]
            } else {
                value = b.actions
            }

            return (b.key, value)
        }

        let plist = Dictionary(seq) { a, b in b }
        return FileWrapper(regularFileWithContents: try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0))
    }
}

@main
struct KeyBindingInspectorApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: KeyBindingsDocument()) { configuration in
            KeyBindingsView(document: configuration.$document)
        }
    }
}
