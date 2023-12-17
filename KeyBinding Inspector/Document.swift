//
//  Document.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/16/23.
//

import Cocoa
import SwiftUI

class KeyBindings: NSObject {
    var bindings: [KeyBinding]

    init(_ keyBindings: [KeyBinding]) {
        bindings = keyBindings
    }

    override convenience init() {
        self.init([])
    }

    init(contentsOf data: Data) throws {
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        guard let dict = plist as? [String: Any] else {
            throw CocoaError(.fileReadCorruptFile)
        }

        bindings = dict.map { (key, value) in
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

class Document: NSDocument {
    @objc var keyBindings: KeyBindings = KeyBindings()

    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        true
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        let c = WindowController()

        let rootView = KeyBindingsView(document: keyBindings)
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
        keyBindings = try KeyBindings(contentsOf: data)
    }
}
