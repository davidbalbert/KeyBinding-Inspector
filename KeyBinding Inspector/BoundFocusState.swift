//
//  BoundFocusState.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/16/23.
//

import SwiftUI

@propertyWrapper
struct BoundFocusState<Subject, Value>: DynamicProperty where Subject: AnyObject, Subject: Observable, Value: Hashable {
    @Environment(Subject.self) var subject: Subject

    // Can't do `@FocusState var focusState: Value` because Swift can't initialize
    // a FocusState without knowing if Value == Bool or Value is optional.
    var _focusState: FocusState<Value>
    var focusState: Value {
        get {
            _focusState.wrappedValue
        }
        nonmutating set {
            _focusState.wrappedValue = newValue
        }
    }

    let keyPath: ReferenceWritableKeyPath<Subject, Value>

    init(_ keyPath: ReferenceWritableKeyPath<Subject, Value>) where Value == Bool {
        _focusState = FocusState()
        self.keyPath = keyPath
    }

    init<T>(_ keyPath: ReferenceWritableKeyPath<Subject, Value>) where Value == T?, T: Hashable {
        _focusState = FocusState()
        self.keyPath = keyPath
    }

    var wrappedValue: Value {
        get {
            focusState
        }

        nonmutating set {
            focusState = newValue
            subject[keyPath: keyPath] = newValue
        }
    }

    // TODO: this might not work
    var projectedValue: FocusState<Value>.Binding {
        _focusState.projectedValue
    }

    mutating func update() {
        if subject[keyPath: keyPath] != focusState {
            focusState = subject[keyPath: keyPath]
        }
    }
}
