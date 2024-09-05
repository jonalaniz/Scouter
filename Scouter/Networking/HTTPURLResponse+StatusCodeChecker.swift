//
//  HTTPURLResponse+StatusCodeChecker.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

extension HTTPURLResponse {
    func statusCodeChecker() throws {
        switch self.statusCode {
        case 200...299: return
        default:
            throw APIManagerError.invalidResponse(statuscode: self.statusCode)
        }
    }
}
