//
//  NotificationSubscriber.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/17/23.
//

import SwiftUI

struct NotificationSubscriber: ViewModifier {
    @State var observer: NSObjectProtocol?

    let name: Notification.Name
    let object: AnyObject?

    var id: ObjectIdentifier? {
        if let object {
            ObjectIdentifier(object)
        } else {
            nil
        }
    }

    let action: (Notification) -> Void

    func observe(_ object: Any?) {
        if let object {
            observer = NotificationCenter.default.addObserver(forName: name, object: object, queue: nil, using: action)
        }
    }

    func unobserve() {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: id, initial: true) {
                unobserve()
                observe(object)
            }
            .onDisappear {
                unobserve()
            }
    }
}

extension View {
    func onNotification(_ name: Notification.Name, requiringObject object: AnyObject?, perform action: @escaping (Notification) -> Void) -> some View {
        modifier(NotificationSubscriber(name: name, object: object, action: action))
    }
}

