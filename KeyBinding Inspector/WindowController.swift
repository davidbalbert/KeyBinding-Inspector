//
//  WindowController.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/17/23.
//

import Cocoa
import SwiftUI

struct WindowControllerKey: EnvironmentKey {
    static let defaultValue: WindowController? = nil
}

extension EnvironmentValues {
    var windowController: WindowController? {
        get { self[WindowControllerKey.self] }
        set { self[WindowControllerKey.self] = newValue }
    }
}

class WindowController: NSWindowController {
    static let didPerformFindNotification = Notification.Name("didPerformFindNotification")

    @objc func find(_ sender: Any?) {
        NotificationCenter.default.post(name: Self.didPerformFindNotification, object: self)
    }
}
