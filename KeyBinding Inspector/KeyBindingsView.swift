//
//  KeyBindingsView.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import SwiftUI

struct WindowControllerKey: EnvironmentKey {
    static let defaultValue: WindowController? = nil
}

extension EnvironmentValues {
    var windowController: WindowController? {
        get { self[WindowControllerKey.self] }
        set { self[WindowControllerKey.self] = newValue }
    }
}

struct KeyBindingsView: View {
    let document: KeyBindings

    @State var sortOrder = [KeyPathComparator(\KeyBinding.keyWithoutModifiers)]
    @State var keyBindings: [KeyBinding] = []

    @State var searchText: String = ""
    var query: String {
        if transitioning && !showingAccessoryBar {
            ""
        } else {
            searchText
        }
    }

    @FocusState var isSearching: Bool
    @State var showingAccessoryBar: Bool = false
    @State var transitioning: Bool = false

    @Environment(\.windowController) var windowController: WindowController?

    func matchesQuery(_ binding: KeyBinding, _ query: String) -> Bool {
        if query.isEmpty {
            return true
        }

        return (
            binding.keyWithoutModifiers.localizedCaseInsensitiveContains(query) ||
            binding.actions.contains(where: { $0.localizedCaseInsensitiveContains(query) }) ||
            binding.rawKey.localizedCaseInsensitiveContains(query)
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

    func highlight(_ s: String) -> AttributedString {
        highlight(AttributedString(s))
    }

    func highlight(_ attrStr: AttributedString) -> AttributedString {
        var s = attrStr

        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let ranges = s.ranges(of: q, options: .caseInsensitive)
        for r in ranges {
            s[r].backgroundColor = .systemYellow.withSystemEffect(.disabled)
        }

        return s
    }

    func attributedString(for string: String) -> AttributedString {
        return highlight(AttributedString(string))
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

                    Text(highlight(b.keyWithoutModifiers))
                }
            }

            TableColumn("Raw", value: \.rawKey) { b in
                Text(highlight(b.attributedRawKey))
            }

            TableColumn("Action", value: \.formattedActions) { b in
                Text(highlight(b.formattedActions))
            }
        }
        .accessoryBar($showingAccessoryBar) {
            TextField("Search", text: $searchText)
                .textFieldStyle(.accessoryBarSearchField)
                .focused($isSearching)
                .onKeyPress(.escape) {
                    showingAccessoryBar = false
                    return .handled
                }
        }
        .onChange(of: showingAccessoryBar) {
            transitioning = true
        }
        // Can't use onCommand because we want this to fire even when our NSWindow is the start of
        // the responder chain. I wish there was a better way to do this.
        .onNotification(WindowController.didPerformFindNotification, requiringObject: windowController) { _ in
            showingAccessoryBar = true
            isSearching = true
        }
        .onChange(of: transitioning) {
            if !transitioning && !showingAccessoryBar {
                searchText = ""
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
        .onAppear {
            keyBindings = document.bindings
        }
    }
}

#Preview {
    try! KeyBindingsView(document: KeyBindings(contentsOf: Data(contentsOf: systemKeyBindingsURL)))
}
