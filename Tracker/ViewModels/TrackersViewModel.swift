//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 09.07.2026.
//

import Foundation

/// Represents the type of placeholder to display
enum TrackersPlaceholderType {
    case empty
    case nothingFound
    case none
}

/// Delegate protocol for TrackersViewModel
protocol TrackersViewModelDelegate: AnyObject {
    /// Called when visible categories are updated
    /// - Parameter categories: The updated array of tracker categories
    func viewModel(_ viewModel: TrackersViewModel, didUpdateCategories categories: [TrackerCategory])

    /// Called when the hasTrackers state changes
    /// - Parameter hasTrackers: Whether there are any trackers for the current date
    func viewModel(_ viewModel: TrackersViewModel, didUpdateHasTrackers hasTrackers: Bool)

    /// Called when the placeholder type changes
    /// - Parameter type: The new placeholder type to display
    func viewModel(_ viewModel: TrackersViewModel, didUpdatePlaceholder type: TrackersPlaceholderType)

    /// Called when the current date changes
    /// - Parameter date: The new current date
    func viewModel(_ viewModel: TrackersViewModel, didUpdateDate date: Date)
}

/// ViewModel for the Trackers screen
final class TrackersViewModel {

    // MARK: - Properties

    /// The delegate to notify about changes
    weak var delegate: TrackersViewModelDelegate?

    let trackerStore: TrackerStore
    let recordStore: TrackerRecordStore
    let categoryStore: TrackerCategoryStore

    private let userStore: UserStore
    private var currentDate: Date = Date()
    private var currentFilter: TrackerFilter
    private var searchText: String?

    // MARK: - Initializers

    /// Creates a new TrackersViewModel
    /// - Parameters:
    ///   - trackerStore: The store for accessing trackers
    ///   - recordStore: The store for accessing tracker records
    ///   - categoryStore: The store for accessing tracker categories
    init(trackerStore: TrackerStore,
         recordStore: TrackerRecordStore,
         categoryStore: TrackerCategoryStore,
         userStore: UserStore = .shared) {
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        self.categoryStore = categoryStore
        self.userStore = userStore
        self.currentFilter = userStore.currentFilter  // Restore the last-used filter
        self.trackerStore.delegate = self
        self.recordStore.delegate = self
    }

    // MARK: - Public Methods

    /// Sets the current date and refreshes visible trackers
    /// - Parameter date: The new date to filter by
    func setDate(_ date: Date) {
        currentDate = date
        filterVisibleTrackers()
    }

    /// Sets the search text and refreshes visible trackers
    /// - Parameter text: The new search text (nil to clear)
    func setSearchText(_ text: String?) {
        searchText = text
        filterVisibleTrackers()
    }

    /// Sets the current filter and refreshes visible trackers
    /// - Parameter filter: The new filter to apply
    func setFilter(_ filter: TrackerFilter) {
        currentFilter = filter
        userStore.currentFilter = filter  // Persist the selection across launches
        if filter == .today {
            currentDate = Date()
            delegate?.viewModel(self, didUpdateDate: currentDate)
        }
        filterVisibleTrackers()
    }

    /// Toggles the completion status of a tracker
    /// - Parameters:
    ///   - tracker: The tracker to toggle
    ///   - date: The date to toggle for
    func toggleTracker(_ tracker: Tracker, on date: Date) {
        recordStore.toggle(trackerId: tracker.id, on: date)
    }

    /// Creates a new tracker in the specified category
    /// - Parameters:
    ///   - tracker: The tracker to create
    ///   - category: The category title to create the tracker in
    func createTracker(_ tracker: Tracker, in category: String) {
        trackerStore.createTracker(tracker, in: category)
    }

    /// Updates an existing tracker
    /// - Parameter tracker: The tracker with updated values
    func updateTracker(_ tracker: Tracker) {
        trackerStore.updateTracker(tracker)
    }

    /// Deletes a tracker by its ID
    /// - Parameter id: The UUID of the tracker to delete
    func deleteTracker(id: UUID) {
        trackerStore.deleteTracker(trackerId: id)
    }

    /// Returns the current date
    func getCurrentDate() -> Date {
        return currentDate
    }

    /// Returns the current filter
    func getCurrentFilter() -> TrackerFilter {
        return currentFilter
    }

    /// Returns the completion count for a given tracker ID
    /// - Parameter trackerId: The UUID of the tracker
    /// - Returns: The number of times the tracker has been completed
    func getCompletionCount(for trackerId: UUID) -> Int {
        return recordStore.getCompletionCount(for: trackerId)
    }

    /// Checks if a tracker is completed on a given date
    /// - Parameters:
    ///   - trackerId: The UUID of the tracker
    ///   - date: The date to check
    /// - Returns: True if the tracker is completed on the date
    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        return recordStore.isCompleted(trackerId: trackerId, on: date)
    }

    // MARK: - Private Methods

    private func filterVisibleTrackers() {
        let categories = trackerStore.snapshotFiltered(
            date: currentDate,
            searchText: searchText,
            filter: currentFilter,
            recordStore: recordStore
        )

        let hasTrackers = trackerStore.hasTrackersOnDate(currentDate, searchText: searchText)

        let placeholderType: TrackersPlaceholderType = {
            if categories.isEmpty {
                let isFiltered = currentFilter != .all || !(searchText?.isEmpty ?? true)
                return isFiltered ? .nothingFound : .empty
            }
            return .none
        }()

        delegate?.viewModel(self, didUpdateCategories: categories)
        delegate?.viewModel(self, didUpdateHasTrackers: hasTrackers)
        delegate?.viewModel(self, didUpdatePlaceholder: placeholderType)
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewModel: TrackerStoreDelegate {
    func trackerStoreDidChange(sectionChanges: [StoreSectionChange], objectChanges: [StoreObjectChange]) {
        filterVisibleTrackers()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewModel: TrackerRecordStoreDelegate {
    func recordStoreDidChange() {
        // Re-run filtering so completed/incomplete filters and completion state stay in sync
        filterVisibleTrackers()
    }
}
