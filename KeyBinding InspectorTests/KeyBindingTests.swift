//
//  KeyBindingTests.swift
//  KeyBinding InspectorTests
//
//  Created by David Albert on 12/18/23.
//

import XCTest
@testable import KeyBinding_Inspector

final class KeyBindingTests: XCTestCase {
    func testParse() {
        func t(_ raw: String, _ expected: String, file: StaticString = #file, line: UInt = #line) {
            let kb = KeyBinding(key: raw, actions: [])
            XCTAssertEqual(kb.modifiers + kb.keyWithoutModifiers, expected, file: file, line: line)
        }

        t("", "")
        t("a", "A")
        t("A", "⇧A")
        t("$a", "⇧A")
        t("^a", "⌃A")
        t("^A", "⌃⇧A")
        t("^$a", "⌃⇧A")
        t("~a", "⌥A")
        t("~A", "⌥⇧A")
        t("@a", "⌘A")
        t("@A", "⇧⌘A")
        t("@$~^a", "⌃⌥⇧⌘A")
        t("@~^A", "⌃⌥⇧⌘A")
        t("@ ", "⌘Space")
        t("@\n", "⌘Return")
        t("@\r", "⌘Return")
        t("@\t", "⌘Tab")
        t("@\u{1b}", "⌘Esc")
        t("@\\033", "⌘Esc")
        t("@\u{08}", "⌘⌫")
        t("@\u{7f}", "⌘⌫")
        t("@\\010", "⌘⌫")
        t("@\u{f728}", "⌘⌦ (Fn-Delete)")
        t("@\u{f700}", "⌘Up Arrow")
        t("@\u{f701}", "⌘Down Arrow")
        t("@$.", "⇧⌘.")
        t("@>", "⌘>")
        t("\u{f729}", "Home (Fn-Left Arrow)")
        t("\u{f72b}", "End (Fn-Right Arrow)")
        t("\u{f72c}", "Page Up (Fn-Up Arrow)")
        t("\u{f72d}", "Page Down (Fn-Down Arrow)")
    }
}
