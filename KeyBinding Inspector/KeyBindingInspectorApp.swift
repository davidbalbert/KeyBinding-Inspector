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
    var body: some Scene {
        DocumentGroup(viewing: KeyBindingsDocument.self) { configuration in
            KeyBindingsView(document: configuration.document)
        }
    }
}
