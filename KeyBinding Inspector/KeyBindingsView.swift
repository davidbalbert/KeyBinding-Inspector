//
//  KeyBindingsView.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import SwiftUI

struct KeyBindingsView: View {
    let content: Document.Content
    @State var sortOrder = [KeyPathComparator(\KeyBinding.keyWithoutModifiers)]

    @State var searchText: String = ""
    var query: String {
        if transitioning && !showingAccessoryBar {
            ""
        } else {
            searchText
        }
    }

    enum Focus: Hashable {
        case search
        case table
    }

    @FocusState var focus: Focus?
    @State var showingAccessoryBar: Bool = false
    @State var transitioning: Bool = false

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

        var bindings = content.keyBindings
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
        .focused($focus, equals: .table)
        .defaultFocus($focus, .table)
        .accessoryBar($showingAccessoryBar) {
            TextField("Search", text: $searchText)
                .textFieldStyle(.accessoryBarSearchField)
                .focused($focus, equals: .search)
                .onKeyPress(.escape) {
                    showingAccessoryBar = false
                    focus = .table
                    return .handled
                }
        }
        .onChange(of: showingAccessoryBar) {
            transitioning = true
        }
        .onCommand(#selector(NSResponder.performTextFinderAction)) {
            showingAccessoryBar = true
            focus = .search
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
    }
}

#Preview {
    let systemKeyBindingsURL = URL(fileURLWithPath: "/System/Library/Frameworks/AppKit.framework/Resources/StandardKeyBinding.dict")
    return try! KeyBindingsView(content: Document.Content(Array<KeyBinding>(contentsOf: Data(contentsOf: systemKeyBindingsURL))))
}
