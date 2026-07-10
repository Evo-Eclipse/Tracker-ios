//
//  TrackerScheduleSelectionViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 09.07.2026.
//

import Foundation

final class TrackerScheduleSelectionViewModel {

    // MARK: - Public Properties

    private(set) var selectedDays: Set<Weekday> = []

    // MARK: - Public Methods

    func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    func getWeekdays() -> [Weekday] {
        return Weekday.allCases
    }

    func isDaySelected(_ day: Weekday) -> Bool {
        return selectedDays.contains(day)
    }
}
