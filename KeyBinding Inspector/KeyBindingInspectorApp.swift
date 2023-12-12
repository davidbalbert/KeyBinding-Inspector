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

    var userKeyBindingsURL: URL? {
        guard let passInfo = getpwuid(getuid()) else {
            return nil
        }
        let homeDir = String(cString: passInfo.pointee.pw_dir)
        return URL(fileURLWithPath: homeDir + "/Library/KeyBindings/DefaultKeyBinding.dict")
    }

    var userKeyBindingsExists: Bool {
        guard let path = userKeyBindingsURL else {
            return false
        }
        return FileManager.default.fileExists(atPath: path.path)
    }

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

                Button("Open User Key Bindings") {
                     Task {
                         try await openDocument(at: userKeyBindingsURL!)
                     }
                }
                .disabled(!userKeyBindingsExists)
            }
        }
    }
}
