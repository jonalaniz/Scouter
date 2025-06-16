//
//  User.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/29/24.
//

import Foundation

// swiftlint:disable identifier_name
struct User: Codable {
    let id: Int
    let role: String
    let firstName: String?
    let lastName: String?
    let photoUrl: String?
    let email: String

    var displayName: String {
        let fullName = [firstName, lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return fullName.isEmpty ? email : fullName
    }
}
