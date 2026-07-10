//
//  FetchedResultsChangeCollector.swift
//  Tracker
//
//  Created by Pavel Komarov on 10.07.2026.
//

import CoreData

/// Reusable `NSFetchedResultsControllerDelegate` that batches section/object changes
/// and reports them through a single closure. Shared by the CoreData stores to avoid
/// duplicating the identical delegate plumbing.
final class FetchedResultsChangeCollector: NSObject, NSFetchedResultsControllerDelegate {

    /// Called at the end of a change batch with the accumulated changes.
    var onChange: (([StoreSectionChange], [StoreObjectChange]) -> Void)?

    private var sectionChanges: [StoreSectionChange] = []
    private var objectChanges: [StoreObjectChange] = []

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sectionChanges.removeAll()
        objectChanges.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: sectionChanges.append(.insert(sectionIndex))
        case .delete: sectionChanges.append(.delete(sectionIndex))
        default: break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let new = newIndexPath { objectChanges.append(.insert(new)) }
        case .delete:
            if let old = indexPath { objectChanges.append(.delete(old)) }
        case .update:
            if let idx = indexPath { objectChanges.append(.update(idx)) }
        case .move:
            if let old = indexPath, let new = newIndexPath { objectChanges.append(.move(from: old, to: new)) }
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange?(sectionChanges, objectChanges)
        sectionChanges.removeAll()
        objectChanges.removeAll()
    }
}
