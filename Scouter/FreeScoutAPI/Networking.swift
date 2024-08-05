//
//  Networking.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import Foundation

class Networking {
    static let shared = Networking()
    
    private init() {}

    func fetch(url: URL, APIKey: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(APIKey,
                         forHTTPHeaderField: "X-FreeScout-API-Key")
        request.addValue("application/json",
                         forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=UTF-8",
                         forHTTPHeaderField: "Content-Type")
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(for: request)
        
        guard let urlResponse = response as? HTTPURLResponse else {
            throw NetworkingError.invalidResponse
        }
        
        guard (200...299).contains(urlResponse.statusCode) else {
            if urlResponse.statusCode == 401 {
                throw NetworkingError.unauthorized
            }

            throw NetworkingError.invalidResponse
        }
        
        return data
    }
}

enum NetworkingError: Error {
    case invalidURL
    case noData
    case unableToDecode
    case invalidResponse
    case requestFailed
    case unauthorized
}
