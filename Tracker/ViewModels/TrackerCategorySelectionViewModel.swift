//
//  TrackerCategorySelectionViewModel.swift
//  Tracker
//
//  Created by Pavel Komarov on 12.08.2025.
//

import Foundation

final class TrackerCategorySelectionViewModel {

    // MARK: - Public Properties

    var onCategoriesChanged: (() -> Void)?
    var onSelectedCategoryChanged: ((String?) -> Void)?

    private(set) var selectedCategory: String? {
        didSet {
            onSelectedCategoryChanged?(selectedCategory)
        }
    }

    // MARK: - Public Properties

    let categoryStore: TrackerCategoryStore

    // MARK: - Private Properties

    private var categories: [TrackerCategory] = []

    // MARK: - Initializers

    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        self.categoryStore.delegate = self
        loadCategories()
    }

    // MARK: - Public Methods

    var numberOfCategories: Int {
        return categories.count
    }

    var isEmpty: Bool {
        return categories.isEmpty
    }

    func categoryTitle(at index: Int) -> String {
        guard let category = category(at: index) else { return "" }
        return category.title
    }

    func isSelected(at index: Int) -> Bool {
        let categoryTitle = categoryTitle(at: index)
        return categoryTitle == selectedCategory
    }

    func selectCategory(at index: Int) {
        let categoryTitle = categoryTitle(at: index)
        selectedCategory = categoryTitle
    }

    func addCategory(title: String) {
        categoryStore.createCategory(title: title)
        selectedCategory = title
    }

    // MARK: - Private Methods

    private func loadCategories() {
        self.categories = categoryStore.getAllCategories().map { title in
            TrackerCategory(title: title, trackers: [])  // Trackers are not needed for category list
        }
        onCategoriesChanged?()
    }

    private func category(at index: Int) -> TrackerCategory? {
        guard index >= 0 && index < categories.count else { return nil }
        return categories[index]
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension TrackerCategorySelectionViewModel: TrackerCategoryStoreDelegate {
    func categoryStoreDidChange(sectionChanges: [StoreSectionChange], objectChanges: [StoreObjectChange]) {
        loadCategories()
    }
}
