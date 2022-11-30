//  APIManager.swift
//  Created by aa on 11/30/22.

import Foundation

final class APIManager {
    static let shared = APIManager()

    private init() {}
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
        static let apiKey = ""
        static let sandboxApiKey = ""
        static let basicUrl = ""
    }
}

// MARK: - Private Methods
private extension APIManager {
    func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        return nil
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
