//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 09.07.2026.
//

import Foundation

/// Aggregated statistics for the Statistics screen
struct StatisticsData {
    /// Longest run of consecutive perfect days
    let bestPeriod: Int
    /// Number of days on which every scheduled tracker was completed
    let perfectDays: Int
    /// Total number of completion records
    let completedTrackers: Int
    /// Average number of trackers completed per active day
    let averageValue: Int

    static let empty = StatisticsData(bestPeriod: 0, perfectDays: 0, completedTrackers: 0, averageValue: 0)

    /// There is nothing to show until at least one tracker has been completed
    var isEmpty: Bool { completedTrackers == 0 }
}

/// Delegate protocol for StatisticsViewModel
protocol StatisticsViewModelDelegate: AnyObject {
    /// Called when the aggregated statistics change
    func viewModel(_ viewModel: StatisticsViewModel, didUpdate data: StatisticsData)

    /// Called when the hasData state changes
    /// - Parameter hasData: Whether there is any statistics data to display
    func viewModel(_ viewModel: StatisticsViewModel, didUpdateHasData hasData: Bool)
}

/// ViewModel for the Statistics screen
final class StatisticsViewModel {

    // MARK: - Properties

    /// The delegate to notify about changes
    weak var delegate: StatisticsViewModelDelegate?

    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    // MARK: - Initializers

    /// Creates a new StatisticsViewModel
    /// - Parameters:
    ///   - trackerStore: The store for accessing trackers (needed to resolve schedules)
    ///   - recordStore: The store for accessing tracker records
    init(trackerStore: TrackerStore, recordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        self.recordStore.statisticsDelegate = self
    }

    // MARK: - Public Methods

    /// Recomputes statistics and notifies the delegate
    func loadStatistics() {
        let data = calculateStatistics()
        delegate?.viewModel(self, didUpdate: data)
        delegate?.viewModel(self, didUpdateHasData: !data.isEmpty)
    }

    // MARK: - Private Methods

    private func calculateStatistics() -> StatisticsData {
        let records = recordStore.allRecords()
        let completedTrackers = records.count
        guard completedTrackers > 0 else { return .empty }

        let calendar = Calendar.app

        // Group the set of completed tracker ids by day
        var completionsByDay: [Date: Set<UUID>] = [:]
        for record in records {
            completionsByDay[record.date, default: []].insert(record.trackerId)
        }

        let trackers = trackerStore.allTrackers()

        // A "perfect day" is a day on which every tracker scheduled for that
        // weekday was completed (irregular events, with no schedule, count every day).
        var perfectDayDates: [Date] = []
        for (day, completedIds) in completionsByDay {
            let weekday = Weekday.fromSystemIndex(calendar.component(.weekday, from: day))
            // Only count trackers that already existed on that day and are scheduled for it
            let scheduledIds = trackers
                .filter { tracker in
                    calendar.startOfDay(for: tracker.createdAt) <= day
                        && (tracker.schedule.isEmpty || tracker.schedule.contains(weekday))
                }
                .map { $0.id }
            guard !scheduledIds.isEmpty else { continue }
            if scheduledIds.allSatisfy({ completedIds.contains($0) }) {
                perfectDayDates.append(day)
            }
        }

        let perfectDays = perfectDayDates.count
        let bestPeriod = longestConsecutiveRun(of: perfectDayDates, calendar: calendar)

        // Average trackers completed per day that has at least one completion
        let activeDays = completionsByDay.count
        let averageValue = activeDays > 0
            ? Int((Double(completedTrackers) / Double(activeDays)).rounded())
            : 0

        return StatisticsData(
            bestPeriod: bestPeriod,
            perfectDays: perfectDays,
            completedTrackers: completedTrackers,
            averageValue: averageValue
        )
    }

    /// Returns the length of the longest streak of consecutive calendar days
    private func longestConsecutiveRun(of dates: [Date], calendar: Calendar) -> Int {
        guard !dates.isEmpty else { return 0 }
        let sorted = dates.sorted()
        var longest = 1
        var current = 1
        for index in 1..<sorted.count {
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: sorted[index - 1]),
               calendar.isDate(nextDay, inSameDayAs: sorted[index]) {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
        }
        return longest
    }
}

// MARK: - TrackerRecordStoreStatisticsDelegate

extension StatisticsViewModel: TrackerRecordStoreStatisticsDelegate {
    func recordStoreDidUpdateStatistics() {
        loadStatistics()
    }
}
