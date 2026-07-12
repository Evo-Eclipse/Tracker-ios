//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Pavel Komarov on 14.08.2025.
//

import Foundation
import AppMetricaCore

final class AnalyticsService {

    // MARK: - Public properties

    static let shared = AnalyticsService()

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Properties

    enum EventType: String {
        case open = "open"
        case close = "close"
        case click = "click"
    }

    enum Screen: String {
        case main = "Main"
        case statistics = "Statistics"
    }

    enum Item: String {
        case addTrack = "add_track"
        case track = "track"
        case filter = "filter"
        case edit = "edit"
        case delete = "delete"
    }

    // MARK: - Public Methods

    func report(event: String, parameters: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: event, parameters: parameters, onFailure: { error in
            print("REPORT ERROR: \(error.localizedDescription)")
        })

        print("Analytics Event: \(event), Parameters: \(parameters)")
    }

    func reportScreenOpen(screen: Screen) {
        let params: [AnyHashable: Any] = [
            "event": EventType.open.rawValue,
            "screen": screen.rawValue
        ]
        report(event: "screen_open", parameters: params)
    }

    func reportScreenClose(screen: Screen) {
        let params: [AnyHashable: Any] = [
            "event": EventType.close.rawValue,
            "screen": screen.rawValue
        ]
        report(event: "screen_close", parameters: params)
    }

    func reportClick(screen: Screen, item: Item) {
        let params: [AnyHashable: Any] = [
            "event": EventType.click.rawValue,
            "screen": screen.rawValue,
            "item": item.rawValue
        ]
        report(event: "click", parameters: params)
    }
}
