//
//  Calendar+App.swift
//  Tracker
//
//  Created by Pavel Komarov on 10.07.2026.
//

import Foundation

extension Calendar {
    /// Shared calendar instance used across the app for day-based comparisons.
    /// Avoids repeatedly constructing `Calendar.current` on hot paths
    /// (filtering, completion checks, statistics).
    static let app = Calendar.current
}
