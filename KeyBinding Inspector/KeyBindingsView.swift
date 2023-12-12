//
//  KeyBindingsView.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import SwiftUI

struct KeyBindingsView: View {
    let document: KeyBindingsDocument
    let url: URL?

    @State var sortOrder = [KeyPathComparator(\KeyBinding.keyWithoutModifiers)]
    @State var keyBindings: [KeyBinding] = []
    @State var fileWatcher: FileWatcher? = nil

    func sortKeyBindings() {
        keyBindings = keyBindings.sorted { $0.modifiers.count < $1.modifiers.count }.sorted(using: sortOrder)
    }

    func startWatching() {
        guard let url else {
            return
        }

        let watcher = FileWatcher(url: url) {
            do {
                let data = try await Data(asyncContentsOf: url)
                keyBindings = try KeyBindingsDocument(data: data).keyBindings
                sortKeyBindings()
            } catch {
                print("Failed to reload file", url, error)
            }
        }

        NSFileCoordinator.addFilePresenter(watcher)
        fileWatcher = watcher
    }

    func stopWatching() {
        if let fileWatcher {
            NSFileCoordinator.removeFilePresenter(fileWatcher)
            self.fileWatcher = nil
        }
    }

    var body: some View {
        Table(keyBindings, sortOrder: $sortOrder) {
            TableColumn("Key", value: \.keyWithoutModifiers) { b in
                HStack {
                    HStack {
                        Spacer()
                        Text(b.modifiers)
                    }
                    .frame(width: 50, alignment: .trailing)

                    Text(b.keyWithoutModifiers)
                }
            }
            TableColumn("Action", value: \.formattedActions)
        }
        .onChange(of: sortOrder) {
            sortKeyBindings()
        }
        .onChange(of: document) {
            keyBindings = document.keyBindings
            sortKeyBindings()
        }
        .onAppear {
            keyBindings = document.keyBindings
            sortKeyBindings()
            startWatching()
        }
        .onDisappear(perform: stopWatching)
    }
}

#Preview {
    try! KeyBindingsView(document: KeyBindingsDocument(data: Data(contentsOf: systemKeyBindingsURL)), url: systemKeyBindingsURL)
}
