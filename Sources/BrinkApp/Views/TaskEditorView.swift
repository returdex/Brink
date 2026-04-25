import SwiftUI

struct TaskEditorView: View {
    @Bindable var store: TaskStore

    var body: some View {
        Group {
            if let task = store.selectedTask {
                editor(for: task)
            } else {
                ContentUnavailableView(
                    "Select a task",
                    systemImage: "square.and.pencil",
                    description: Text("Choose a task from the sidebar or create a new one to start editing.")
                )
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    BrinkTheme.canvasTop.opacity(0.78),
                    BrinkTheme.canvasBottom.opacity(0.92),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func editor(for task: TaskItem) -> some View {
        Form {
            Section("Task") {
                TextField(
                    "Task title",
                    text: binding(for: task.id) { $0.title } set: { $0.title = $1 }
                )

                Picker(
                    "Status",
                    selection: binding(for: task.id) { $0.status } set: { $0.status = $1 }
                ) {
                    Text("Active").tag(TaskStatus.pending)
                    Text("Completed").tag(TaskStatus.completed)
                }
                .pickerStyle(.segmented)
            }

            Section("Deadline") {
                Toggle(
                    "Has deadline",
                    isOn: Binding(
                        get: { store.task(for: task.id)?.dueDate != nil },
                        set: { hasDeadline in
                            let fallbackDate = Calendar.current.date(byAdding: .day, value: 3, to: store.now) ?? store.now
                            store.updateDueDate(hasDeadline ? (store.task(for: task.id)?.dueDate ?? fallbackDate) : nil, for: task.id)
                        }
                    )
                )

                if store.task(for: task.id)?.dueDate != nil {
                    DatePicker(
                        "Due date",
                        selection: Binding(
                            get: { store.task(for: task.id)?.dueDate ?? store.now },
                            set: { store.updateDueDate($0, for: task.id) }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }

            Section("Notes") {
                TextEditor(
                    text: binding(for: task.id) { $0.notes ?? "" } set: { task, value in
                        task.notes = value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : value
                    }
                )
                .frame(minHeight: 150)
            }

            Section("Context") {
                LabeledContent("Effective due") {
                    Text(task.effectiveDue.map { RelativeDateTimeFormatter().localizedString(for: $0, relativeTo: store.now) } ?? L10n.string("No deadline"))
                }
                LabeledContent("Nested active tasks") {
                    Text("\(task.incompleteDescendantCount)")
                }
                Text("Local reminders are scheduled automatically one hour before and at the deadline for active tasks.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .padding(18)
        .brinkPanel(cornerRadius: 30)
    }

    private func binding<Value>(
        for id: UUID,
        get: @escaping (TaskItem) -> Value,
        set: @escaping (inout TaskItem, Value) -> Void
    ) -> Binding<Value> {
        Binding(
            get: {
                guard let task = store.task(for: id) else {
                    fatalError("Task missing while editing")
                }
                return get(task)
            },
            set: { value in
                store.updateTaskValue(id: id) { task in
                    set(&task, value)
                }
            }
        )
    }
}
