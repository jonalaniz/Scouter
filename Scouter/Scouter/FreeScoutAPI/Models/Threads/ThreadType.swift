//
//  ThreadType.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/16/25.
//

import Foundation

enum ThreadType: String, Codable {
    case customer
    case message
    case note
    case lineitem
    case phone
    case forwardparent
    case forwardchild
}
