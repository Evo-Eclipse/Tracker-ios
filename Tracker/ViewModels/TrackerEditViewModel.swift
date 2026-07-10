//
//  TrackerEditViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 09.07.2026.
//

import UIKit

protocol TrackerEditViewModelDelegate: AnyObject {
    func viewModelDidUpdateSaveButtonState(_ viewModel: TrackerEditViewModel, isEnabled: Bool)
    func viewModel(_ viewModel: TrackerEditViewModel, didUpdateTracker tracker: Tracker)
    func viewModel(_ viewModel: TrackerEditViewModel, didUpdateError isHidden: Bool)
    func viewModel(_ viewModel: TrackerEditViewModel, didUpdateDaysCount count: Int)
    func viewModelDidUpdateSelectedCategory(_ viewModel: TrackerEditViewModel, category: String)
    func viewModelDidUpdateSelectedSchedule(_ viewModel: TrackerEditViewModel, schedule: Set<Weekday>)
}

final class TrackerEditViewModel {

    // MARK: - Public Properties

    weak var delegate: TrackerEditViewModelDelegate?

    let originalTracker: Tracker
    let trackerType: TrackerType

    private(set) var title: String
    private(set) var selectedCategory: String
    private(set) var selectedSchedule: Set<Weekday>
    private(set) var selectedEmoji: String
    private(set) var selectedColor: UIColor

    // MARK: - Private Properties

    private let recordStore: TrackerRecordStore
    private let maxTitleLength = Validation.maxTitleLength

    // MARK: - Initializers

    init(tracker: Tracker, recordStore: TrackerRecordStore) {
        self.originalTracker = tracker
        // Irregular events are stored without a schedule; habits always have at least one day.
        self.trackerType = tracker.schedule.isEmpty ? .irregularEvent : .habit
        self.recordStore = recordStore

        self.title = tracker.title
        self.selectedEmoji = tracker.emoji
        self.selectedColor = UIColor(appColor: tracker.color)
        self.selectedSchedule = Set(tracker.schedule)
        self.selectedCategory = tracker.category.isEmpty ? L10n.defaultCategoryName : tracker.category
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
        updateSaveButtonState()
    }

    func setSelectedCategory(_ category: String) {
        selectedCategory = category
        delegate?.viewModelDidUpdateSelectedCategory(self, category: category)
        updateSaveButtonState()
    }

    func setSelectedSchedule(_ schedule: Set<Weekday>) {
        selectedSchedule = schedule
        delegate?.viewModelDidUpdateSelectedSchedule(self, schedule: schedule)
        updateSaveButtonState()
    }

    func setSelectedEmoji(_ emoji: String) {
        selectedEmoji = emoji
        updateSaveButtonState()
    }

    func setSelectedColor(_ color: UIColor) {
        selectedColor = color
        updateSaveButtonState()
    }

    func updateDaysCount() {
        let count = recordStore.getCompletionCount(for: originalTracker.id)
        delegate?.viewModel(self, didUpdateDaysCount: count)
    }

    func saveTracker() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        // Habits keep their selected days; irregular events are stored without a schedule.
        let schedule = trackerType.hasSchedule ? Array(selectedSchedule) : []

        let updatedTracker = Tracker(
            id: originalTracker.id,
            title: trimmedTitle,
            color: selectedColor.appColor,
            emoji: selectedEmoji,
            schedule: schedule,
            category: selectedCategory
        )

        delegate?.viewModel(self, didUpdateTracker: updatedTracker)
    }

    // MARK: - Private Methods

    private func updateSaveButtonState() {
        let hasTitle = !title.trimmingCharacters(in: .whitespaces).isEmpty
        let hasEmoji = !selectedEmoji.isEmpty
        let hasSchedule = !trackerType.hasSchedule || !selectedSchedule.isEmpty

        let isValid = hasTitle && hasEmoji && hasSchedule
        delegate?.viewModelDidUpdateSaveButtonState(self, isEnabled: isValid)
    }
}
