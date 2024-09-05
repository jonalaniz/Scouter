//
//  Error+Description.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/1/24.
//

import Foundation

extension Error {
    var description: String {
        ((self as? APIManagerError)?.errorDescription) ?? self.localizedDescription
    }
}
