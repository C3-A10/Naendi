//
//  OpeningHours.swift
//  Naendi
//
//  Decodes the `jam_buka` JSON blob into comparable time intervals so a
//  preferred time window can be matched against a place's schedule.
//

import Foundation

/// Minutes from midnight. `end` may exceed 1440 for a slot that runs past
/// midnight, e.g. "18.00–02.00" becomes 1080...1560.
struct MinuteInterval: Equatable {
    let start: Int
    let end: Int

    init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }

    init(startHour: Int, startMinute: Int = 0, endHour: Int, endMinute: Int = 0) {
        self.init(start: startHour * 60 + startMinute, end: endHour * 60 + endMinute)
    }

    func contains(_ other: MinuteInterval) -> Bool {
        start <= other.start && other.end <= end
    }
}

struct OpeningHours {
    /// Indexed by `Calendar.component(.weekday)` minus one, so Sunday is first.
    /// Deliberately hardcoded rather than derived from a DateFormatter with an
    /// id_ID locale — that route depends on ICU data and varies by platform.
    static let indonesianDays = [
        "Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"
    ]

    /// A present-but-empty value means the place is explicitly closed that day.
    /// An absent key means the schedule is unknown for that day.
    private let intervalsByDay: [String: [MinuteInterval]]

    init?(json: String) {
        guard
            let data = json.data(using: .utf8),
            let raw = try? JSONDecoder().decode([String: [String]].self, from: data)
        else { return nil }

        intervalsByDay = raw.mapValues { slots in
            Self.merge(slots.compactMap(Self.interval(from:)))
        }
    }

    /// Returns `nil` when the schedule for that day is unknown, which callers
    /// treat as a pass rather than a non-match.
    func isOpen(during window: MinuteInterval, onWeekday weekday: Int) -> Bool? {
        let dayIndex = weekday - 1
        guard Self.indonesianDays.indices.contains(dayIndex) else { return nil }
        guard let intervals = intervalsByDay[Self.indonesianDays[dayIndex]] else { return nil }

        // Whole-window containment: the place must be open for the entire
        // requested window. Swap `contains` for an overlap test to loosen this.
        return intervals.contains { $0.contains(window) }
    }

    private static func interval(from slot: String) -> MinuteInterval? {
        let text = slot.trimmingCharacters(in: .whitespaces).lowercased()

        if text.contains("tutup") { return nil }
        if text.contains("24 jam") { return MinuteInterval(start: 0, end: 24 * 60) }

        let parts = text.components(separatedBy: CharacterSet(charactersIn: "\u{2013}-"))
        guard
            parts.count == 2,
            let open = minutes(from: parts[0]),
            let close = minutes(from: parts[1])
        else { return nil }

        // A closing time at or before the opening time runs past midnight.
        return MinuteInterval(start: open, end: close <= open ? close + 24 * 60 : close)
    }

    private static func minutes(from token: String) -> Int? {
        let parts = token
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: CharacterSet(charactersIn: ".:"))
        guard
            parts.count == 2,
            let hour = Int(parts[0]),
            let minute = Int(parts[1]),
            (0...23).contains(hour),
            (0...59).contains(minute)
        else { return nil }
        return hour * 60 + minute
    }

    /// Collapses overlapping or touching slots so a split schedule like
    /// "08.00–12.00" + "12.00–20.00" is treated as one continuous stretch.
    private static func merge(_ intervals: [MinuteInterval]) -> [MinuteInterval] {
        let sorted = intervals.sorted { $0.start < $1.start }
        return sorted.reduce(into: [MinuteInterval]()) { merged, next in
            if let last = merged.last, next.start <= last.end {
                merged[merged.count - 1] = MinuteInterval(
                    start: last.start,
                    end: Swift.max(last.end, next.end)
                )
            } else {
                merged.append(next)
            }
        }
    }
}

extension Place {
    /// `nil` when `jamBuka` is missing or malformed.
    var openingHours: OpeningHours? { OpeningHours(json: jamBuka) }
}
