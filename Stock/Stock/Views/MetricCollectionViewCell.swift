//  MetricCollectionViewCell.swift
//  Created by aa on 12/4/22.

import UIKit

class MetricCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "MetricCollectionViewCell"

    struct ViewModel {
        let name: String
        let value: String
    }

    // MARK: - UI Components
    private let nameLabel: UILabel = {
        return $0
    }(UILabel())

    private let valueLabel: UILabel = {
        $0.textColor = .secondaryLabel
        return $0
    }(UILabel())

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubviews(nameLabel, valueLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.sizeToFit()
        valueLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 3, y: 0, width: nameLabel.width, height: contentView.height)
        valueLabel.frame = CGRect(x: nameLabel.right + 3, y: 0, width: valueLabel.width, height: contentView.height)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        valueLabel.text = nil
    }

    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name + ": "
        valueLabel.text = viewModel.value
    }
}
