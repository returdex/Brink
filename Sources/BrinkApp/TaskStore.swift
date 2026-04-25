import Foundation
import Observation
import WidgetKit

struct AppAlert: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
}

struct TaskDraft: Equatable {
    var title: String = ""
    var notes: String = ""
    var dueDate: Date = .now
    var hasDueDate = true
    var parentID: UUID?

    var normalizedNotes: String? {
        let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var normalizedDueDate: Date? {
        hasDueDate ? dueDate : nil
    }
}

@Observable
final class TaskStore {
    var rootTasks: [TaskItem]
    var now: Date
    var selectedTaskID: UUID?
    var draft = TaskDraft()
    var activeAlert: AppAlert?
    var hasBootstrappedNotifications = false

    private let fileStore: TaskFileStore
    private let notificationScheduler: TaskNotificationScheduler?

    init(
        rootTasks: [TaskItem],
        now: Date = .now,
        selectedTaskID: UUID? = nil,
        fileStore: TaskFileStore,
        notificationScheduler: TaskNotificationScheduler? = nil
    ) {
        self.rootTasks = rootTasks
        self.now = now
        self.selectedTaskID = selectedTaskID ?? rootTasks.sorted { TaskSortKey(task: $0) < TaskSortKey(task: $1) }.first?.id
        self.fileStore = fileStore
        self.notificationScheduler = notificationScheduler
    }

    static func live(now: Date = .now) -> TaskStore {
        do {
            let fileStore = try TaskFileStore.live()
            let loadedTasks = try fileStore.load()
            let tasks = loadedTasks.isEmpty ? sampleTasks(now: now) : loadedTasks
            let store = TaskStore(
                rootTasks: tasks,
                now: now,
                fileStore: fileStore,
                notificationScheduler: TaskNotificationScheduler()
            )
            if loadedTasks.isEmpty {
                try? fileStore.save(tasks)
            }
            return store
        } catch {
            let fallbackStore = try? TaskFileStore.live()
            let store = TaskStore(
                rootTasks: sampleTasks(now: now),
                now: now,
                fileStore: fallbackStore ?? TaskFileStore(fileURL: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("brink-tasks.json")),
                notificationScheduler: TaskNotificationScheduler()
            )
            return store
        }
    }

    var sortedRootTasks: [TaskItem] {
        rootTasks.sorted {
            TaskSortKey(task: $0) < TaskSortKey(task: $1)
        }
    }

    var allTasks: [TaskItem] {
        sortedRootTasks.flatMap { [$0] + $0.flattenedChildren }
    }

    var selectedTask: TaskItem? {
        guard let selectedTaskID else {
            return nil
        }
        return task(for: selectedTaskID)
    }

    var mostUrgentTask: TaskItem? {
        allTasks.first(where: { !$0.isCompleted })
    }

    var completedCount: Int {
        allTasks.filter(\.isCompleted).count
    }

    var activeCount: Int {
        allTasks.count - completedCount
    }

    func task(for id: UUID) -> TaskItem? {
        rootTasks.recursiveTask(id: id)
    }

    func selectTask(_ id: UUID?) {
        selectedTaskID = id
    }

    func refreshClock() {
        now = .now
        rescheduleNotifications()
    }

    func prepareDraft(parentID: UUID?) {
        draft = TaskDraft(parentID: parentID)
        if let parentID, let parent = task(for: parentID), let parentDue = parent.effectiveDue {
            draft.dueDate = parentDue
        } else {
            draft.dueDate = Calendar.current.date(byAdding: .day, value: 3, to: now) ?? now
        }
    }

    func createTask(from draft: TaskDraft) {
        let newTask = TaskItem(
            title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: draft.normalizedNotes,
            dueDate: draft.normalizedDueDate
        )

        guard !newTask.title.isEmpty else {
            return
        }

        if let parentID = draft.parentID {
            updateTaskTree {
                $0.appendChild(newTask, to: parentID)
            }
        } else {
            updateTaskTree {
                $0.append(newTask)
            }
        }

        selectedTaskID = newTask.id
    }

    func deleteSelectedTask() {
        guard let selectedTaskID else {
            return
        }

        updateTaskTree {
            $0.removeTask(withID: selectedTaskID)
        }

        self.selectedTaskID = sortedRootTasks.first?.id
    }

    func updateTitle(_ title: String, for id: UUID) {
        updateTask(id: id) {
            $0.title = title
        }
    }

    func updateNotes(_ notes: String, for id: UUID) {
        updateTask(id: id) {
            let trimmed = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            $0.notes = trimmed.isEmpty ? nil : trimmed
        }
    }

