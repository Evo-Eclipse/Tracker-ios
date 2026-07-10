//
//  TrackerNewCategoryViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 09.07.2026.
//

import Foundation

protocol TrackerNewCategoryViewModelDelegate: AnyObject {
    func viewModelDidUpdateDoneButtonState(_ viewModel: TrackerNewCategoryViewModel, isEnabled: Bool)
    func viewModel(_ viewModel: TrackerNewCategoryViewModel, didCreateCategory category: String)
    func viewModel(_ viewModel: TrackerNewCategoryViewModel, didUpdateError isHidden: Bool)
}

final class TrackerNewCategoryViewModel {

    // MARK: - Public Properties

    weak var delegate: TrackerNewCategoryViewModelDelegate?

    private(set) var categoryName: String = ""

    // MARK: - Private Properties

    private let maxTitleLength = Validation.maxTitleLength

    // MARK: - Public Methods

    func setCategoryName(_ name: String) {
        if name.count > maxTitleLength {
            categoryName = String(name.prefix(maxTitleLength))
            delegate?.viewModel(self, didUpdateError: false)
        } else {
            categoryName = name
            delegate?.viewModel(self, didUpdateError: true)
        }
        updateDoneButtonState()
    }

    func createCategory() {
        guard !categoryName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let trimmedName = categoryName.trimmingCharacters(in: .whitespaces)
        delegate?.viewModel(self, didCreateCategory: trimmedName)
    }

    // MARK: - Private Methods

    private func updateDoneButtonState() {
        let isEnabled = !categoryName.trimmingCharacters(in: .whitespaces).isEmpty
        delegate?.viewModelDidUpdateDoneButtonState(self, isEnabled: isEnabled)
    }
}
