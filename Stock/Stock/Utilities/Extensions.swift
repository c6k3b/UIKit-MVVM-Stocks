//  Extensions.swift
//  Created by aa on 11/30/22.

import UIKit

// MARK: - Notifications
extension Notification.Name {
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}

// MARK: - NumberFormatter
extension NumberFormatter {
    static let percentageFormatter: NumberFormatter = {
        $0.locale = .current
        $0.numberStyle = .percent
        $0.maximumFractionDigits = 2
        return $0
    }(NumberFormatter())

    static let numberFormatter: NumberFormatter = {
        $0.locale = .current
        $0.numberStyle = .decimal
        $0.maximumFractionDigits = 2
        return $0
    }(NumberFormatter())
}

// MARK: - ImageView
extension UIImageView {
    func setImage(with url: URL?) {
        guard let url = url else { return }
        DispatchQueue.global(qos: .background).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}

// MARK: - String
extension String {
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }

    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentageFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }

    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - DateFormatter
extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        $0.dateFormat = "YYYY-MM-dd"
        return $0
    }(DateFormatter())

    static let prettyDateFormatter: DateFormatter = {
        $0.dateStyle = .medium
        return $0
    }(DateFormatter())
}

// MARK: - Add Subview
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}

// MARK: - Framing
extension UIView {
    var width: CGFloat { frame.size.width }
    var height: CGFloat { frame.size.height }
    var left: CGFloat { frame.origin.x }
    var right: CGFloat { left + width }
    var top: CGFloat { frame.origin.y }
    var bottom: CGFloat { top + height }
}

// MARK: - Candlestick sorting
extension Array where Element == CandleStick {
    func getPercentage() -> Double {
        let latestDate = self[0].date
        guard let latestClose = self.first?.close,
              let priorClose = self.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: latestDate) })?.close
        else { return 0 }

        let difference = 1 - priorClose / latestClose
        return difference
    }
}
