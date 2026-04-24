import SwiftUI

struct TaskBoardView: View {
    let tasks: [TaskItem]
    let now: Date
    let selectedTaskID: UUID?
    let onSelect: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Risk Board")
                        .font(.title3.weight(.bold))
                    Text("Horizontal bars communicate deadline pressure rather than completion.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            LazyVStack(spacing: 14) {
                ForEach(tasks) { task in
                    TaskSummaryRow(
                        task: task,
                        now: now,
                        isSelected: selectedTaskID == task.id,
                        onSelect: onSelect
                    )
                }
            }
        }
    }
}

struct TaskSummaryRow: View {
    let task: TaskItem
    let now: Date
    let isSelected: Bool
    let onSelect: (UUID) -> Void
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let snapshot = UrgencyEngine.snapshot(for: task, now: now)

        Button {
            onSelect(task.id)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.headline)
                        Text(snapshot.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(snapshot.level.label)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(snapshot.level.tint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(snapshot.level.tint.opacity(0.12))
                        .clipShape(Capsule())
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(BrinkTheme.progressTrack(for: colorScheme))
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(snapshot.level.tint)
                            .frame(width: proxy.size.width * snapshot.ratio)
                    }
                }
                .frame(height: 14)

                if !task.visibleChildren.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(task.visibleChildren) { child in
                            HStack {
                                Image(systemName: "arrow.turn.down.right")
                                    .foregroundStyle(.secondary)
                                Text(child.title)
                                    .font(.subheadline)
                                Spacer()
                                Text(UrgencyEngine.snapshot(for: child, now: now).subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.leading, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .padding(18)
        .background(BrinkTheme.cardBackground(isSelected: isSelected))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(BrinkTheme.cardBorder(isSelected: isSelected), lineWidth: 1)
        )
        .shadow(color: BrinkTheme.shadow.opacity(colorScheme == .dark ? 0.45 : 0.18), radius: 18, y: 8)
    }
}
