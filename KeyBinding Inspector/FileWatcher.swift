//
//  FileWatcher.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/12/23.
//

import SwiftUI

class FileWatcher: NSObject, NSFilePresenter {
    let url: URL
    let action: () -> Void

    init(url: URL, perform action: @escaping () -> Void) {
        self.url = url
        self.action = action
    }

    var presentedItemURL: URL? { url }
    var presentedItemOperationQueue: OperationQueue {
        OperationQueue.main
    }

    func presentedItemDidChange() {
        action()
    }
}

struct WatchFile: ViewModifier {
    let fileWatcher: FileWatcher

    init(url: URL, perform action: @escaping (URL) -> Void) {
        fileWatcher = FileWatcher(url: url) {
            action(url)
        }
    }

    func body(content: Content) -> some View {
        content
            .background {
                Color.clear
                    .onAppear {
                        NSFileCoordinator.addFilePresenter(fileWatcher)
                    }
                    .onDisappear {
                        NSFileCoordinator.removeFilePresenter(fileWatcher)
                    }
            }
    }
}

extension View {
    @ViewBuilder
    func onChange(ofFileAt url: URL?, perform action: @escaping (URL) -> Void) -> some View {
        if let url {
            modifier(WatchFile(url: url, perform: action))
        } else {
            self
        }
    }
}
