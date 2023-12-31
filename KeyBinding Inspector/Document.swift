//
//  Document.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/16/23.
//

import Cocoa
import SwiftUI
import CryptoKit

class Document: NSDocument {
    @Observable
    final class Content {
        var keyBindings: [KeyBinding]

        convenience init() {
            self.init([])
        }

        init(_ keyBindings: [KeyBinding]) {
            self.keyBindings = keyBindings
        }
    }

    var content: Content = Content()
    var digest: Data? // SHA256Digest

    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        true
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        let rootView = KeyBindingsView(content: content)
        let vc = NSHostingController(rootView: rootView)
        let w = NSWindow(contentViewController: vc)
        w.setContentSize(CGSize(width: 800, height: 500))

        let wc = NSWindowController(window: w)

        if let p = NSApp.mainWindow?.cascadeTopLeft(from: .zero) {
            w.cascadeTopLeft(from: p)
        } else {
            w.center()
        }

        addWindowController(wc)
    }

    override func data(ofType typeName: String) throws -> Data {
        //        let seq = try keyBindings.map { b in
        //            let value: Any
        //            if b.actions.isEmpty {
        //                throw Errors.missingAction
        //            } else if b.actions.count == 1 {
        //                value = b.actions[0]
        //            } else {
        //                value = b.actions
        //            }
        //
        //            return (b.key, value)
        //        }
        //
        //        let plist = Dictionary(seq) { a, b in b }
        //        return try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0))
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        let kb = try Array<KeyBinding>(contentsOf: data)
        let d = Data(SHA256.hash(data: data))

        Task.detached { @MainActor [self] in
            content.keyBindings = kb
            digest = d
        }
    }

    override func presentedItemDidChange() {
        guard let fileURL, let fileType else {
            return
        }

        var error: NSError?
        NSFileCoordinator(filePresenter: self).coordinate(readingItemAt: fileURL, options: .withoutChanges, error: &error) { url in
            guard let data = try? Data(contentsOf: url) else {
                Swift.print("Document.presentedItemDidChange(): Error reading \(url)")
                return
            }

            let d = Data(SHA256.hash(data: data))

            Task.detached { @MainActor [self] in
                if digest == nil || Data(digest!) == d {
                    do {
                        try revert(toContentsOf: url, ofType: fileType)
                    } catch {
                        Swift.print("Document.presentedItemDidChange(): Error reverting \(url): \(error)")
                    }
                }
            }
        }
    }
}
