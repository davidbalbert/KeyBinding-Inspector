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

    let repositoryURL = URL(string: "https://github.com/davidbalbert/KeyBinding-Inspector")!
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

    func applicationWillFinishLaunching(_ notification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidFinishRestoringWindows), name: NSApplication.didFinishRestoringWindowsNotification, object: NSApplication.shared)
    }

    @objc func applicationDidFinishRestoringWindows(_ notification: Notification) {
        if NSDocumentController.shared.documents.isEmpty {
            open(fileURL: systemKeyBindingsURL)
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
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

    @objc func openSystemKeyBindings(_ sender: Any?) {
        open(fileURL: systemKeyBindingsURL)
    }

    @objc func openUserKeyBindings(_ sender: Any?) {
        if let userKeyBindingsURL {
            open(fileURL: userKeyBindingsURL)
        }
    }

    func open(fileURL: URL) {
        Task {
            do {
                let _ = try await NSDocumentController.shared.openDocument(withContentsOf: fileURL, display: true)
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }
    }

    @objc func openReadme(_ sender: Any?) {
        // This gives warnings to do with concurrency. Not sure why given that everything's
        // running on MainActor, but let's do it the old fashioned way.

        // Task {
        //     do {
        //         let _ = try await NSWorkspace.shared.open(helpURL, configuration: .init())
        //     } catch {
        //         let alert = NSAlert(error: error)
        //         alert.runModal()
        //     }
        // }

        NSWorkspace.shared.open(repositoryURL, configuration: .init()) { _, error in
            if let error {
                DispatchQueue.main.async {
                    let alert = NSAlert(error: error)
                    alert.runModal()
                }
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
