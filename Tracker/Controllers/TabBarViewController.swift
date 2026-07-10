//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 24.07.2025.
//

import UIKit

final class TabBarViewController: UITabBarController {

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        setupViewControllers()
    }

    // MARK: - Private Methods

    private func setupTabBar() {
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupViewControllers() {
        // Get stores from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            assertionFailure("AppDelegate unavailable")
            return
        }

        let trackerStore = appDelegate.trackerStore
        let categoryStore = appDelegate.categoryStore
        let recordStore = appDelegate.recordStore

        // Create StatisticsViewController with ViewModel
        let statisticsViewModel = StatisticsViewModel(trackerStore: trackerStore, recordStore: recordStore)
        let statisticsViewController = StatisticsViewController(viewModel: statisticsViewModel)
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: L10n.statisticsTab,
            image: UIImage(systemName: "hare.fill"),  // hare
            selectedImage: UIImage(systemName: "hare.fill")
        )

        // Create TrackersViewController with ViewModel
        let trackersViewModel = TrackersViewModel(
            trackerStore: trackerStore,
            recordStore: recordStore,
            categoryStore: categoryStore
        )
        let trackersViewController = TrackersViewController(viewModel: trackersViewModel)
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: L10n.trackersTab,
            image: UIImage(systemName: "record.circle.fill"),  // record.circle
            selectedImage: UIImage(systemName: "record.circle.fill")
        )

        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
}
