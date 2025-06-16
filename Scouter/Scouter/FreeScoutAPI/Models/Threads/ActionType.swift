//
//  ActionType.swift
//  Scouter
//
//  Created by Jon Alaniz on 6/16/25.
//

import Foundation

enum ActionType: String, Codable {
    case statusChanged = "changed-ticket-status"
    case userChanged = "changed-ticket-assignee"
    case movedFromMailbox = "moved-from-mailbox"
    case merged
    case imported
    case importedExternal = "imported-external"
    case changedTicketCustomer = "changed-ticket-customer"
    case deletedTicket = "deleted-ticket"
    case restoreTicket = "restore-ticket"
    case other = ""
}
