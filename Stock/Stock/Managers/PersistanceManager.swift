//  PersistanceManager.swift
//  Created by aa on 11/30/22.

import Foundation

final class PersistanceManager {
    static let shared = PersistanceManager()
    private init() {}

    // MARK: - Properties
    private let userDefaults: UserDefaults = .standard
    private var hasOnboarded: Bool { userDefaults.bool(forKey: Constants.onboardedKey) }
}

// MARK: - Methods
extension PersistanceManager {
    var getWatchlist: [String] {
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }

    func isWatchlistContains(symbol: String) -> Bool {
        return getWatchlist.contains(symbol)
    }

    func addToWatchlist(symbol: String, companyName: String) {
        var current = getWatchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchlistKey)
        userDefaults.set(companyName, forKey: symbol)

        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }

    func removeFromWatchList(symbol: String) {
        var newList = [String]()
        userDefaults.set(nil, forKey: symbol)

        for item in getWatchlist where item != symbol {
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchlistKey)
    }
}

// MARK: - Private Methods
private extension PersistanceManager {
    func setUpDefaults() {
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

        let symbols = Array(map.keys)  // map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)

        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}

// MARK: - Private Helpers
private extension PersistanceManager {
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
}
