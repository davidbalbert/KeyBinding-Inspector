//
//  AppDelegate.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/16/23.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var updaterState: UpdaterState = UpdaterState()
    var updaterWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("didFinishLaunching")
    }

    @objc func checkForUpdates(_ sender: Any?) {
        let w: NSWindow
        if let updaterWindow {
            w = updaterWindow
        } else {
            let rootView = Updater(state: updaterState)
            let controller = NSHostingController(rootView: rootView)
            w = NSWindow(contentViewController: controller)
            w.styleMask.remove(.resizable)
        }

        updaterState.reset()

        w.center()
        w.makeKeyAndOrderFront(self)

        if updaterWindow != nil {
            updaterState.recheck()
        }
        
        updaterWindow = w
    }
}
