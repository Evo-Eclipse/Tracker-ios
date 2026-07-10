//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Pavel Komarov on 28.07.2025.
//

struct TrackerCategory: Hashable {
    let title: String
    let trackers: [Tracker]

    // TrackerCategory is uniquely identified by its title
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.title == rhs.title
    }
}
