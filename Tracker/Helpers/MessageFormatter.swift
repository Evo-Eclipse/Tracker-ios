//
//  MessageFormatter.swift
//  Tracker
//
//  Created by Pavel Komarov on 13.08.2025.
//

import Foundation

struct MessageFormatter {
    static func characterLimitTemplate(_ count: Int) -> String {
        let format = NSLocalizedString("characterLimitTemplate", comment: "Character limit template with number")
        return String(format: format, count)
    }
}
