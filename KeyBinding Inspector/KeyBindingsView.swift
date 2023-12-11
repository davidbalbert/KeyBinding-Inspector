//
//  KeyBindingsView.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/11/23.
//

import SwiftUI

struct KeyBindingsView: View {
    @State private var sortOrder = [KeyPathComparator(\KeyBinding.keyWithoutModifiers)]

    var document: KeyBindingsDocument

    var keyBindings: [KeyBinding] {
        document.keyBindings.sorted(using: sortOrder)
    }

//    @State var keyBindings: [KeyBinding] = {
//        let url = URL(fileURLWithPath: "/System/Library/Frameworks/AppKit.framework/Resources/StandardKeyBinding.dict")
//        let data = try! Data(contentsOf: url)
//        let plist = try! PropertyListSerialization.propertyList(from: data, options: [], format: nil)
//        let dict = plist as! [String: Any]
//
//        return dict.map { (key, value) in
//            let actions: [String]
//            if let s = value as? String {
//                actions = [s]
//            } else if let a = value as? [String] {
//                actions = a
//            } else {
//                actions = []
//            }
//            return KeyBinding(key: key, actions: actions)
//        }
//    }()

    var body: some View {
        Table(keyBindings, sortOrder: $sortOrder) {
            TableColumn("") {
                Text($0.modifiers)
                    .padding(0)
            }
            .width(max: 40)
            .alignment(.trailing)
            .disabledCustomizationBehavior(.resize)

            TableColumn("Key", value: \.keyWithoutModifiers)
            TableColumn("Action", value: \.formattedActions)
        }
    }
}

#Preview {
    KeyBindingsView(document: KeyBindingsDocument())
}
