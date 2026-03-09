// Models/HabitItem.swift

import Foundation

/// Which days of the week a habit can be scheduled on
enum Weekday: Int, CaseIterable, Identifiable, Codable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }
    var displayName: String {
        switch self {
        case .sunday:    return "Sun"
        case .monday:    return "Mon"
        case .tuesday:   return "Tue"
        case .wednesday: return "Wed"
        case .thursday:  return "Thu"
        case .friday:    return "Fri"
        case .saturday:  return "Sat"
        }
    }
}

/// When during the day the habit should occur
enum TimeOfDay: String, CaseIterable, Identifiable, Codable {
    case morning, afternoon, evening

    var id: Self { self }
    var displayName: String {
        switch self {
        case .morning:   return "Morning"
        case .afternoon: return "Afternoon"
        case .evening:   return "Evening"
        }
    }
}

struct HabitItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var selectedDays: [Weekday]
    var timeOfDay: TimeOfDay

    init(
        id: UUID = UUID(),
        name: String,
        selectedDays: [Weekday],
        timeOfDay: TimeOfDay
    ) {
        self.id = id
        self.name = name
        self.selectedDays = selectedDays
        self.timeOfDay = timeOfDay
    }
}
