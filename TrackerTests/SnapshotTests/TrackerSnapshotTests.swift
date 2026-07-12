//
//  TrackerSnapshotTests.swift
//  Tracker
//
//  Created by Pavel Komarov on 14.08.2025.
//

import XCTest
import SnapshotTesting
import CoreData
@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {

    // MARK: - Configuration

    // Set to true to overwrite all reference snapshots
    private let shouldRecordSnapshots = false
    
    private var persistentContainer: NSPersistentContainer!
    private var trackerStore: TrackerStore!
    private var recordStore: TrackerRecordStore!
    private var categoryStore: TrackerCategoryStore!

    override func setUpWithError() throws {
        // Setup CoreData stack for tests
        persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        
        trackerStore = TrackerStore(container: persistentContainer)
        categoryStore = TrackerCategoryStore(container: persistentContainer)
        recordStore = TrackerRecordStore(container: persistentContainer)
    }

    override func tearDownWithError() throws {
        persistentContainer = nil
        trackerStore = nil
        recordStore = nil
        categoryStore = nil
    }

    func testTrackersViewControllerLightTheme() throws {
        let viewModel = TrackersViewModel(
            trackerStore: trackerStore,
            recordStore: recordStore,
            categoryStore: categoryStore
        )
        let viewController = TrackersViewController(viewModel: viewModel)
        viewController.overrideUserInterfaceStyle = .light
        
        // Trigger view lifecycle
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)

        withSnapshotTesting(record: shouldRecordSnapshots ? .all : .missing) {
            assertSnapshots(of: viewController, as: [
                .image(on: .iPhone12),
                .image(on: .iPhoneSe)
            ])
        }
    }

    func testTrackersViewControllerDarkTheme() throws {
        let viewModel = TrackersViewModel(
            trackerStore: trackerStore,
            recordStore: recordStore,
            categoryStore: categoryStore
        )
        let viewController = TrackersViewController(viewModel: viewModel)
        viewController.overrideUserInterfaceStyle = .dark
        
        // Trigger view lifecycle
        _ = viewController.view
        viewController.viewWillAppear(false)
        viewController.viewDidAppear(false)

        withSnapshotTesting(record: shouldRecordSnapshots ? .all : .missing) {
            assertSnapshots(of: viewController, as: [
                .image(on: .iPhone12),
                .image(on: .iPhoneSe)
            ])
        }
    }
}
