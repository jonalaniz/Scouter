//
//  DateFormatter+FormatConversationDate.swift
//  Scouter
//
//  Created by Jon Alaniz on 11/14/24.
//

import Foundation

extension DateFormatter {
    static func formatConversationDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        guard let date = formatter.date(from: dateString) else {
            return ""
        }

        formatter.dateFormat = "MMMM d, h:mm a"

        return "\n- \(formatter.string(from: date))"
    }
}
