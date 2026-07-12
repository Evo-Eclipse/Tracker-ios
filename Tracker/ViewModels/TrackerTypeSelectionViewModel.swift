//
//  TrackerTypeSelectionViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 09.07.2026.
//

import Foundation

final class TrackerTypeSelectionViewModel {

    // MARK: - Public Properties

    let categoryStore: TrackerCategoryStore

    // MARK: - Initializers

    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }

    // MARK: - Public Methods

    func createCreationFormViewModel(for trackerType: TrackerType) -> TrackerCreationFormViewModel {
        return TrackerCreationFormViewModel(
            trackerType: trackerType,
            categoryStore: categoryStore
        )
    }
}
