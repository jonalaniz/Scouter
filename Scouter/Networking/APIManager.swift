//
//  APIManager.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

final class APIManager: Managable {
    public internal(set) var session = URLSession.shared
    
    static let shared: Managable = APIManager()
    
    private init() {}
    
    func request<T>(url: URL,
                    httpMethod: ServiceMethod,
                    body: Data?,
                    headers: [String : String]?,
                    expectingReturnType: T.Type
    ) async throws -> T where T : Decodable, T : Encodable {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        if let body = body, httpMethod != .get {
            request.httpBody = body
        }

        request.addHeaders(from: headers)
        
        
        
        return try await self.responseHandler(session.data(for: request))
    }
    
    func responseHandler<T: Codable>(_ dataWithResponse: (data: Data, response: URLResponse)) async throws -> T {
        guard let response = dataWithResponse.response as? HTTPURLResponse else {
            throw APIManagerError.conversionFailedToHTTPURLResponse
        }
        
        try response.statusCodeChecker()
                
        return try JSONDecoder().decode(T.self, from: dataWithResponse.data)
    }
}
