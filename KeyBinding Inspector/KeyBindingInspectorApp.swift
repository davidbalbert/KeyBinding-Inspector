//
//  KeyBindingInspectorApp.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import SwiftUI


//class AppDelegate: NSObject, NSApplicationDelegate {
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        DispatchQueue.main.async {
//            if NSDocumentController.shared.documents.isEmpty {
//                NSDocumentController.shared.openDocument(withContentsOf: systemKeyBindingsURL, display: true) { _, _, _ in }
//            }
//
//        }
//    }
//}

struct KeyBindingInspectorApp: App {
//    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    @Environment(\.openDocument) var openDocument
    @Environment(\.openWindow) var openWindow

//    @FocusedValue(\.searchFieldFocused) var searchFieldFocused: FocusState<Bool>.Binding?
//    @FocusedBinding(\.showingAccessoryBar) var showingAccessoryBar: Bool?

    var body: some Scene {
//        DocumentGroup(viewing: KeyBindingsDocument.self) { configuration in
//            KeyBindingsView(document: configuration.document)
//        }
        Window("Software Update", id: "software-update") {
            Updater(state: UpdaterState())
        }
        .windowResizability(.contentSize)
//        .commands {
//            CommandGroup(after: .appSettings) {
//                Button("Check For Updates") {
//                    openWindow(id: "software-update")
//                }
//            }
//
//            CommandGroup(after: .newItem) {
//                Button("Open System Key Bindings") {
//                    Task {
//                        try await openDocument(at: systemKeyBindingsURL)
//                    }
//                }
//                .keyboardShortcut("o", modifiers: [.command, .option])
//
//                Button("Open User Key Bindings") {
//                     Task {
//                         try await openDocument(at: userKeyBindingsURL!)
//                     }
//                }
//                .keyboardShortcut("o", modifiers: [.command, .shift, .option])
//                .disabled(!userKeyBindingsExists)
//            }
//
//            CommandGroup(after: .textEditing) {
//                Button("Find") {
//                    showingAccessoryBar = true
//                    searchFieldFocused?.wrappedValue = true
//                }
//                .disabled(showingAccessoryBar == nil)
//                .keyboardShortcut("f")
//            }
//        }
    }
}
