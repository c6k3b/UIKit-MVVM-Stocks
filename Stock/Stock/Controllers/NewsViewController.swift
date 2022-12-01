//  NewsViewController.swift
//  Created by aa on 11/30/22.

import UIKit

class NewsViewController: UIViewController {
    // MARK: - Properties
    private var type: Type

    lazy var tableView: UITableView = {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        return $0
    }(UITableView())

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

    }

    private func open(url: URL) {

    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
