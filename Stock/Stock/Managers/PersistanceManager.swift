//  PersistanceManager.swift
//  Created by aa on 11/30/22.

import Foundation

final class PersistanceManager {
    // MARK: - Properties
    static let shared = PersistanceManager()
    private let userDefaults: UserDefaults = .standard

    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }

    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }

    private init() {}

    // MARK: - Public
    public var watchlist: [String] {
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }

    public func watchListContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }

    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchlistKey)
        userDefaults.set(companyName, forKey: symbol)

        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }

    public func removeFromWatchList(symbol: String) {
        var newList = [String]()
        userDefaults.set(nil, forKey: symbol)

        for item in watchlist where item != symbol {
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchlistKey)
    }

    // MARK: - Private
    private func setUpDefaults() {
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft corporation",
            "SNAP": "Snap Inc",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com",
            "WORK": "Slack Technologies",
            "FB": "Facebook Inc",
            "NVDA": "Nvidia Inc",
            "NKE": "Nike",
            "PINS": "Pinterest Inc"
        ]

        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)

        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
