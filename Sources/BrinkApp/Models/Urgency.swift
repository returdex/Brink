import Foundation
import SwiftUI

enum UrgencyLevel: String, CaseIterable, Sendable {
    case safe
    case attention
    case elevated
    case critical
    case complete
    case unscheduled

    var tint: Color {
        switch self {
        case .safe:
            return Color(red: 0.18, green: 0.47, blue: 0.93)
        case .attention:
            return Color(red: 0.91, green: 0.75, blue: 0.18)
        case .elevated:
            return Color(red: 0.94, green: 0.50, blue: 0.15)
        case .critical:
            return Color(red: 0.88, green: 0.22, blue: 0.19)
        case .complete:
            return Color(red: 0.22, green: 0.62, blue: 0.36)
        case .unscheduled:
            return Color.secondary.opacity(0.18)
        }
    }

    var label: String {
        switch self {
        case .safe:
            return "Safe"
        case .attention:
            return "Watch"
        case .elevated:
            return "Soon"
        case .critical:
            return "Now"
        case .complete:
            return "Done"
        case .unscheduled:
            return "No due"
        }
    }
}

struct UrgencySnapshot: Sendable {
    let level: UrgencyLevel
    let ratio: Double
    let subtitle: String
}

enum UrgencyEngine {
    static func snapshot(for task: TaskItem, now: Date = .now) -> UrgencySnapshot {
        if task.isCompleted {
            return UrgencySnapshot(level: .complete, ratio: 1.0, subtitle: "Completed")
        }

        guard let dueDate = task.effectiveDue else {
            return UrgencySnapshot(level: .unscheduled, ratio: 0.0, subtitle: "No deadline")
        }

        let remaining = dueDate.timeIntervalSince(now)
        let day: TimeInterval = 24 * 60 * 60

        let level: UrgencyLevel
        switch remaining {
        case ..<0:
            level = .critical
        case ..<(2 * day):
            level = .critical
        case ..<(5 * day):
            level = .elevated
        case ..<(10 * day):
            level = .attention
        default:
            level = .safe
        }

        let ratio = progressRatio(remaining: remaining, horizon: 14 * day)
        return UrgencySnapshot(
            level: level,
            ratio: ratio,
            subtitle: RelativeDateTimeFormatter().localizedString(for: dueDate, relativeTo: now)
        )
    }

    private static func progressRatio(remaining: TimeInterval, horizon: TimeInterval) -> Double {
        let normalized = 1.0 - (remaining / horizon)
        return min(max(normalized, 0.08), 1.0)
    }
}
