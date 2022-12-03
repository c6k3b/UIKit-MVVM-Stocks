//  AppDelegate.swift
//  Created by aa on 11/30/22.

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        debug()
        return true
    }

    private func debug() {
        APIManager.shared.marketData(for: "AAPL", numberOfDays: 1) { result in
//            switch result {
//                case .success(let data):
//                    let candleSticks = data.candleSticks
//                case .failure(let error):
//                    print(error)
//            }
        }
    }
}
