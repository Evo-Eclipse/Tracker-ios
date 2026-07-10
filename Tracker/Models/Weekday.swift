//
//  Weekday.swift
//  Tracker
//
//  Created by Pavel Komarov on 02.08.2025.
//

enum Weekday: Int, CaseIterable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday

    var long: String {
        switch self {
        case .monday: return L10n.mondayFull
        case .tuesday: return L10n.tuesdayFull
        case .wednesday: return L10n.wednesdayFull
        case .thursday: return L10n.thursdayFull
        case .friday: return L10n.fridayFull
        case .saturday: return L10n.saturdayFull
        case .sunday: return L10n.sundayFull
        }
    }

    var short: String {
        switch self {
        case .monday: return L10n.mondayShort
        case .tuesday: return L10n.tuesdayShort
        case .wednesday: return L10n.wednesdayShort
        case .thursday: return L10n.thursdayShort
        case .friday: return L10n.fridayShort
        case .saturday: return L10n.saturdayShort
        case .sunday: return L10n.sundayShort
        }
    }

    static func fromSystemIndex(_ index: Int) -> Weekday {
        switch index {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}
