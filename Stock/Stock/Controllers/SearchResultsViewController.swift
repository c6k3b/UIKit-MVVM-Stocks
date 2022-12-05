//  SearchResultsViewController.swift
//  Created by aa on 11/30/22.

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultViewControllerDidSelect(searchResult: SearchResult)
}

final class SearchResultsViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: SearchResultsViewControllerDelegate?
    private var results: [SearchResult] = []

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        $0.isHidden = true
        $0.register(SearchResultsTableViewCell.self, forCellReuseIdentifier: SearchResultsTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView())

    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func update(with results: [SearchResult]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }
}

// MARK: - Delegates
extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewCell.identifier, for: indexPath)
        let model = results[indexPath.row]
        cell.textLabel?.text = model.displaySymbol
        cell.detailTextLabel?.text = model.description
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = results[indexPath.row]
        delegate?.searchResultViewControllerDidSelect(searchResult: model)
    }
}
