//
//  String+Truncated.swift
//  Scouter
//
//  Created by Jon Alaniz on 7/6/24.
//

import Foundation

extension String {
    func truncated(_ count: Int) -> String {
        if self.count > count {
            return String(self.prefix(count))
        }
        
        return self
    }
}
