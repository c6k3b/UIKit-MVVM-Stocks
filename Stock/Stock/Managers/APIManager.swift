//  APIManager.swift
//  Created by aa on 11/30/22.

import Foundation

final class APIManager {
    static let shared = APIManager()

    private init() {}

    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(
            url: url(for: .search, queryParams: ["q": safeQuery]),
            expectation: SearchResponse.self,
            completion: completion
        )
    }

    public func news(
        for type: NewsViewController.`Type`,
        completion: @escaping (Result<[NewsStory], Error>) -> Void
    ){
        switch type {
            case .topStories:
                request(
                    url: url(for: .topStories, queryParams: ["category": "general"]),
                    expectation: [NewsStory].self,
                    completion: completion
                )
            case .company(let symbol):
                let today = Date()
                let oneWeekBack = today.addingTimeInterval(-Constants.day * 7)
                request(
                    url: url(
                        for: .companyNews,
                        queryParams: [
                            "symbol": symbol,
                            "from":  DateFormatter.newsDateFormatter.string(from: oneWeekBack),
                            "to": DateFormatter.newsDateFormatter.string(from: today)
                        ]
                    ),
                    expectation: [NewsStory].self,
                    completion: completion
                )
        }
    }

    public func marketData(
        for symbol: String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping (Result<MarketDataResponse, Error>) -> Void
    ) {
        let today = Date()
        let prior = today.addingTimeInterval(-Constants.day * numberOfDays)
        request(
            url: url(
                for: .marketData,
                queryParams: [
                    "symbol": symbol,
                    "resolution": "1",
                    "from": "\(Int(prior.timeIntervalSince1970))",
                    "to": "\(Int(today.timeIntervalSince1970))"
                ]
            ),
            expectation: MarketDataResponse.self,
            completion: completion
        )
    }
}

// MARK: - Private Helpers
private extension APIManager {
    enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
    }

    enum APIError: Error {
        case noDataReturned, invalidURL
    }

    struct Constants {
        static let apiKey = "ce3ou3aad3i1h2n7o7l0ce3ou3aad3i1h2n7o7lg"
        static let sandboxApiKey = ""
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
}

// MARK: - Private Methods
private extension APIManager {
    func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        var queryItems = [URLQueryItem]()
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        print("\n\(urlString)\n")
        return URL(string: urlString)
    }

    func request<T: Codable>(url: URL?, expectation: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = url else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(APIError.noDataReturned))
                }
                return
            }
            do {
                let result = try JSONDecoder().decode(expectation, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
