//
//  OpeningHours.swift
//  Naendi
//
//  Decodes the `jam_buka` JSON blob into comparable time intervals so a
//  preferred time window can be matched against a place's schedule.
//

import Foundation

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
    static let indonesianDays = [
        "Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu"
    ]

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

    func isOpen(during window: MinuteInterval, onWeekday weekday: Int) -> Bool? {
        let dayIndex = weekday - 1
        guard Self.indonesianDays.indices.contains(dayIndex) else { return nil }
        guard let intervals = intervalsByDay[Self.indonesianDays[dayIndex]] else { return nil }

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
    var openingHours: OpeningHours? { OpeningHours(json: jamBuka) }
}