    func updateDueDate(_ dueDate: Date?, for id: UUID) {
        updateTask(id: id) {
            $0.dueDate = dueDate
        }
    }

    func updateStatus(_ status: TaskStatus, for id: UUID) {
        updateTask(id: id) {
            $0.status = status
        }
    }

    func updateTaskValue(id: UUID, mutate: (inout TaskItem) -> Void) {
        updateTask(id: id, mutate: mutate)
    }

    func requestNotificationAuthorization() {
        notificationScheduler?.requestAuthorizationIfNeeded()
    }

    func bootstrapAfterLaunch() {
        guard !hasBootstrappedNotifications else {
            return
        }

        hasBootstrappedNotifications = true
        requestNotificationAuthorization()
        rescheduleNotifications()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func exportDocument(format: TaskTransferFormat) -> TaskTransferDocument {
        TaskTransferDocument(rootTasks: rootTasks, format: format)
    }

    func importTasks(from url: URL) {
        do {
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: url)
            let format = format(for: url)
            let importedTasks = try TaskTransferCodec.decode(data: data, format: format)
            replaceAllTasks(with: importedTasks)
            activeAlert = AppAlert(
                title: L10n.string("Import complete"),
                message: L10n.importCompleteMessage(taskCount: allTasks.count, filename: url.lastPathComponent)
            )
        } catch {
            activeAlert = AppAlert(
                title: L10n.string("Import failed"),
                message: error.localizedDescription
            )
        }
    }

    func handleExportResult(_ result: Result<URL, Error>, format: TaskTransferFormat) {
        switch result {
        case let .success(url):
            activeAlert = AppAlert(
                title: L10n.string("Export complete"),
                message: L10n.exportCompleteMessage(format: format.rawValue.uppercased(), filename: url.lastPathComponent)
            )
        case let .failure(error):
            activeAlert = AppAlert(
                title: L10n.string("Export failed"),
                message: error.localizedDescription
            )
        }
    }

    private func updateTask(id: UUID, mutate: (inout TaskItem) -> Void) {
        updateTaskTree {
            _ = $0.updateTask(withID: id, mutate: mutate)
        }
    }

    private func updateTaskTree(_ mutate: (inout [TaskItem]) -> Void) {
        mutate(&rootTasks)
        persist()
    }

    private func persist() {
        do {
            try fileStore.save(rootTasks)
            rescheduleNotifications()
            WidgetCenter.shared.reloadTimelines(ofKind: BrinkShared.widgetKind)
        } catch {
            print("Brink failed to save tasks: \(error)")
        }
    }

    private func replaceAllTasks(with tasks: [TaskItem]) {
        rootTasks = tasks
        selectedTaskID = sortedRootTasks.first?.id
        persist()
    }

    private func rescheduleNotifications() {
        notificationScheduler?.reschedule(for: allTasks, now: now)
    }

    private func format(for url: URL) -> TaskTransferFormat {
        switch url.pathExtension.lowercased() {
        case "csv":
            return .csv
        default:
            return .json
        }
    }

    private static func sampleTasks(now: Date) -> [TaskItem] {
        let calendar = Calendar.current

        let launchPrep = TaskItem(
            title: L10n.string("Launch Brink beta"),
            dueDate: calendar.date(byAdding: .day, value: 5, to: now),
            children: [
                TaskItem(
                    title: L10n.string("Polish risk colors"),
                    dueDate: calendar.date(byAdding: .day, value: 2, to: now)
                ),
                TaskItem(
                    title: L10n.string("Record demo video"),
                    dueDate: calendar.date(byAdding: .day, value: 4, to: now)
                ),
            ]
        )

        let importFlow = TaskItem(
            title: L10n.string("Import pipeline"),
            dueDate: calendar.date(byAdding: .day, value: 9, to: now),
            children: [
                TaskItem(
                    title: L10n.string("CSV parser"),
                    dueDate: calendar.date(byAdding: .day, value: 6, to: now)
                ),
                TaskItem(
                    title: L10n.string("Reminders mapping draft"),
                    dueDate: calendar.date(byAdding: .day, value: 8, to: now)
                ),
            ]
        )

        let menuBar = TaskItem(
            title: L10n.string("Menu bar entry"),
            dueDate: calendar.date(byAdding: .hour, value: 20, to: now)
        )

        let dependency = TaskItem(
            title: L10n.string("Shared urgency model"),
            dueDate: calendar.date(byAdding: .day, value: 12, to: now),
            status: .completed
        )

        let someday = TaskItem(
            title: L10n.string("Investigate Widget syncing"),
            notes: L10n.string("App Group + GRDB snapshot"),
            dueDate: nil
        )

        return [launchPrep, importFlow, menuBar, dependency, someday]
    }
}
