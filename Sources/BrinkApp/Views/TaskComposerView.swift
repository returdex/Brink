import SwiftUI

struct TaskComposerView: View {
    @Bindable var store: TaskStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("New Task") {
                    TextField("Task title", text: $store.draft.title)
                    TextField("Notes", text: $store.draft.notes, axis: .vertical)
                        .lineLimit(4, reservesSpace: true)
                }

                Section("Deadline") {
                    Toggle("Has deadline", isOn: $store.draft.hasDueDate)

                    if store.draft.hasDueDate {
                        DatePicker(
                            "Due date",
                            selection: $store.draft.dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                if let parentID = store.draft.parentID, let parent = store.task(for: parentID) {
                    Section("Parent") {
                        Text(parent.title)
                    }
                }
            }
            .navigationTitle(store.draft.parentID == nil ? "New Root Task" : "New Child Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        store.createTask(from: store.draft)
                        dismiss()
                    }
                    .disabled(store.draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(minWidth: 420, minHeight: 360)
    }
}
