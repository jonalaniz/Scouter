//
//  CustomField.swift
//  Kami
//
//  Created by Jon Alaniz on 6/15/25.
//

import Foundation

struct CustomField: Codable {
    let id: Int
    let value: String

    let name, text: String
}

struct CustomFieldRequest: Encodable {
    let id: Int
    let value: String
}
