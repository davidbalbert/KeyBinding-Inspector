//
//  Foundation+Extensions.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/12/23.
//

import Foundation

extension AttributedStringProtocol {
    func ranges<T>(of stringToFind: T, options: String.CompareOptions = [], locale: Locale? = nil) -> [Range<AttributedString.Index>] where T: StringProtocol {
        var ranges: [Range<AttributedString.Index>] = []
        var start = startIndex
        while let range = self[start...].range(of: stringToFind, options: options, locale: locale) {
            ranges.append(range)
            start = range.upperBound
        }

        return ranges
    }
}
