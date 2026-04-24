import SwiftUI

struct CompactRiskCard: View {
    let task: TaskItem
    let now: Date

    var body: some View {
        let snapshot = UrgencyEngine.snapshot(for: task, now: now)

        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(snapshot.level.tint.opacity(0.18), lineWidth: 16)

                Circle()
                    .trim(from: 0, to: snapshot.ratio)
                    .stroke(snapshot.level.tint, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("1x1")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(snapshot.level.label)
                        .font(.headline.weight(.bold))
                }
            }
            .frame(width: 120, height: 120)

            VStack(alignment: .leading, spacing: 8) {
                Text("Most urgent now")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(task.title)
                    .font(.title2.weight(.bold))
                Text(snapshot.subtitle)
                    .font(.headline)
                    .foregroundStyle(snapshot.level.tint)

                if task.incompleteDescendantCount > 0 {
                    Text("\(task.incompleteDescendantCount) nested tasks still active")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
