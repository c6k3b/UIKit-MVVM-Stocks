//  SearchResultsTableViewCell.swift
//  Created by aa on 11/30/22.

import UIKit

final class SearchResultsTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "SearchResultsTableViewCell"

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
