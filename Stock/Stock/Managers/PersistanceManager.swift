//  PersistanceManager.swift
//  Created by aa on 11/30/22.

import Foundation

final class PersistanceManager {
    static let shared = PersistanceManager()
    private let userDefaults: UserDefaults = .standard
    private var hasOnboarded: Bool { return false }
    private struct Constants {
    }

    private init() {}

    // MARK: - Public
    public var watchList: [String] {
        return []
    }

    public func addToWatchList() {
    }

    public func removeFromWatchList() {
    }
}
