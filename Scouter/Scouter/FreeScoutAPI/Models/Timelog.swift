//
//  Timelog.swift
//  Kami
//
//  Created by Jon Alaniz on 6/15/25.
//

import Foundation

// swiftlint:disable identifier_name
struct Timelog: Codable {
    let id: Int
    let coversationStatus: String
    let userId: Int
    let timeSpent: Int
    let paused: Bool
    let finished: Bool
    let createdAt: String
    let updatedAt: String
}
