//  StockDetailsViewController.swift
//  Created by aa on 11/30/22.

import UIKit
import SafariServices

class StockDetailsViewController: UIViewController {
    // MARK: - Properties
    private let symbol: String
    private let companyName: String
    private let candleStickData: [CandleStick]

    private var stories = [NewsStory]()

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        $0.rowHeight = NewsStoryTableViewCell.preferredHeight
        $0.sectionHeaderHeight = NewsHeaderView.preferredHeight
        $0.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width * 0.7 + 100))
        $0.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        $0.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView())

    // MARK: - Initializers
    init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = companyName
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        setUpCloseButton()
        fetchFinancialData()
        fetchNews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    // MARK: - Private Methods
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func fetchFinancialData() {
        let group = DispatchGroup()

        if candleStickData.isEmpty {
            group.enter()
        }

        group.enter()
        APIManager.shared.financialMetrics(for: symbol) { result in
            defer { group.leave() }

            switch result {
                case .success(let response):
                    let metrics = response.metric
                    print(metrics)
                case .failure(let error):
                    print(error)
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }

    private func renderChart() {
        let headerView = StockDetailHeaderView(frame: CGRect(
            x: 0, y: 0, width: view.width, height: view.width * 0.7 + 100
        ))
        headerView.backgroundColor = .link
        tableView.tableHeaderView = headerView
    }

    private func fetchNews() {
        APIManager.shared.news(for: .company(symbol: symbol)) { [weak self] result in
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
}

// MARK: - Protocols
extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier) as? NewsStoryTableViewCell
        else { return UITableViewCell() }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView
        else { return nil }
        header.delegate = self
        header.configure(with: .init(
            title: symbol.uppercased(),
            shouldShowAddButton: !PersistanceManager.shared.watchListContains(symbol: symbol)
        ))
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        headerView.button.isHidden = true
        PersistanceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)

        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We've added \(companyName) to your Watchlist",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}
