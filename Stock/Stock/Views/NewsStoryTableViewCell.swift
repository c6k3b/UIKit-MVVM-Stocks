//  NewsStoryTableViewCell.swift
//  Created by aa on 12/1/22.

import UIKit
import SDWebImage

class NewsStoryTableViewCell: UITableViewCell {
    static let identifier = "NewsStoryTableViewCell"
    static let preferredHeight: CGFloat = 140

    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageURL: URL?

        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageURL = URL(string: model.image)
        }
    }

    private let sourceLabel: UILabel = {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        return $0
    }(UILabel())

    private let headlineLabel: UILabel = {
        $0.font = .systemFont(ofSize: 22, weight: .regular)
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private let dateLabel: UILabel = {
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 14, weight: .light)
        return $0
    }(UILabel())

    private let storyImageView: UIImageView = {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.backgroundColor = .tertiarySystemBackground
        return $0
    }(UIImageView())

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height / 1.33
        storyImageView.frame = CGRect(
            x: contentView.width - imageSize - 10,
            y: (contentView.height - imageSize) / 2,
            width: imageSize,
            height: imageSize
        )

        let availableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 15
        dateLabel.frame = CGRect(x: separatorInset.left, y: contentView.height - 40, width: availableWidth, height: 40)

        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(x: separatorInset.left, y: 4, width: availableWidth, height: sourceLabel.height)

        headlineLabel.frame = CGRect(x: separatorInset.left, y: sourceLabel.bottom + 5, width: availableWidth, height: contentView.height - sourceLabel.bottom - dateLabel.height - 10)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }

    public func configure(with viewModel: ViewModel) {
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        storyImageView.sd_setImage(with: viewModel.imageURL)
//        storyImageView.setImage(with: viewModel.imageURL)
    }
}
