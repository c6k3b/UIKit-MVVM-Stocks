//  WatchListTableViewCell.swift
//  Created by aa on 12/2/22.

import UIKit

protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

class WatchListTableViewCell: UITableViewCell {
    static let identifier = "WatchListTableViewCell"
    static let preferredHeight: CGFloat = 60

    weak var delegate: WatchListTableViewCellDelegate?

    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }

    // MARK: - UIComponents
    private let symbolLabel: UILabel = {
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        return $0
    }(UILabel())

    private let nameLabel: UILabel = {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        return $0
    }(UILabel())

    private let priceLabel: UILabel = {
        $0.textAlignment = .right
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        return $0
    }(UILabel())

    private let changeLabel: UILabel = {
        $0.textAlignment = .right
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        return $0
    }(UILabel())

    private let miniChartView: StockChartView = {
        $0.clipsToBounds = true
        $0.backgroundColor = .link
        return $0
    }(StockChartView())

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(symbolLabel, nameLabel, miniChartView, priceLabel, changeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()

        symbolLabel.frame = CGRect(
            x: separatorInset.left,
            y: (contentView.height - symbolLabel.height - nameLabel.height) / 2,
            width: symbolLabel.width,
            height: symbolLabel.height
        )

        nameLabel.frame = CGRect(
            x: separatorInset.left,
            y: symbolLabel.bottom,
            width: nameLabel.width,
            height: nameLabel.height
        )

        let currentWidth = max(max(priceLabel.width, changeLabel.width), WatchListViewController.maxChangeWidth)

        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }

        priceLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: (contentView.height - priceLabel.height - changeLabel.height) / 2,
            width: currentWidth,
            height: priceLabel.height
        )

        changeLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: priceLabel.bottom,
            width: currentWidth,
            height: changeLabel.height
        )

        miniChartView.frame = CGRect(
            x: priceLabel.left - contentView.width / 3 - 5,
            y: 6,
            width: contentView.width / 3,
            height: contentView.height - 12
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }

    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        nameLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        // configure chart
    }
}
