//
//  AppDelegate.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/16/23.
//

import Cocoa
import SwiftUI

@main
@MainActor
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

    let systemKeyBindingsURL = URL(fileURLWithPath: "/System/Library/Frameworks/AppKit.framework/Resources/StandardKeyBinding.dict")

    var userKeyBindingsURL: URL? {
        guard let passInfo = getpwuid(getuid()) else {
            return nil
        }
        let homeDir = String(cString: passInfo.pointee.pw_dir)
        return URL(fileURLWithPath: homeDir + "/Library/KeyBindings/DefaultKeyBinding.dict")
    }

    var userKeyBindingsExists: Bool {
        guard let path = userKeyBindingsURL else {
            return false
        }
        return FileManager.default.fileExists(atPath: path.path)
    }

    @objc func openSystemKeyBindings(_ sender: Any?) {
        open(url: systemKeyBindingsURL)
    }

    @objc func openUserKeyBindings(_ sender: Any?) {
        if let userKeyBindingsURL {
            open(url: userKeyBindingsURL)
        }
    }

    func open(url: URL) {
        Task {
            do {
                let _ = try await NSDocumentController.shared.openDocument(withContentsOf: url, display: true)
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }
    }
}

extension AppDelegate: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(openUserKeyBindings(_:)) {
            return userKeyBindingsExists
        }
        return true
    }
}
