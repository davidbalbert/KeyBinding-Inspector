//
//  Foundation+Extensions.swift
//  KeyBinding Inspector
//
//  Created by David Albert on 12/12/23.
//

import Foundation

extension Data {
    init(asyncContentsOf url: URL, options: Data.ReadingOptions = []) async throws {
        self = try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let res = Result {
                    try Data(contentsOf: url, options: options)
                }
                continuation.resume(with: res)
            }
        }
    }
}
