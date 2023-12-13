//
//  KeyBindingsView.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import SwiftUI


struct SearchFieldFocusedKey: FocusedValueKey {
    typealias Value = FocusState<Bool>.Binding
}

extension FocusedValues {
    var searchFieldFocused: SearchFieldFocusedKey.Value? {
        get { self[SearchFieldFocusedKey.self] }
        set { self[SearchFieldFocusedKey.self] = newValue }
    }
}

struct ShowingAccessoryBarKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    var showingAccessoryBar: ShowingAccessoryBarKey.Value? {
        get { self[ShowingAccessoryBarKey.self] }
        set { self[ShowingAccessoryBarKey.self] = newValue}
    }
}


struct KeyBindingsView: View {
    let document: KeyBindingsDocument
    let url: URL?

    @State var sortOrder = [KeyPathComparator(\KeyBinding.keyWithoutModifiers)]
    @State var keyBindings: [KeyBinding] = []
    @State var query: String = ""

    @State var showingAccessoryBar: Bool = true
    @FocusState var searchFieldFocused: Bool

    var filteredKeyBindings: [KeyBinding] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)

        var bindings = keyBindings
        if !q.isEmpty {
            bindings.removeAll {
                !$0.keyWithoutModifiers.localizedCaseInsensitiveContains(q) && !$0.actions.contains(where: { $0.localizedCaseInsensitiveContains(q)})
            }
        }

        bindings.sort { $0.modifiers.count < $1.modifiers.count }
        bindings.sort(using: sortOrder)

        return bindings
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
        .accessoryBar($showingAccessoryBar) {
            TextField("Search", text: $query)
                .textFieldStyle(.accessoryBarSearchField)
                .focused($searchFieldFocused)
                .onKeyPress(.escape) {
                    showingAccessoryBar = false
                    return .handled
                }
        }
        .focusedSceneValue(\.showingAccessoryBar, $showingAccessoryBar)
        .focusedSceneValue(\.searchFieldFocused, $searchFieldFocused)
        .animation(.easeInOut(duration: 0.1), value: showingAccessoryBar)
        .onChange(of: document) {
            keyBindings = document.keyBindings
        }
        .onAppear {
            keyBindings = document.keyBindings
        }
        .onChangeOfFile(at: url) { url in
            Task {
                do {
                    let data = try await Data(asyncContentsOf: url)
                    keyBindings = try KeyBindingsDocument(data: data).keyBindings
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
