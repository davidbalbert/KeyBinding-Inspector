//
//  WindowController.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/17/23.
//

import Cocoa

class WindowController: NSWindowController {
    static let didPerformFindNotification = Notification.Name("didPerformFindNotification")

    override func windowDidLoad() {
        super.windowDidLoad()
    }

    @objc func find(_ sender: Any?) {
        NotificationCenter.default.post(name: Self.didPerformFindNotification, object: self)
    }
}
