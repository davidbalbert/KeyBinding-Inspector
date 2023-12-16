//
//  KeyBindingsViewController.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/16/23.
//

import SwiftUI

class KeyBindingsViewController: NSHostingController<KeyBindingsView> {
    init(keyBindings: KeyBindings) {
        let view = KeyBindingsView(document: keyBindings)
        super.init(rootView: view)
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
