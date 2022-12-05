//  StockDetailsViewController.swift
//  Created by aa on 11/30/22.

import UIKit
import SafariServices

final class StockDetailsViewController: UIViewController {
    // MARK: - Properties
    private let symbol: String
    private let companyName: String
    private var candleStickData: [CandleStick]

    private var stories = [NewsStory]()
    private var metrics: Metrics?

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
}

// MARK: - Private Methods
private extension StockDetailsViewController {
    func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
    }

    @objc func didTapClose() {
        dismiss(animated: true)
    }

    func fetchFinancialData() {
        let group = DispatchGroup()

        if candleStickData.isEmpty {
            group.enter()
            APIManager.shared.getMarketData(for: symbol) { [weak self] result in
                defer { group.leave() }
                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }

        group.enter()
        APIManager.shared.getFinancialMetrics(for: symbol) { [weak self] result in
            defer { group.leave() }

            switch result {
            case .success(let response):
                self?.metrics = response.metric
            case .failure(let error):
                print(error)
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }

    func renderChart() {
        let headerView = StockDetailHeaderView(frame: CGRect(
            x: 0, y: 0, width: view.width, height: view.width * 0.7 + 100
        ))

        var viewModels = [MetricCollectionViewCell.ViewModel]()

        if let metrics = metrics {
            viewModels.append(.init(name: "52W High", value: "\(metrics.annualWeekHigh)"))
            viewModels.append(.init(name: "52W Low", value: "\(metrics.annualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metrics.annualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metrics.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metrics.tenDayAverageTradingVolume)"))
        }

        let changePercentage = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(
            chartViewModel: .init(
                data: candleStickData.reversed().map { $0.close },
                showLegend: true,
                showAxis: true,
                fillColor: changePercentage < 0 ? .systemRed : .systemGreen
            ),
            metricViewModels: viewModels
        )

        tableView.tableHeaderView = headerView
    }

    func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: { !Calendar.current.isDate($0.date, inSameDayAs: latestDate) })?.close
        else { return 0 }

        let difference = 1 - priorClose / latestClose
        return difference
    }

    func fetchNews() {
        APIManager.shared.getNews(for: .company(symbol: symbol)) { [weak self] result in
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

// MARK: - Delegates
extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NewsStoryTableViewCell.identifier
        ) as? NewsStoryTableViewCell
        else { return UITableViewCell() }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: NewsHeaderView.identifier
        ) as? NewsHeaderView
        else { return nil }
        header.delegate = self
        header.configure(with: .init(
            title: symbol.uppercased(),
            shouldShowAddButton: !PersistanceManager.shared.isWatchlistContains(symbol: symbol)
        ))
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let url = URL(string: stories[indexPath.row].url) else { return }

        HapticsManager.shared.vibrateForSelection()

        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true)
    }
}

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        HapticsManager.shared.vibrate(for: .success)
        
        headerView.button.isHidden = true
        PersistanceManager.shared.addToWatchlist(symbol: symbol, companyName: companyName)

        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We've added \(companyName) to your Watchlist",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}
