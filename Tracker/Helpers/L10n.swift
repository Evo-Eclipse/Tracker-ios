//
//  L10n.swift
//  Tracker
//
//  Created by Pavel Komarov on 13.08.2025.
//

import Foundation

enum L10n {
    // MARK: Buttons

    static let cancelButton = NSLocalizedString("cancelButton", comment: "Cancel button")
    static let createButton = NSLocalizedString("createButton", comment: "Create button")
    static let saveButton = NSLocalizedString("saveButton", comment: "Save button")
    static let doneButton = NSLocalizedString("doneButton", comment: "Done button")
    static let addCategoryButton = NSLocalizedString("addCategoryButton", comment: "Add category button")
    static let onboardingButton = NSLocalizedString("onboardingButton", comment: "Onboarding finish button")
    static let filtersButton = NSLocalizedString("filtersButton", comment: "Filters button")

    // MARK: Tracker Types

    static let habitType = NSLocalizedString("habitType", comment: "Habit tracker type")
    static let irregularEventType = NSLocalizedString("irregularEventType", comment: "Irregular event tracker type")
    static let newHabitTitle = NSLocalizedString("newHabitTitle", comment: "New habit title")
    static let newIrregularEventTitle = NSLocalizedString("newIrregularEventTitle", comment: "New irregular event title")

    // MARK: Navigation

    static let trackersTab = NSLocalizedString("trackersTab", comment: "Trackers tab title")
    static let statisticsTab = NSLocalizedString("statisticsTab", comment: "Statistics tab title")
    static let scheduleTitle = NSLocalizedString("scheduleTitle", comment: "Schedule title")
    static let categoryTitle = NSLocalizedString("categoryTitle", comment: "Category title")
    static let trackerCreationTitle = NSLocalizedString("trackerCreationTitle", comment: "Tracker creation title")
    static let newCategoryTitle = NSLocalizedString("newCategoryTitle", comment: "New category title")
    static let emojiSectionTitle = NSLocalizedString("emojiSectionTitle", comment: "Emoji section title")
    static let colorSectionTitle = NSLocalizedString("colorSectionTitle", comment: "Color section title")
    static let filtersTitle = NSLocalizedString("filtersTitle", comment: "Filters screen title")

    // MARK: Filter Options

    static let allTrackersFilter = NSLocalizedString("allTrackersFilter", comment: "All trackers filter option")
    static let todayTrackersFilter = NSLocalizedString("todayTrackersFilter", comment: "Today trackers filter option")
    static let completedTrackersFilter = NSLocalizedString("completedTrackersFilter", comment: "Completed trackers filter option")
    static let incompleteTrackersFilter = NSLocalizedString("incompleteTrackersFilter", comment: "Incomplete trackers filter option")

    // MARK: Placeholders

    static let trackerNamePlaceholder = NSLocalizedString("trackerNamePlaceholder", comment: "Tracker name input placeholder")
    static let categoryNamePlaceholder = NSLocalizedString("categoryNamePlaceholder", comment: "Category name input placeholder")
    static let searchPlaceholder = NSLocalizedString("searchPlaceholder", comment: "Search bar placeholder")

    // MARK: Days of Week (Full)

    static let mondayFull = NSLocalizedString("mondayFull", comment: "Monday")
    static let tuesdayFull = NSLocalizedString("tuesdayFull", comment: "Tuesday")
    static let wednesdayFull = NSLocalizedString("wednesdayFull", comment: "Wednesday")
    static let thursdayFull = NSLocalizedString("thursdayFull", comment: "Thursday")
    static let fridayFull = NSLocalizedString("fridayFull", comment: "Friday")
    static let saturdayFull = NSLocalizedString("saturdayFull", comment: "Saturday")
    static let sundayFull = NSLocalizedString("sundayFull", comment: "Sunday")

    // MARK: Days of Week (Short)

    static let mondayShort = NSLocalizedString("mondayShort", comment: "Monday short")
    static let tuesdayShort = NSLocalizedString("tuesdayShort", comment: "Tuesday short")
    static let wednesdayShort = NSLocalizedString("wednesdayShort", comment: "Wednesday short")
    static let thursdayShort = NSLocalizedString("thursdayShort", comment: "Thursday short")
    static let fridayShort = NSLocalizedString("fridayShort", comment: "Friday short")
    static let saturdayShort = NSLocalizedString("saturdayShort", comment: "Saturday short")
    static let sundayShort = NSLocalizedString("sundayShort", comment: "Sunday short")

    // MARK: Messages

    static let emptyTrackersMessage = NSLocalizedString("emptyTrackersMessage", comment: "Empty trackers state message")
    static let noSearchResultsMessage = NSLocalizedString("noSearchResultsMessage", comment: "No search results message")
    static let emptyStatisticsMessage = NSLocalizedString("emptyStatisticsMessage", comment: "Empty statistics state message")
    static let completedTrackersTitle = NSLocalizedString("completedTrackersTitle", comment: "Completed trackers statistics title")
    static let bestPeriodTitle = NSLocalizedString("bestPeriodTitle", comment: "Best period statistics title")
    static let perfectDaysTitle = NSLocalizedString("perfectDaysTitle", comment: "Perfect days statistics title")
    static let averageValueTitle = NSLocalizedString("averageValueTitle", comment: "Average value statistics title")
    static let onboardingFirstPage = NSLocalizedString("onboardingFirstPage", comment: "First onboarding page text")
    static let onboardingSecondPage = NSLocalizedString("onboardingSecondPage", comment: "Second onboarding page text")
    static let categoriesDescription = NSLocalizedString("categoriesDescription", comment: "Categories empty state description")
    static let characterLimitMessage = NSLocalizedString("characterLimitMessage", comment: "Character limit warning")
    static let everyDaySchedule = NSLocalizedString("everyDaySchedule", comment: "Every day schedule option")
    static let defaultCategoryName = NSLocalizedString("defaultCategoryName", comment: "Default category name")

    // MARK: Context menu

    static let editAction = NSLocalizedString("editAction", comment: "")
    static let deleteAction = NSLocalizedString("deleteAction", comment: "")
    static let deleteConfirmationTitle = NSLocalizedString("deleteConfirmationTitle", comment: "")
    static let editHabitTitle = NSLocalizedString("editHabitTitle", comment: "")
}
