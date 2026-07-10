//
//  TrackerCreationFormViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 09.07.2026.
//

import UIKit

protocol TrackerCreationFormViewModelDelegate: AnyObject {
    func viewModelDidUpdateCreateButtonState(_ viewModel: TrackerCreationFormViewModel, isEnabled: Bool)
    func viewModelDidUpdateSelectedCategory(_ viewModel: TrackerCreationFormViewModel, category: String)
    func viewModelDidUpdateSelectedSchedule(_ viewModel: TrackerCreationFormViewModel, schedule: Set<Weekday>)
    func viewModel(_ viewModel: TrackerCreationFormViewModel, didCreateTracker tracker: Tracker, category: String)
    func viewModel(_ viewModel: TrackerCreationFormViewModel, didUpdateError isHidden: Bool)
}

final class TrackerCreationFormViewModel {

    // MARK: - Public Properties

    weak var delegate: TrackerCreationFormViewModelDelegate?
    let trackerType: TrackerType
    let categoryStore: TrackerCategoryStore

    private(set) var selectedCategory: String
    private(set) var selectedSchedule: Set<Weekday> = []
    private(set) var selectedEmoji: String?
    private(set) var selectedColor: UIColor?
    private(set) var title: String = ""

    // MARK: - Private Properties

    private let maxTitleLength = Validation.maxTitleLength

    // MARK: - Initializers

    init(trackerType: TrackerType, categoryStore: TrackerCategoryStore) {
        self.trackerType = trackerType
        self.categoryStore = categoryStore
        self.selectedCategory = L10n.defaultCategoryName
    }

    // MARK: - Public Methods

    func setTitle(_ title: String) {
        if title.count > maxTitleLength {
            self.title = String(title.prefix(maxTitleLength))
            delegate?.viewModel(self, didUpdateError: false)
        } else {
            self.title = title
            delegate?.viewModel(self, didUpdateError: true)
        }
        updateCreateButtonState()
    }

    func setSelectedCategory(_ category: String) {
        selectedCategory = category
        delegate?.viewModelDidUpdateSelectedCategory(self, category: category)
        updateCreateButtonState()
    }

    func setSelectedSchedule(_ schedule: Set<Weekday>) {
        selectedSchedule = schedule
        delegate?.viewModelDidUpdateSelectedSchedule(self, schedule: schedule)
        updateCreateButtonState()
    }

    func setSelectedEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateCreateButtonState()
    }

    func setSelectedColor(_ color: UIColor) {
        selectedColor = color
        updateCreateButtonState()
    }

    func createTracker() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              let emoji = selectedEmoji,
              let uiColor = selectedColor
        else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        // Habits store their selected days; irregular events are stored without a schedule.
        let schedule = trackerType.hasSchedule ? Array(selectedSchedule) : []

        let newTracker = Tracker(
            id: UUID(),
            title: trimmedTitle,
            color: uiColor.appColor,
            emoji: emoji,
            schedule: schedule,
            category: selectedCategory
        )

        delegate?.viewModel(self, didCreateTracker: newTracker, category: selectedCategory)
    }

    // MARK: - Private Methods

    private func updateCreateButtonState() {
        let isTitleValid = !title.trimmingCharacters(in: .whitespaces).isEmpty
        let isScheduleSelected = trackerType.hasSchedule ? !selectedSchedule.isEmpty : true
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil

        let isEnabled = isTitleValid && isScheduleSelected && isEmojiSelected && isColorSelected
        delegate?.viewModelDidUpdateCreateButtonState(self, isEnabled: isEnabled)
    }
}
