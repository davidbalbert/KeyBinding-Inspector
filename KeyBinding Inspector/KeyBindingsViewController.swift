//
//  KeyBindingsViewController.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/16/23.
//

import SwiftUI

@Observable
class ViewModel {
    var isSearching: Bool = false
}

// TODO: get rid of AnyView
class KeyBindingsViewController: NSHostingController<AnyView> {
    let viewModel = ViewModel()

    init(keyBindings: KeyBindings) {
        let view = KeyBindingsView(document: keyBindings)
            .environment(viewModel)
        super.init(rootView: AnyView(view))
    }
    
    @MainActor required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func performTextFinderAction(_ sender: Any?) {
        print("textfinderaction")
        viewModel.isSearching = true
    }
}
