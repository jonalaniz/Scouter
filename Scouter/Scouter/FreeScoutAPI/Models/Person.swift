//
//  Person.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/15/25.
//

import Foundation

/// Represents the type of person involved in an action or timestamp.
///
/// Used in fields like `Source.via` and `TimeFrame.latestReplyFrom`
/// to distinguish whether an event or origin was initiated by a customer or a user.
///
/// - Note: This enum conforms to `Codable` for easy JSON encoding and decoding.
enum Person: String, Codable {
    case customer
    case user
    case none = ""
}
