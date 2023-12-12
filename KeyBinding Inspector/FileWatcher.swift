//
//  FileWatcher.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/12/23.
//

import Foundation

class FileWatcher: NSObject, NSFilePresenter {
    let url: URL
    let action: () async -> Void

    var presentedItemURL: URL? { url }
    var presentedItemOperationQueue: OperationQueue {
        OperationQueue.main
    }

    init(url: URL, action: @escaping () async -> Void) {
        self.url = url
        self.action = action
    }

    func presentedItemDidChange() {
        Task {
            await action()
        }
    }
}
