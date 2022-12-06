//  WatchListViewController.swift
//  Created by aa on 11/30/22.

import UIKit
import FloatingPanel

final class WatchListViewController: UIViewController {
    // MARK: - Properties
    private var watchlistMap: [String: [CandleStick]] = [:]
    private var viewModels: [WatchListTableViewCell.ViewModel] = []

    private var searchTimer: Timer?
    private var panel: FloatingPanelController?
    private var observer: NSObjectProtocol?

    // MARK: - UI Components
    static var maxChangeWidth: CGFloat = 0

    private lazy var tableView: UITableView = {
        $0.rowHeight = WatchListTableViewCell.preferredHeight
        $0.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView())

    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)

        setUpTitleView()
        setUpSearchController()
        fetchWatchlistData()
        setUpFloatingPanel()
        setUpObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

// MARK: - Private Methods
private extension WatchListViewController {
    func setUpObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchWatchlistData()
            }
        )
    }

    func fetchWatchlistData() {
        let symbols = PersistanceManager.shared.getWatchlist
        createPlaceholderViewModel()

        let group = DispatchGroup()
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            APIManager.shared.getMarketData(for: symbol) { [weak self] result in
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
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }

    func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = candleSticks.getPercentage()
            viewModels.append(.init(
                symbol: symbol,
                companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                price: getLatestClosingPrice(from: candleSticks),
                changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                changePercentage: .percentage(from: changePercentage),
                chartViewModel: .init(
                    data: candleSticks.reversed().map { $0.close },
                    showLegend: false,
                    showAxis: false,
                    fillColor: changePercentage < 0 ? .systemRed : .systemGreen
                )
            ))
        }
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
    }

    func createPlaceholderViewModel() {
        let symbols = PersistanceManager.shared.getWatchlist
        symbols.forEach { item in
            viewModels.append(
                .init(
                    symbol: item,
                    companyName: UserDefaults.standard.string(forKey: item) ?? "Company",
                    price: "0.00",
                    changeColor: .systemGreen,
                    changePercentage: "0.00",
                    chartViewModel: .init(
                        data: [],
                        showLegend: false,
                        showAxis: false,
                        fillColor: .clear
                    )
                )
            )
        }
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
        tableView.reloadData()
    }

    func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else { return "" }
        return .formatted(number: closingPrice)
    }

    func setUpFloatingPanel() {
        let viewController = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: viewController)
        panel.addPanel(toParent: self)
        panel.track(scrollView: viewController.tableView)
    }

    func setUpTitleView() {
        let titleView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100)
        )
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width - 20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 32, weight: .medium)
        titleView.addSubview(label)

        navigationItem.titleView = titleView
    }

    func setUpSearchController() {
        let resultsVC = SearchResultsViewController()
        resultsVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultsVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

// MARK: - Methods
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

// MARK: - Delegates
extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        HapticsManager.shared.vibrateForSelection()

        let viewController = StockDetailsViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description
        )
        let navigationVC = UINavigationController(rootViewController: viewController)
        viewController.title = searchResult.description
        present(navigationVC, animated: true)
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WatchListTableViewCell.identifier
        ) as? WatchListTableViewCell
        else { fatalError("cell not configured") }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        cell.layoutIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()

        let viewModel = viewModels[indexPath.row]
        let viewController = StockDetailsViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchlistMap[viewModel.symbol] ?? []
        )
        let navigationVC = UINavigationController(rootViewController: viewController)
        present(navigationVC, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath
    ) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            PersistanceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
            viewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdateMaxWidth() {
        // Optimize: Only refresh rows prior to current row that changes the max width
        tableView.reloadData()
    }
}
