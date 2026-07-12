//
//  TrackerType.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import Foundation

enum TrackerType {
    case habit
    case irregularEvent

    var title: String {
        switch self {
        case .habit:
            return L10n.newHabitTitle
        case .irregularEvent:
            return L10n.newIrregularEventTitle
        }
    }

    var hasSchedule: Bool {
        switch self {
        case .habit:
            return true
        case .irregularEvent:
            return false
        }
    }
}
