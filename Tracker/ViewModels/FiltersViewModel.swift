//
//  FiltersViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 09.07.2026.
//

import Foundation

/// Delegate protocol for FiltersViewModel
protocol FiltersViewModelDelegate: AnyObject {
    /// Called when a filter is selected
    /// - Parameter filter: The selected filter
    func filtersViewModel(_ viewModel: FiltersViewModel, didSelectFilter filter: TrackerFilter)
}

/// ViewModel for the Filters screen
final class FiltersViewModel {

    // MARK: - Properties

    /// The delegate to notify about filter selection
    weak var delegate: FiltersViewModelDelegate?

    private let selectedFilter: TrackerFilter

    // MARK: - Initializers

    /// Creates a new FiltersViewModel
    /// - Parameter selectedFilter: The currently selected filter
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
    }

    // MARK: - Public Methods

    /// Returns the number of available filters
    func numberOfFilters() -> Int {
        return TrackerFilter.allCases.count
    }

    /// Returns the filter at a given index
    /// - Parameter index: The index of the filter
    /// - Returns: The TrackerFilter at the specified index
    func filter(at index: Int) -> TrackerFilter {
        return TrackerFilter.allCases[index]
    }

    /// Returns the title for a given filter
    /// - Parameter filter: The filter to get the title for
    /// - Returns: The localized title string
    func title(for filter: TrackerFilter) -> String {
        switch filter {
        case .all: return L10n.allTrackersFilter
        case .today: return L10n.todayTrackersFilter
        case .completed: return L10n.completedTrackersFilter
        case .incomplete: return L10n.incompleteTrackersFilter
        }
    }

    /// Checks if a filter should show a checkmark
    /// - Parameter filter: The filter to check
    /// - Returns: True if the filter should show a checkmark (completed or incomplete)
    func shouldShowCheckmark(for filter: TrackerFilter) -> Bool {
        // Only completed and incomplete filters show checkmarks
        return filter == .completed || filter == .incomplete
    }

    /// Checks if a filter is currently selected (with checkmark)
    /// - Parameter filter: The filter to check
    /// - Returns: True if the filter is selected and should show checkmark
    func isSelected(withCheckmark filter: TrackerFilter) -> Bool {
        return filter == selectedFilter && shouldShowCheckmark(for: filter)
    }

    /// Checks if a filter is the first in the list
    /// - Parameter index: The index of the filter
    /// - Returns: True if the filter is the first
    func isFirstFilter(at index: Int) -> Bool {
        return index == 0
    }

    /// Checks if a filter is the last in the list
    /// - Parameter index: The index of the filter
    /// - Returns: True if the filter is the last
    func isLastFilter(at index: Int) -> Bool {
        return index == TrackerFilter.allCases.count - 1
    }

    /// Called when a filter is selected
    /// - Parameter index: The index of the selected filter
    func didSelectFilter(at index: Int) {
        let filter = filter(at: index)
        delegate?.filtersViewModel(self, didSelectFilter: filter)
    }
}
