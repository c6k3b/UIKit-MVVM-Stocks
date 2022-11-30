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
}

// MARK: - Private Helpers
private extension APIManager {
    enum Endpoint: String {
        case search
    }

    enum APIError: Error {
        case noDataReturned, invalidURL
    }

    struct Constants {
        static let apiKey = "ce3ou3aad3i1h2n7o7l0ce3ou3aad3i1h2n7o7lg"
        static let sandboxApiKey = ""
        static let baseUrl = "https://finnhub.io/api/v1/"
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
