//
//  URLRequest+Headers.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

extension URLRequest {
    mutating func addHeaders(from headers: [String: String]? = nil) {
        guard let headers = headers, !headers.isEmpty else {
            self.defaultHeaders()
            return
        }
        
        for header in headers {
            self.addValue(header.value, forHTTPHeaderField: header.key)
        }
    }
    
    mutating func defaultHeaders() {
        self.addValue(
            HeaderKeyValue.jsonCharset.rawValue,
            forHTTPHeaderField: HeaderKeyValue.contentType.rawValue
        )
        
        self.addValue(
            HeaderKeyValue.applicationJSON.rawValue,
            forHTTPHeaderField: HeaderKeyValue.contentType.rawValue
        )
    }
}
