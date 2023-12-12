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
    @State var query: String = ""

    func sortKeyBindings() {
        keyBindings = keyBindings.sorted { $0.modifiers.count < $1.modifiers.count }.sorted(using: sortOrder)
    }

    var filteredKeyBindings: [KeyBinding] {
        if !query.isEmpty {
            keyBindings.filter {
                $0.keyWithoutModifiers.localizedCaseInsensitiveContains(query) || $0.actions.contains(where: { $0.localizedCaseInsensitiveContains(query )})
            }
        } else {
            keyBindings
        }
    }

    var body: some View {
        Table(filteredKeyBindings, sortOrder: $sortOrder) {
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
        .searchable(text: $query)
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
        }
        .onChangeOfFile(at: url) { url in
            Task {
                do {
                    let data = try await Data(asyncContentsOf: url)
                    keyBindings = try KeyBindingsDocument(data: data).keyBindings
                    sortKeyBindings()
                } catch {
                    print("Failed to reload file", url, error)
                }
            }
        }
    }
}

#Preview {
    try! KeyBindingsView(document: KeyBindingsDocument(data: Data(contentsOf: systemKeyBindingsURL)), url: systemKeyBindingsURL)
}
