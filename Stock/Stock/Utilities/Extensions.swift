//  Extensions.swift
//  Created by aa on 11/30/22.

import UIKit

// MARK: - Image
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
