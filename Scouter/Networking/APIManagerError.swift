//
//  APIManagerError.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

enum APIManagerError: Error {
    case configurationMissing
    case conversionFailedToHTTPURLResponse
    case invalidResponse(statuscode: Int)
    case invalidURL
    case serializaitonFailed
    case somethingWentWrong(error: Error?)
    
    var errorDescription: String {
        switch self {
        case .configurationMissing:
            return "Missing configuration data"
        case .conversionFailedToHTTPURLResponse:
            return "Typecasting failed."
        case .invalidResponse(let statuscode):
            return "Invalid Response (\(statuscode))"
        case .invalidURL:
            return "Invalid URL"
        case .serializaitonFailed:
            return "JSONSerialization Failed"
        case .somethingWentWrong(let error):
            return error?.localizedDescription ?? "Something went wrong"
        }
    }
}
