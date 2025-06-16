//
//  TimeFrame.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import Foundation

struct TimeFrame: Codable {
    let time: String?
    let friendly: String
    let latestReplyFrom: Person?
}
