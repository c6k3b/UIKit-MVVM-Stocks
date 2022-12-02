//  WatchListViewController.swift
//  Created by aa on 11/30/22.

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    private var searchTimer: Timer?
    private var panel: FloatingPanelController?

    // model
    private var watchlistMap: [String: [CandleStick]] = [:]

    // viewModel
    private var viewModel: [String] = []

    private lazy var tableView: UITableView = {
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView())

    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitleView()
        setUpSearchController()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        fetchWatchlistData()
        setUpFloatingPanel()
    }

    // MARK: - Private
    private func fetchWatchlistData() {
        let symbols = PersistanceManager.shared.watchlist
        let group = DispatchGroup()
        for symbol in symbols {
            // fetch market data
            group.enter()
            APIManager.shared.marketData(for: symbol) { [weak self] result in
                defer { group.leave() }
                switch result {
                    case .success(let data):
                        let candleSticks = data.candleSticks
                        self?.watchlistMap[symbol] = candleSticks
                    case .failure(let error): print(error)
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }

    private func setUpTitleView() {
        let titleView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100)
        )
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        titleView.addSubview(label)

        navigationItem.titleView = titleView
    }

    private func setUpSearchController() {
        let resultsVC = SearchResultsViewController()
        resultsVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultsVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty
        else { return }

        searchTimer?.invalidate()

        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APIManager.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVC.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
}

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let viewController = StockDetailsViewController()
        let navVC = UINavigationController(rootViewController: viewController)
        viewController.title = searchResult.description
        present(navVC, animated: true)
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistMap.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // open details for selection
    }
}
