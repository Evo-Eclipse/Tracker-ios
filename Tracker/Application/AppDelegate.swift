//
//  AppDelegate.swift
//  Tracker
//
//  Created by Pavel Komarov on 07.07.2025.
//

import UIKit
import CoreData
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if let configuration = AppMetricaConfiguration(apiKey: "0dd49635-0d93-42ab-ae72-650cb95c9d84") {
            AppMetrica.activate(with: configuration)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    // MARK: - Stores

    /// Shared tracker store instance for managing trackers
    lazy var trackerStore: TrackerStore = {
        TrackerStore(container: persistentContainer)
    }()

    /// Shared category store instance for managing tracker categories
    lazy var categoryStore: TrackerCategoryStore = {
        TrackerCategoryStore(container: persistentContainer)
    }()

    /// Shared record store instance for managing tracker completion records
    lazy var recordStore: TrackerRecordStore = {
        TrackerRecordStore(container: persistentContainer)
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
