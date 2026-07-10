//
//  Tracker.swift
//  Tracker
//
//  Created by Pavel Komarov on 28.07.2025.
//

import Foundation

struct Tracker: Hashable {
    let id: UUID
    let title: String
    let color: AppColor
    let emoji: String
    let schedule: [Weekday]
    let category: String
    let createdAt: Date

    init(id: UUID,
         title: String,
         color: AppColor,
         emoji: String,
         schedule: [Weekday],
         category: String = "",
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.category = category
        self.createdAt = createdAt
    }

    // Tracker is uniquely identified by its id
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Tracker, rhs: Tracker) -> Bool {
        lhs.id == rhs.id
    }
}
