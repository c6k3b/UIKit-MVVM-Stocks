//  HapticsManager.swift
//  Created by aa on 11/30/22.

import UIKit

final class HapticsManager {
    static let shared = HapticsManager()
    private init() {}
}

// MARK: - Methods
extension HapticsManager {
    func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
