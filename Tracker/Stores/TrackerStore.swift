//
//  TrackerStore.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//

import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange(sectionChanges: [StoreSectionChange], objectChanges: [StoreObjectChange])
}

final class TrackerStore: NSObject {

    // MARK: - Public Properties

    weak var delegate: TrackerStoreDelegate?

    // MARK: - Private Properties

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private lazy var changeCollector: FetchedResultsChangeCollector = {
        let collector = FetchedResultsChangeCollector()
        collector.onChange = { [weak self] sectionChanges, objectChanges in
            guard let self else { return }
            self.delegate?.trackerStoreDidChange(sectionChanges: sectionChanges, objectChanges: objectChanges)
        }
        return collector
    }()
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        // Sort by category title then tracker title for stable grouping
        let sortCategory = NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortTitle = NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        request.sortDescriptors = [sortCategory, sortTitle]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil
        )
        frc.delegate = changeCollector
        return frc
    }()

    // MARK: - Initializers

    init(container: NSPersistentContainer) {
        self.container = container
        self.context = container.viewContext
        super.init()
        try? fetchedResultsController.performFetch()
    }

    // MARK: - Public Methods

    /// Creates a new tracker in the specified category
    /// - Parameters:
    ///   - tracker: The tracker to create
    ///   - categoryTitle: The title of the category to create the tracker in
    func createTracker(_ tracker: Tracker, in categoryTitle: String) {
        container.performBackgroundTask { [weak self] ctx in
            guard let self = self else { return }

            // Find or create category
            let cat = self.fetchOrCreateCategory(with: categoryTitle, in: ctx)

            // Create tracker
            let obj = TrackerCoreData(context: ctx)
            obj.id = tracker.id
            obj.title = tracker.title
            obj.emoji = tracker.emoji
            obj.category = cat
            obj.createdAt = tracker.createdAt
            do { obj.color = try tracker.color.toData() } catch { obj.color = Data() }
            do { obj.schedule = try tracker.schedule.toData() } catch { obj.schedule = Data() }

            do { try ctx.save() } catch { print("[TrackerStore] create error: \(error)") }
        }
    }

    /// Deletes a tracker by its ID
    /// - Parameter trackerId: The UUID of the tracker to delete
    func deleteTracker(trackerId: UUID) {
        container.performBackgroundTask { [weak self] ctx in
            guard let self = self else { return }

            guard let obj = self.fetchTracker(by: trackerId, in: ctx) else { return }
            ctx.delete(obj)
            do { try ctx.save() } catch { print("[TrackerStore] delete error: \(error)") }
        }
    }

    /// Updates an existing tracker with new values
    /// - Parameter tracker: The tracker with updated values
    func updateTracker(_ tracker: Tracker) {
        container.performBackgroundTask { [weak self] ctx in
            guard let self = self else { return }

            guard let obj = self.fetchTracker(by: tracker.id, in: ctx) else { return }
            obj.title = tracker.title
            obj.emoji = tracker.emoji
            do { obj.color = try tracker.color.toData() } catch {}
            do { obj.schedule = try tracker.schedule.toData() } catch {}
            // Move the tracker to a different category if it changed
            if !tracker.category.isEmpty, obj.category?.title != tracker.category {
                obj.category = self.fetchOrCreateCategory(with: tracker.category, in: ctx)
            }
            do { try ctx.save() } catch { print("[TrackerStore] update error: \(error)") }
        }
    }

    // MARK: - Read helpers for UI (no CoreData leakage)

    /// Returns the number of categories/sections
    func numberOfSections() -> Int { fetchedResultsController.sections?.count ?? 0 }

    /// Returns the number of trackers in a given section
    /// - Parameter section: The section index
    /// - Returns: Number of trackers in the section
    func numberOfItems(in section: Int) -> Int { fetchedResultsController.sections?[section].numberOfObjects ?? 0 }

    /// Returns the title for a given section
    /// - Parameter section: The section index
    /// - Returns: The category title for the section
    func titleForSection(_ section: Int) -> String { fetchedResultsController.sections?[section].name ?? "" }

    /// Returns the tracker at a specific index path
    /// - Parameter indexPath: The index path of the tracker
    /// - Returns: The Tracker domain model object
    func tracker(at indexPath: IndexPath) -> Tracker {
        let obj = fetchedResultsController.object(at: indexPath)
        return mapToDomain(obj)
    }

    /// Builds a filtered snapshot of trackers grouped by category for UI consumption
    /// - Parameters:
    ///   - date: The date to filter trackers by schedule
    ///   - searchText: Optional text to filter trackers by title
    ///   - filter: Optional filter type (all, today, completed, incomplete)
    ///   - recordStore: Optional store to check completion status
    /// - Returns: Array of TrackerCategory containing filtered trackers
    func snapshotFiltered(date: Date, searchText: String?, filter: TrackerFilter? = nil, recordStore: TrackerRecordStore? = nil) -> [TrackerCategory] {
        var result: [TrackerCategory] = []

        let sectionsCount = numberOfSections()
        for section in 0..<sectionsCount {
            let title = titleForSection(section)
            var trackers: [Tracker] = []
            let items = numberOfItems(in: section)

            for row in 0..<items {
                let candidate = tracker(at: IndexPath(item: row, section: section))
                if shouldIncludeTracker(candidate, date: date, searchText: searchText, filter: filter, recordStore: recordStore) {
                    trackers.append(candidate)
                }
            }

            if !trackers.isEmpty {
                result.append(TrackerCategory(title: title, trackers: trackers))
            }
        }

        return result
    }

    /// Checks if there are any trackers scheduled for a given date
    /// - Parameters:
    ///   - date: The date to check
    ///   - searchText: Optional text to filter trackers by title
    /// - Returns: True if any trackers exist for the date, false otherwise
    /// - Note: This method ignores completion status (only checks schedule and search)
    func hasTrackersOnDate(_ date: Date, searchText: String?) -> Bool {
        // Reuse snapshotFiltered logic but only check if any trackers match
        // Pass nil for filter and recordStore to skip completion filtering
        let sectionsCount = numberOfSections()
        for section in 0..<sectionsCount {
            let items = numberOfItems(in: section)
            for row in 0..<items {
                let candidate = tracker(at: IndexPath(item: row, section: section))
                if shouldIncludeTracker(candidate, date: date, searchText: searchText, filter: nil, recordStore: nil) {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Private Methods

    // Common logic for filtering trackers by date, search text, and completion status
    private func shouldIncludeTracker(_ tracker: Tracker, date: Date, searchText: String?, filter: TrackerFilter?, recordStore: TrackerRecordStore?) -> Bool {
        let calendar = Calendar.app
        let weekdayIndex = calendar.component(.weekday, from: date)
        let weekday = Weekday.fromSystemIndex(weekdayIndex)

        // Prepare case-insensitive search if provided
        let query = (searchText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        let hasQuery = !query.isEmpty

        // Filter by weekday schedule (empty schedule means every day)
        // Always respect selected date's weekday regardless of the current filter
        let matchesDay = tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
        if !matchesDay { return false }

        // Filter by search query
        if hasQuery, tracker.title.localizedStandardRange(of: query) == nil { return false }

        // Filter by completion state if requested
        if let filter = filter, let rs = recordStore {
            switch filter {
            case .all:
                break
            case .today:
                // Already constrained by date via weekday; include all
                break
            case .completed:
                if !rs.isCompleted(trackerId: tracker.id, on: date) { return false }
            case .incomplete:
                if rs.isCompleted(trackerId: tracker.id, on: date) { return false }
            }
        }

        return true
    }

    private func fetchOrCreateCategory(with title: String, in ctx: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "%K ==[cd] %@", #keyPath(TrackerCategoryCoreData.title), title)
        if let found = try? ctx.fetch(req).first { return found }
        let cat = TrackerCategoryCoreData(context: ctx)
        cat.title = title
        return cat
    }

    private func fetchTracker(by trackerId: UUID, in ctx: NSManagedObjectContext) -> TrackerCoreData? {
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "%K == %@", "id", trackerId as CVarArg)
        return try? ctx.fetch(req).first
    }

    private func mapToDomain(_ obj: TrackerCoreData) -> Tracker {
        let color: AppColor = {
            if let data = obj.color, let decoded = try? AppColor.fromData(data) { return decoded }
            return .black
        }()
        let schedule: [Weekday] = {
            if let data = obj.schedule, let decoded = try? [Weekday].fromData(data) { return decoded }
            return []
        }()
        return Tracker(id: obj.id ?? UUID(),
                       title: obj.title ?? "",
                       color: color,
                       emoji: obj.emoji ?? "",
                       schedule: schedule,
                       category: obj.category?.title ?? "",
                       createdAt: obj.createdAt ?? .distantPast)
    }

    /// Returns all trackers as domain models (unfiltered). Used for statistics.
    func allTrackers() -> [Tracker] {
        (fetchedResultsController.fetchedObjects ?? []).map { mapToDomain($0) }
    }
}
