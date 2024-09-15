//
//  Endpoint.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/27/24.
//

import Foundation

enum Endpoint {
    case conversations
    case folders(Int)
    case mailbox
    
    var path: String {
        var endpoint: String
        
        switch self {
        case .conversations: endpoint = "/api/conversations"
        case .folders(let mailbox): endpoint = "/api/mailboxes/\(mailbox)/folders"
        case .mailbox: endpoint = "/api/mailboxes"
        }
        
        return endpoint
    }
}
