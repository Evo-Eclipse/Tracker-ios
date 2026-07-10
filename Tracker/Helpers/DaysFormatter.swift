//
//  DaysFormatter.swift
//  Tracker
//
//  Created by Pavel Komarov on 13.08.2025.
//

import Foundation

struct DaysFormatter {
    static func localizedDaysCount(_ count: Int) -> String {
        let format = NSLocalizedString("daysCount", comment: "Days count with pluralization")
        return String.localizedStringWithFormat(format, count)
    }

    /// Subtitle for a schedule row: `nil` when empty, "Every day" when all days are
    /// selected, otherwise a comma-separated list of short weekday names.
    static func scheduleSubtitle(for days: Set<Weekday>) -> String? {
        if days.isEmpty { return nil }
        if days.count == Weekday.allCases.count { return L10n.everyDaySchedule }
        return days.sorted { $0.rawValue < $1.rawValue }
            .map { $0.short }
            .joined(separator: ", ")
    }
}
