import Foundation

enum TaskStatus: String, Codable, Sendable {
    case pending
    case completed
}

struct TaskItem: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var title: String
    var notes: String?
    var dueDate: Date?
    var status: TaskStatus
    var children: [TaskItem]

    init(
        id: UUID = UUID(),
        title: String,
        notes: String? = nil,
        dueDate: Date? = nil,
        status: TaskStatus = .pending,
        children: [TaskItem] = []
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.status = status
        self.children = children
    }

    var isCompleted: Bool {
        status == .completed
    }

    var effectiveDue: Date? {
        guard !isCompleted else {
            return nil
        }

        let descendantDueDates = children.compactMap(\.effectiveDue)
        return ([dueDate].compactMap { $0 } + descendantDueDates).min()
    }

    var visibleChildren: [TaskItem] {
        children.sorted {
            TaskSortKey(task: $0) < TaskSortKey(task: $1)
        }
    }

    var incompleteDescendantCount: Int {
        children.reduce(0) { partialResult, child in
            partialResult + (child.isCompleted ? 0 : 1) + child.incompleteDescendantCount
        }
    }

    var flattenedChildren: [TaskItem] {
        visibleChildren.flatMap { [$0] + $0.flattenedChildren }
    }
}

struct TaskSortKey: Comparable {
    let isCompleted: Bool
    let effectiveDue: Date?
    let title: String

    init(task: TaskItem) {
        isCompleted = task.isCompleted
        effectiveDue = task.effectiveDue
        title = task.title.localizedLowercase
    }

    static func < (lhs: TaskSortKey, rhs: TaskSortKey) -> Bool {
        if lhs.isCompleted != rhs.isCompleted {
            return lhs.isCompleted == false
        }

        switch (lhs.effectiveDue, rhs.effectiveDue) {
        case let (left?, right?):
            if left != right {
                return left < right
            }
        case (.some, .none):
            return true
        case (.none, .some):
            return false
        case (.none, .none):
            break
        }

        return lhs.title < rhs.title
    }
}

extension Array where Element == TaskItem {
    func recursiveTask(id: UUID) -> TaskItem? {
        for task in self {
            if task.id == id {
                return task
            }
            if let child = task.children.recursiveTask(id: id) {
                return child
            }
        }
        return nil
    }

    mutating func updateTask(withID id: UUID, mutate: (inout TaskItem) -> Void) -> Bool {
        for index in indices {
            if self[index].id == id {
                mutate(&self[index])
                return true
            }

            if self[index].children.updateTask(withID: id, mutate: mutate) {
                return true
            }
        }
        return false
    }

    mutating func appendChild(_ child: TaskItem, to parentID: UUID) {
        _ = updateTask(withID: parentID) { task in
            task.children.append(child)
        }
    }

    mutating func removeTask(withID id: UUID) {
        if let index = firstIndex(where: { $0.id == id }) {
            remove(at: index)
            return
        }

        for index in indices {
            self[index].children.removeTask(withID: id)
        }
    }
}
