//
//  CoreDataTestStack.swift
//  TrackerTests
//
//  Created by Pavel Komarov on 10.07.2026.
//

import CoreData
@testable import Tracker

/// In-memory CoreData stack and seeding helpers for unit tests.
enum CoreDataTestStack {

    static func makeInMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Tracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            precondition(error == nil, "Failed to load in-memory store: \(String(describing: error))")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }

    /// Seeds a tracker directly into the view context (synchronous, bypasses async store writes).
    @discardableResult
    static func seedTracker(in container: NSPersistentContainer,
                            id: UUID = UUID(),
                            title: String = "Tracker",
                            schedule: [Weekday],
                            createdAt: Date = .distantPast,
                            categoryTitle: String = "Category") -> UUID {
        let context = container.viewContext

        let category = fetchOrCreateCategory(title: categoryTitle, in: context)

        let tracker = TrackerCoreData(context: context)
        tracker.id = id
        tracker.title = title
        tracker.emoji = "🙂"
        tracker.color = Data()
        tracker.schedule = (try? schedule.toData()) ?? Data()
        tracker.createdAt = createdAt
        tracker.category = category

        try? context.save()
        return id
    }

    /// Seeds a completion record for the given tracker on the given day.
    static func seedRecord(in container: NSPersistentContainer, trackerId: UUID, date: Date) {
        let context = container.viewContext
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        guard let tracker = try? context.fetch(request).first else { return }

        let record = TrackerRecordCoreData(context: context)
        record.id = UUID()
        record.tracker = tracker
        record.date = Calendar.app.startOfDay(for: date)
        try? context.save()
    }

    private static func fetchOrCreateCategory(title: String, in context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "title == %@", title)
        if let existing = try? context.fetch(request).first { return existing }
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        return category
    }
}

/// Builds a concrete calendar date for deterministic tests.
func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = 12
    return Calendar.app.date(from: components)!
}
