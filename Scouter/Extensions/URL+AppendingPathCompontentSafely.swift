//
//  URL+AppendingPathCompontentSafely.swift
//  Scouter
//
//  Created by Jon Alaniz on 12/2/24.
//

import Foundation

extension URL {
    func appendingPathComponentSafely(_ component: String) -> URL {
        var finalPath = self.path
        if finalPath.hasSuffix("/") {
            finalPath.removeLast()
        }

        return self.appendingPathComponent(component)
    }
}
