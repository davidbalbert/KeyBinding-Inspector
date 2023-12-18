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
    class Content {
        var keyBindings: [KeyBinding]

        convenience init() {
            self.init([])
        }

        init(_ keyBindings: [KeyBinding]) {
            self.keyBindings = keyBindings
        }

        init(contentsOf data: Data) throws {
            guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
                throw CocoaError(.fileReadCorruptFile)
            }

            guard let dict = plist as? [String: Any] else {
                throw CocoaError(.fileReadCorruptFile)
            }

            keyBindings = dict.map { (key, value) in
                let actions: [String]
                if let s = value as? String {
                    actions = [s]
                } else if let a = value as? [String] {
                    actions = a
                } else {
                    actions = []
                }
                return KeyBinding(key: key, actions: actions)
            }
        }
    }

    var content: Content = Content()
    var digest: SHA256.Digest?

    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        true
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        let c = WindowController()
        let rootView = KeyBindingsView(content: content)
            .environment(\.windowController, c)
        let w = NSWindow(contentViewController: NSHostingController(rootView: rootView))
        w.setContentSize(CGSize(width: 800, height: 600))
        c.window = w
        addWindowController(c)
    }

    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
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
        content.keyBindings = try Content(contentsOf: data).keyBindings
        digest = SHA256.hash(data: data)
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

            let d = SHA256.hash(data: data)

            if digest != d {
                DispatchQueue.main.async { [self] in
                    digest = d
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
