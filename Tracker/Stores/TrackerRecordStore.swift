//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    /// Called after completion records change (a tracker was marked complete/incomplete)
    func recordStoreDidChange()
}

protocol TrackerRecordStoreStatisticsDelegate: AnyObject {
    func recordStoreDidUpdateStatistics()
}

final class TrackerRecordStore: NSObject {

    // MARK: - Public Properties

    weak var delegate: TrackerRecordStoreDelegate?
    weak var statisticsDelegate: TrackerRecordStoreStatisticsDelegate?

    // MARK: - Private Properties

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    // MARK: - Initializers

    init(container: NSPersistentContainer) {
        self.container = container
        self.context = container.viewContext
        super.init()
    }

    // MARK: - Public Methods

    func isCompleted(trackerId: UUID, on date: Date) -> Bool {
        let normalized = Calendar.app.startOfDay(for: date)
        let trackerReq: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerReq.fetchLimit = 1
        trackerReq.predicate = NSPredicate(format: "%K == %@", "id", trackerId as CVarArg)
        guard let trackerObj = try? context.fetch(trackerReq).first else { return false }

        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.tracker), trackerObj,
            #keyPath(TrackerRecordCoreData.date), normalized as CVarArg
        )
        do { return try context.fetch(req).first != nil } catch { return false }
    }

    func toggle(trackerId: UUID, on date: Date) {
        let normalized = Calendar.app.startOfDay(for: date)

        container.performBackgroundTask { [weak self] ctx in
            guard let self = self else { return }

            // Fetch tracker object in this context
            let trackerReq: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            trackerReq.fetchLimit = 1
            trackerReq.predicate = NSPredicate(format: "%K == %@", "id", trackerId as CVarArg)
            guard let trackerObj = try? ctx.fetch(trackerReq).first else { return }

            // Check existing record
            let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            req.fetchLimit = 1
            req.predicate = NSPredicate(
                format: "%K == %@ AND %K == %@",
                #keyPath(TrackerRecordCoreData.tracker), trackerObj,
                #keyPath(TrackerRecordCoreData.date), normalized as CVarArg
            )
            if let existing = try? ctx.fetch(req).first {
                ctx.delete(existing)
            } else {
                let obj = TrackerRecordCoreData(context: ctx)
                obj.tracker = trackerObj
                obj.date = normalized
                obj.id = UUID()
            }
            do {
                try ctx.save()
                // Notify observers on the main thread
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.recordStoreDidChange()
                    self?.statisticsDelegate?.recordStoreDidUpdateStatistics()
                }
            } catch {
                print("[TrackerRecordStore] toggle error: \(error)")
            }
        }
    }

    func getCompletionCount(for trackerId: UUID) -> Int {
        let trackerReq: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        trackerReq.fetchLimit = 1
        trackerReq.predicate = NSPredicate(format: "%K == %@", "id", trackerId as CVarArg)
        guard let trackerObj = try? context.fetch(trackerReq).first else { return 0 }

        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.tracker), trackerObj)
        do { return try context.count(for: req) } catch { return 0 }
    }

    /// Returns all completion records as (trackerId, day-normalized date) pairs. Used for statistics.
    func allRecords() -> [(trackerId: UUID, date: Date)] {
        let req: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        guard let objs = try? context.fetch(req) else { return [] }
        let calendar = Calendar.app
        return objs.compactMap { obj in
            guard let date = obj.date, let trackerId = obj.tracker?.id else { return nil }
            return (trackerId, calendar.startOfDay(for: date))
        }
    }
}
