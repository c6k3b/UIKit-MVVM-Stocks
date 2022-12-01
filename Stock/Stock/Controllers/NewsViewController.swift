//  NewsViewController.swift
//  Created by aa on 11/30/22.

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    enum `Type` {
        case topStories
        case company(symbol: String)

        var title: String {
            switch self {
                case .topStories: return "Top Stories"
                case .company(let symbol): return symbol.uppercased()
            }
        }
    }

    // MARK: - Properties
    private var stories = [NewsStory]()
    private var type: Type

    lazy var tableView: UITableView = {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        $0.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        return $0
    }(UITableView())

    // MARK: - Initializers
    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTable()
        fetchNews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    // MARK: - Private Methods
    private func setUpTable() {
        view.addSubview(tableView)
    }

    private func fetchNews() {
        APIManager.shared.news(for: type) { [weak self] result in
            switch result {
                case .success(let stories):
                    DispatchQueue.main.async {
                        self?.stories = stories
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }

    private func open(url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

    private func presentFailedToOpenAlert() {
        let alert = UIAlertController(
            title: "Unable to Open",
            message: "We were unable to open the article.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsStoryTableViewCell.identifier,
            for: indexPath
        ) as? NewsStoryTableViewCell else { return UITableViewCell() }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else { return nil }
        header.configure(with: .init(title: self.type.title, shouldShowAddButton: false))
        return header

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // open news story
        let story = stories[indexPath.row]
        guard let url = URL(string: story.url) else {
            presentFailedToOpenAlert()
            return
        }
        open(url: url)
    }
}
