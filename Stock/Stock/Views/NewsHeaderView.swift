//  NewsHeaderView.swift
//  Created by aa on 12/1/22.

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

final class NewsHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties
    static let identifier = "NewsHeaderView"
    static let preferredHeight: CGFloat = 70

    weak var delegate: NewsHeaderViewDelegate?

    // MARK: - UI Components
    private let label: UILabel = {
        $0.font = .systemFont(ofSize: 32, weight: .medium)
        return $0
    }(UILabel())

    lazy var button: UIButton = {
        $0.setTitle("+ Watchlist", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 8
        $0.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return $0
    }(UIButton())

    // MARK: - Initializers
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(label, button)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 16, y: 0, width: contentView.width - 32, height: contentView.height)
        button.sizeToFit()
        button.frame = CGRect(
            x: contentView.width - button.width - 32,
            y: (contentView.height - button.height) / 2,
            width: button.width + 16,
            height: button.height
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }

    func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }

    @objc private func didTapButton() {
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
}

// MARK: - ViewModel
extension NewsHeaderView {
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
}
