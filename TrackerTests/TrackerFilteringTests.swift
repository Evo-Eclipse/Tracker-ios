//
//  TrackerFilteringTests.swift
//  TrackerTests
//
//  Created by Pavel Komarov on 10.07.2026.
//

import XCTest
import CoreData
@testable import Tracker

final class TrackerFilteringTests: XCTestCase {

    private var container: NSPersistentContainer!

    // 2024-01-01 is a Monday, 2024-01-02 a Tuesday
    private let monday = makeDate(2024, 1, 1)
    private let tuesday = makeDate(2024, 1, 2)

    override func setUp() {
        super.setUp()
        container = CoreDataTestStack.makeInMemoryContainer()
    }

    override func tearDown() {
        container = nil
        super.tearDown()
    }

    private func allTrackers(_ categories: [TrackerCategory]) -> [Tracker] {
        categories.flatMap { $0.trackers }
    }

    // MARK: - Schedule

    func testTrackerShownOnScheduledWeekday() {
        CoreDataTestStack.seedTracker(in: container, title: "Monday habit", schedule: [.monday])
        let store = TrackerStore(container: container)

        let onMonday = store.snapshotFiltered(date: monday, searchText: nil)
        let onTuesday = store.snapshotFiltered(date: tuesday, searchText: nil)

        XCTAssertEqual(allTrackers(onMonday).count, 1)
        XCTAssertTrue(allTrackers(onTuesday).isEmpty)
    }

    func testEmptyScheduleShownEveryDay() {
        CoreDataTestStack.seedTracker(in: container, title: "Irregular", schedule: [])
        let store = TrackerStore(container: container)

        XCTAssertEqual(allTrackers(store.snapshotFiltered(date: monday, searchText: nil)).count, 1)
        XCTAssertEqual(allTrackers(store.snapshotFiltered(date: tuesday, searchText: nil)).count, 1)
    }

    // MARK: - Search

    func testSearchFiltersByTitle() {
        CoreDataTestStack.seedTracker(in: container, title: "Drink water", schedule: [])
        CoreDataTestStack.seedTracker(in: container, title: "Read a book", schedule: [], categoryTitle: "B")
        let store = TrackerStore(container: container)

        let result = store.snapshotFiltered(date: monday, searchText: "water")

        XCTAssertEqual(allTrackers(result).map { $0.title }, ["Drink water"])
    }

    func testSearchIsCaseInsensitive() {
        CoreDataTestStack.seedTracker(in: container, title: "Drink water", schedule: [])
        let store = TrackerStore(container: container)

        XCTAssertEqual(allTrackers(store.snapshotFiltered(date: monday, searchText: "WATER")).count, 1)
    }

    // MARK: - Completion filters

    func testCompletedAndIncompleteFilters() {
        let completedId = CoreDataTestStack.seedTracker(in: container, title: "Done", schedule: [], categoryTitle: "A")
        CoreDataTestStack.seedTracker(in: container, title: "Not done", schedule: [], categoryTitle: "A")
        CoreDataTestStack.seedRecord(in: container, trackerId: completedId, date: monday)

        let store = TrackerStore(container: container)
        let recordStore = TrackerRecordStore(container: container)

        let completed = store.snapshotFiltered(date: monday, searchText: nil, filter: .completed, recordStore: recordStore)
        let incomplete = store.snapshotFiltered(date: monday, searchText: nil, filter: .incomplete, recordStore: recordStore)

        XCTAssertEqual(allTrackers(completed).map { $0.title }, ["Done"])
        XCTAssertEqual(allTrackers(incomplete).map { $0.title }, ["Not done"])
    }

    func testAllFilterReturnsEverythingScheduled() {
        CoreDataTestStack.seedTracker(in: container, title: "One", schedule: [], categoryTitle: "A")
        CoreDataTestStack.seedTracker(in: container, title: "Two", schedule: [], categoryTitle: "A")
        let store = TrackerStore(container: container)
        let recordStore = TrackerRecordStore(container: container)

        let result = store.snapshotFiltered(date: monday, searchText: nil, filter: .all, recordStore: recordStore)

        XCTAssertEqual(allTrackers(result).count, 2)
    }
}
