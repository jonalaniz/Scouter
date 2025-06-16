//
//  ThreadStatus.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/16/25.
//

import Foundation

enum ThreadStatus: String, Codable {
    case active
    case closed
    case nochange
    case pending
    case spam
}
