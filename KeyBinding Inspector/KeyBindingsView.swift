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

    @State var queryText: String = ""
    var query: String {
        if transitioning && !showingAccessoryBar {
            ""
        } else {
            queryText
        }
    }

    @FocusState var searchFieldFocused: Bool
    @State var showingAccessoryBar: Bool = false
    @State var transitioning: Bool = false

    func matchesQuery(_ binding: KeyBinding, _ query: String) -> Bool {
        if query.isEmpty {
            return true
        }

        return (
            binding.keyWithoutModifiers.localizedCaseInsensitiveContains(query) ||
            binding.actions.contains(where: { $0.localizedCaseInsensitiveContains(query) }) ||
            binding.escapedRawKey.localizedCaseInsensitiveContains(query)
        )
    }

    var filteredKeyBindings: [KeyBinding] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)

        var bindings = keyBindings
        bindings.removeAll {
            !matchesQuery($0, q)
        }

        bindings.sort { $0.modifiers.count < $1.modifiers.count }
        bindings.sort(using: sortOrder)

        return bindings
    }
    
    func rangesOfQuery(in attrStr: AttributedString) -> [Range<AttributedString.Index>] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            return []
        }

        var ranges: [Range<AttributedString.Index>] = []
        var start = attrStr.startIndex
        while let range = attrStr[start...].range(of: q, options: .caseInsensitive) {
            ranges.append(range)
            start = range.upperBound
        }

        return ranges
    }

    func highlight(_ attrStr: inout AttributedString) {
        let ranges = rangesOfQuery(in: attrStr)
        for r in ranges {
            attrStr[r].backgroundColor = .systemYellow.withSystemEffect(.disabled)
        }
    }

    func attributedString(for string: String) -> AttributedString {
        var attrStr = AttributedString(string)
        highlight(&attrStr)
        return attrStr
    }

    func formattedRawKey(for string: String) -> AttributedString {
        var attrStr = AttributedString(string)
        attrStr.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        highlight(&attrStr)
        return attrStr
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

                    Text(attributedString(for: b.keyWithoutModifiers))
                }
            }

            TableColumn("Raw", value: \.escapedRawKey) { b in
                Text(formattedRawKey(for: b.escapedRawKey))
            }

            TableColumn("Action", value: \.formattedActions) { b in
                Text(attributedString(for: b.formattedActions))
            }
        }
        .accessoryBar($showingAccessoryBar) {
            TextField("Search", text: $queryText)
                .textFieldStyle(.accessoryBarSearchField)
                .focused($searchFieldFocused)
                .onKeyPress(.escape) {
                    showingAccessoryBar = false
                    return .handled
                }
        }
        .focusedSceneValue(\.showingAccessoryBar, $showingAccessoryBar)
        .focusedSceneValue(\.searchFieldFocused, $searchFieldFocused)
        .onChange(of: showingAccessoryBar) {
            transitioning = true
        }
        .onChange(of: transitioning) {
            if !transitioning && !showingAccessoryBar {
                queryText = ""
            }
        }
        .transaction { t in
            if t.animation != nil {
                t.addAnimationCompletion {
                    transitioning = false
                }
            }
        }
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
