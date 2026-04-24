import Foundation
@preconcurrency import UserNotifications

final class TaskNotificationScheduler {
    private let center: UNUserNotificationCenter
    private let identifierPrefix = "brink.task."

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { [center] settings in
            guard settings.authorizationStatus == .notDetermined else {
                return
            }

            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error {
                    print("Brink notification auth request failed: \(error)")
                } else if !granted {
                    print("Brink notification permission not granted")
                }
            }
        }
    }

    func reschedule(for tasks: [TaskItem], now: Date = .now) {
        center.getNotificationSettings { [center, identifierPrefix] settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                return
            }

            center.getPendingNotificationRequests { requests in
                let existingIDs = requests.map(\.identifier).filter { $0.hasPrefix(identifierPrefix) }
                if !existingIDs.isEmpty {
                    center.removePendingNotificationRequests(withIdentifiers: existingIDs)
                }

                let activeTasks = tasks.filter { !$0.isCompleted }
                for task in activeTasks {
                    guard let dueDate = task.effectiveDue else {
                        continue
                    }

                    let reminders = Self.reminderDates(for: dueDate, now: now)
                    for reminder in reminders {
                        let content = UNMutableNotificationContent()
                        content.title = task.title
                        content.body = reminder.body
                        content.sound = .default
                        content.userInfo = ["taskID": task.id.uuidString]

                        let components = Calendar.current.dateComponents(
                            [.year, .month, .day, .hour, .minute, .second],
                            from: reminder.date
                        )
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                        let request = UNNotificationRequest(
                            identifier: Self.identifier(prefix: identifierPrefix, taskID: task.id, kind: reminder.kind),
                            content: content,
                            trigger: trigger
                        )

                        center.add(request) { error in
                            if let error {
                                print("Brink failed scheduling notification for \(task.id): \(error)")
                            }
                        }
                    }
                }
            }
        }
    }

    private static func reminderDates(for dueDate: Date, now: Date) -> [(kind: String, date: Date, body: String)] {
        var reminders: [(String, Date, String)] = []

        let oneHourBefore = dueDate.addingTimeInterval(-3600)
        if oneHourBefore.timeIntervalSince(now) > 60 {
            reminders.append((
                "soon",
                oneHourBefore,
                L10n.string("Due in about an hour. Brink is keeping this task on top.")
            ))
        }

        if dueDate.timeIntervalSince(now) > 60 {
            reminders.append((
                "due",
                dueDate,
                L10n.string("This task has reached its deadline.")
            ))
        }

        return reminders
    }

    private static func identifier(prefix: String, taskID: UUID, kind: String) -> String {
        "\(prefix)\(taskID.uuidString).\(kind)"
    }
}
