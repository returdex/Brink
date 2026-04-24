import SwiftUI

struct MenuBarContentView: View {
    let store: TaskStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Brink")
                .font(.title3.weight(.bold))

            if let mostUrgent = store.mostUrgentTask {
                let snapshot = UrgencyEngine.snapshot(for: mostUrgent, now: store.now)

                VStack(alignment: .leading, spacing: 6) {
                    Text(mostUrgent.title)
                        .font(.headline)
                    Text(snapshot.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(snapshot.level.tint)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(snapshot.level.tint.opacity(0.12))
                )
            }

            Divider()

            ForEach(store.sortedRootTasks.prefix(4)) { task in
                TaskSummaryRow(
                    task: task,
                    now: store.now,
                    isSelected: store.selectedTaskID == task.id,
                    onSelect: { store.selectTask($0) }
                )
            }
        }
        .padding(16)
    }
}
