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

    func name() -> String {
        var name = ""
        if let firstName = firstName {
            name += firstName
        }

        if let lastName = lastName {
            name += " " + lastName
        }

        if name == "" {
            name += email
        }

        return name
    }
}
