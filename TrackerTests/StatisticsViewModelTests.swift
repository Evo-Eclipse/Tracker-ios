//
//  StatisticsViewModelTests.swift
//  TrackerTests
//
//  Created by Pavel Komarov on 10.07.2026.
//

import XCTest
import CoreData
@testable import Tracker

final class StatisticsViewModelTests: XCTestCase {

    private var container: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        container = CoreDataTestStack.makeInMemoryContainer()
    }

    override func tearDown() {
        container = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeViewModel() -> (StatisticsViewModel, StatisticsSpy) {
        let trackerStore = TrackerStore(container: container)
        let recordStore = TrackerRecordStore(container: container)
        let viewModel = StatisticsViewModel(trackerStore: trackerStore, recordStore: recordStore)
        let spy = StatisticsSpy()
        viewModel.delegate = spy
        return (viewModel, spy)
    }

    // MARK: - Tests

    func testEmptyStateProducesZeros() {
        let (viewModel, spy) = makeViewModel()

        viewModel.loadStatistics()

        XCTAssertEqual(spy.data, .empty)
        XCTAssertEqual(spy.hasData, false)
    }

    func testCompletedCountEqualsRecords() {
        let everyDay = Weekday.allCases
        let id = CoreDataTestStack.seedTracker(in: container, schedule: everyDay)
        CoreDataTestStack.seedRecord(in: container, trackerId: id, date: makeDate(2024, 1, 1))
        CoreDataTestStack.seedRecord(in: container, trackerId: id, date: makeDate(2024, 1, 2))

        let (viewModel, spy) = makeViewModel()
        viewModel.loadStatistics()

        XCTAssertEqual(spy.data?.completedTrackers, 2)
        XCTAssertEqual(spy.hasData, true)
    }

    func testPerfectDaysAndBestPeriodForConsecutiveDays() {
        // Single every-day tracker completed on three consecutive days
        let id = CoreDataTestStack.seedTracker(in: container, schedule: Weekday.allCases)
        CoreDataTestStack.seedRecord(in: container, trackerId: id, date: makeDate(2024, 1, 1))
        CoreDataTestStack.seedRecord(in: container, trackerId: id, date: makeDate(2024, 1, 2))
        CoreDataTestStack.seedRecord(in: container, trackerId: id, date: makeDate(2024, 1, 3))

        let (viewModel, spy) = makeViewModel()
        viewModel.loadStatistics()

        XCTAssertEqual(spy.data?.perfectDays, 3)
        XCTAssertEqual(spy.data?.bestPeriod, 3)
        XCTAssertEqual(spy.data?.averageValue, 1)
    }

    func testBestPeriodPicksLongestStreak() {
        let id = CoreDataTestStack.seedTracker(in: container, schedule: Weekday.allCases)
        // Streak of 2 (Jan 1-2), gap, streak of 1 (Jan 5)
        [makeDate(2024, 1, 1), makeDate(2024, 1, 2), makeDate(2024, 1, 5)].forEach {
            CoreDataTestStack.seedRecord(in: container, trackerId: id, date: $0)
        }

        let (viewModel, spy) = makeViewModel()
        viewModel.loadStatistics()

        XCTAssertEqual(spy.data?.perfectDays, 3)
        XCTAssertEqual(spy.data?.bestPeriod, 2)
    }

    func testPartiallyCompletedDayIsNotPerfect() {
        // Two every-day trackers; both completed on day 1, only one on day 2
        let first = CoreDataTestStack.seedTracker(in: container, schedule: Weekday.allCases, categoryTitle: "A")
        let second = CoreDataTestStack.seedTracker(in: container, schedule: Weekday.allCases, categoryTitle: "A")
        CoreDataTestStack.seedRecord(in: container, trackerId: first, date: makeDate(2024, 1, 1))
        CoreDataTestStack.seedRecord(in: container, trackerId: second, date: makeDate(2024, 1, 1))
        CoreDataTestStack.seedRecord(in: container, trackerId: first, date: makeDate(2024, 1, 2))

        let (viewModel, spy) = makeViewModel()
        viewModel.loadStatistics()

        XCTAssertEqual(spy.data?.completedTrackers, 3)
        XCTAssertEqual(spy.data?.perfectDays, 1)      // only day 1 is perfect
        XCTAssertEqual(spy.data?.bestPeriod, 1)
        XCTAssertEqual(spy.data?.averageValue, 2)     // 3 completions over 2 active days -> rounded 2
    }

    func testTrackerCreatedAfterDayDoesNotBreakPastPerfectDays() {
        // Tracker A exists from the start and is completed on Jan 1.
        // Tracker B is created on Jan 2, so Jan 1 must still count as perfect.
        let trackerA = CoreDataTestStack.seedTracker(in: container,
                                                     schedule: Weekday.allCases,
                                                     createdAt: makeDate(2024, 1, 1),
                                                     categoryTitle: "A")
        CoreDataTestStack.seedTracker(in: container,
                                      schedule: Weekday.allCases,
                                      createdAt: makeDate(2024, 1, 2),
                                      categoryTitle: "A")
        CoreDataTestStack.seedRecord(in: container, trackerId: trackerA, date: makeDate(2024, 1, 1))

        let (viewModel, spy) = makeViewModel()
        viewModel.loadStatistics()

        XCTAssertEqual(spy.data?.perfectDays, 1)
    }
}

// MARK: - Spy

private final class StatisticsSpy: StatisticsViewModelDelegate {
    var data: StatisticsData?
    var hasData: Bool?

    func viewModel(_ viewModel: StatisticsViewModel, didUpdate data: StatisticsData) {
        self.data = data
    }

    func viewModel(_ viewModel: StatisticsViewModel, didUpdateHasData hasData: Bool) {
        self.hasData = hasData
    }
}

extension StatisticsData: Equatable {
    public static func == (lhs: StatisticsData, rhs: StatisticsData) -> Bool {
        lhs.bestPeriod == rhs.bestPeriod
            && lhs.perfectDays == rhs.perfectDays
            && lhs.completedTrackers == rhs.completedTrackers
            && lhs.averageValue == rhs.averageValue
    }
}
