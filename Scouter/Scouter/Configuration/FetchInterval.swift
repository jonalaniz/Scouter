//
//  FetchInterval.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import Foundation

enum FetchInterval: TimeInterval, CaseIterable, Codable {
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900
    case thirtyMinutes = 1800

    var title: String {
        switch self {
        case .oneMinute: return "Each Minute"
        case .fiveMinutes: return "Every Five Minutes"
        case .fifteenMinutes: return "Every Fifteen Minutes"
        case .thirtyMinutes: return "Every Thirty Minutes"
        }
    }
}
