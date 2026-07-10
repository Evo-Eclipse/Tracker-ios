//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func categoryStoreDidChange(sectionChanges: [StoreSectionChange], objectChanges: [StoreObjectChange])
}

final class TrackerCategoryStore: NSObject {

    // MARK: - Public Properties

    weak var delegate: TrackerCategoryStoreDelegate?

    // MARK: - Private Properties

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private lazy var changeCollector: FetchedResultsChangeCollector = {
        let collector = FetchedResultsChangeCollector()
        collector.onChange = { [weak self] sectionChanges, objectChanges in
            guard let self else { return }
            self.delegate?.categoryStoreDidChange(sectionChanges: sectionChanges, objectChanges: objectChanges)
        }
        return collector
    }()
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
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

    func createCategory(title: String) {
        container.performBackgroundTask { [weak self] ctx in
            guard let self = self else { return }

            if let _ = self.fetchCategory(title: title, in: ctx) { return }  // If category exists, do nothing
            let cat = TrackerCategoryCoreData(context: ctx)
            cat.title = title
            do { try ctx.save() } catch { print("[CategoryStore] save error: \(error)") }
        }
    }

    func deleteCategory(title: String) {
        container.performBackgroundTask { [weak self] ctx in
            guard let self = self else { return }

            guard let cat = self.fetchCategory(title: title, in: ctx) else { return }
            // Don't orphan trackers: refuse to delete a category that still has trackers
            guard (cat.trackers?.count ?? 0) == 0 else { return }
            ctx.delete(cat)
            do { try ctx.save() } catch { print("[CategoryStore] delete error: \(error)") }
        }
    }

    /// Returns all category titles (domain-friendly, no CoreData leakage)
    func getAllCategories() -> [String] {
        return (fetchedResultsController.fetchedObjects ?? []).compactMap { $0.title }
    }

    // MARK: - Private Methods

    private func fetchCategory(title: String, in ctx: NSManagedObjectContext) -> TrackerCategoryCoreData? {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "%K ==[cd] %@", #keyPath(TrackerCategoryCoreData.title), title)
        return try? ctx.fetch(req).first
    }
}
