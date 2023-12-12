//
//  KeyBindingInspectorApp.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct KeyBindingInspectorApp: App {
    @Environment(\.openDocument) var openDocument

    var body: some Scene {
        DocumentGroup(viewing: KeyBindingsDocument.self) { configuration in
            KeyBindingsView(document: configuration.document)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open System Key Bindings") {
                    let url = URL(fileURLWithPath: "/System/Library/Frameworks/AppKit.framework/Resources/StandardKeyBinding.dict")
                    Task {
                        try await openDocument(at: url)
                    }
                }
            }
        }
    }
}
