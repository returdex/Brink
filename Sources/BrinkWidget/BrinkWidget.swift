import SwiftUI
import WidgetKit

struct BrinkWidgetEntry: TimelineEntry {
    let date: Date
    let tasks: [TaskItem]
}

struct BrinkWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BrinkWidgetEntry {
        BrinkWidgetEntry(date: .now, tasks: sampleTasks(now: .now))
    }

    func getSnapshot(in context: Context, completion: @escaping (BrinkWidgetEntry) -> Void) {
        completion(loadEntry(now: .now, fallbackToSampleData: context.isPreview))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BrinkWidgetEntry>) -> Void) {
        let now = Date()
        let entry = loadEntry(now: now, fallbackToSampleData: context.isPreview)
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func loadEntry(now: Date, fallbackToSampleData: Bool) -> BrinkWidgetEntry {
        let tasks: [TaskItem]
        do {
            let store = try TaskFileStore.live()
            var decodedTasks: [TaskItem] = []
            if FileManager.default.fileExists(atPath: store.fileURL.path) {
                if let rawData = try? Data(contentsOf: store.fileURL) {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    decodedTasks = (try? decoder.decode(TaskSnapshot.self, from: rawData).rootTasks) ?? []
                }
            }
            let loaded = decodedTasks
            if loaded.isEmpty && fallbackToSampleData {
                tasks = sampleTasks(now: now)
            } else {
                tasks = loaded
            }
        } catch {
            if fallbackToSampleData {
                tasks = sampleTasks(now: now)
            } else {
                tasks = []
            }
        }

        let visibleTasks = tasks
            .flatMap { [$0] + $0.flattenedChildren }
            .filter { !$0.isCompleted }
            .sorted { TaskSortKey(task: $0) < TaskSortKey(task: $1) }

        return BrinkWidgetEntry(
            date: now,
            tasks: visibleTasks
        )
    }

    private func sampleTasks(now: Date) -> [TaskItem] {
        let calendar = Calendar.current
        return [
            TaskItem(
                title: "Launch Brink beta",
                dueDate: calendar.date(byAdding: .hour, value: 18, to: now)
            ),
            TaskItem(
                title: "Polish widget colors",
                dueDate: calendar.date(byAdding: .day, value: 2, to: now)
            ),
            TaskItem(
                title: "Review import flow",
                dueDate: calendar.date(byAdding: .day, value: 5, to: now)
            ),
        ]
    }
}

struct BrinkWidgetView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode

    let entry: BrinkWidgetEntry

    private let widgetCornerRadius: CGFloat = 36
    private let usesDarkAppearance = true

    var body: some View {
        ZStack {
            if entry.tasks.isEmpty {
                emptyState
            } else if renderingMode == .accented {
                accentedWidget(limit: family == .systemSmall ? 3 : 7)
            } else {
                switch family {
                case .systemSmall:
                    smallWidget
                case .systemMedium, .systemLarge:
                    listWidget(limit: 7)
                default:
                    listWidget(limit: 7)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: widgetCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: widgetCornerRadius, style: .continuous)
                .stroke(panelStroke.opacity(usesDarkAppearance ? 0.95 : 1), lineWidth: 1.5)
        )
        .containerBackground(for: .widget) {
            Group {
                if renderingMode == .accented {
                    Color.clear
                } else {
                    widgetBackground
                        .clipShape(RoundedRectangle(cornerRadius: widgetCornerRadius, style: .continuous))
                }
            }
        }
        .widgetURL(URL(string: "brink://tasks"))
    }

    private var widgetBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    backgroundTop,
                    backgroundMiddle,
                    backgroundBottom,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color(red: 0.98, green: 0.75, blue: 0.48).opacity(usesDarkAppearance ? 0.18 : 0.16))
                .frame(width: 180, height: 180)
                .offset(x: 120, y: -120)

            Circle()
                .fill(Color(red: 0.25, green: 0.61, blue: 0.97).opacity(usesDarkAppearance ? 0.14 : 0.10))
                .frame(width: 220, height: 220)
                .offset(x: -120, y: 170)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Brink")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(ink)

            Spacer()

            Text("No active deadlines")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(ink)

            Text("Your urgent task list will show up here.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(mutedInk)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(20)
    }

    private var smallWidget: some View {
        let task = entry.tasks[0]
        let color = urgencyColor(for: task, now: entry.date)

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Brink")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(ink)

                Spacer(minLength: 0)

                Text(riskLabel(for: task, now: entry.date))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.12), in: Capsule())
                    .foregroundStyle(color)
            }

            Spacer(minLength: 0)

            Circle()
                .fill(color.opacity(0.12))
                .overlay {
                    Circle()
                        .stroke(color.opacity(0.18), lineWidth: 16)
                    Circle()
                        .trim(from: 0, to: ringProgress(for: task, now: entry.date))
                        .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .padding(7)

                    VStack(spacing: 4) {
                        Text(relativeDueText(for: task, now: entry.date))
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(ink)
                        Text("left")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(mutedInk)
                    }
                }
                .frame(maxWidth: .infinity)

            Text(task.title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .lineLimit(2)
                .foregroundStyle(ink)

            Text(relativeDueDescription(for: task, now: entry.date))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(mutedInk)
        }
        .padding(18)
    }

    private func boardWidget(limit: Int, compact: Bool, showsHeader: Bool) -> some View {
        let tasks = Array(entry.tasks.prefix(limit))
        let heroTask = tasks.first
        let rows = Array(tasks.dropFirst())

        return VStack(alignment: .leading, spacing: compact ? 8 : 14) {
            if showsHeader {
                header
            } else {
                compactTopBar
            }

            if let heroTask {
                heroCard(for: heroTask, compact: compact)
            }

            VStack(spacing: compact ? 7 : 10) {
                ForEach(rows) { task in
                    taskRow(for: task, compact: compact)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(compact ? 14 : 18)
    }

    private func listWidget(limit: Int) -> some View {
        let tasks = Array(entry.tasks.prefix(limit))

        return VStack(alignment: .leading, spacing: 8) {
            compactTopBar

            ForEach(tasks) { task in
                taskRow(for: task, compact: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
    }

    private func accentedWidget(limit: Int) -> some View {
        let tasks = Array(entry.tasks.prefix(limit))

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Brink")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .widgetAccentable()

                Spacer(minLength: 8)

                Text("\(entry.tasks.count)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .widgetAccentable()
            }

            ForEach(tasks) { task in
                HStack(spacing: 10) {
                    Capsule()
                        .fill(Color.white.opacity(0.28))
                        .frame(width: 34, height: 5)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: max(34 * riskBarFill(for: task, now: entry.date), 10), height: 5)
                        }
                        .widgetAccentable()

                    VStack(alignment: .leading, spacing: 2) {
                        Text(task.title)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .widgetAccentable()

                        Text(relativeDueDescription(for: task, now: entry.date))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 6)

                    Text(relativeDueBadgeText(for: task, now: entry.date))
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .widgetAccentable()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .foregroundStyle(Color.white)
    }

    private var compactTopBar: some View {
        HStack(spacing: 8) {
            Text("Brink")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(ink)

            Spacer(minLength: 8)

            Text("\(entry.tasks.count) active")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(panelFill.opacity(0.92), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(panelStroke, lineWidth: 1)
                )
                .foregroundStyle(ink.opacity(0.82))
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Brink")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(ink)

                Text("Deadline radar")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(mutedInk)
            }

            Spacer(minLength: 12)

            Text("\(entry.tasks.count) active")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(panelFill.opacity(0.92), in: Capsule())
                .overlay(
                    Capsule()
                        .stroke(panelStroke, lineWidth: 1)
                )
                .foregroundStyle(ink.opacity(0.8))
        }
    }

    private func heroCard(for task: TaskItem, compact: Bool) -> some View {
        let color = urgencyColor(for: task, now: entry.date)

        return VStack(alignment: .leading, spacing: compact ? 8 : 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("Most urgent")
                    .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(heroPrimaryText.opacity(0.78))

                Spacer()

                Text(riskLabel(for: task, now: entry.date))
                    .font(.system(size: compact ? 10 : 11, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, compact ? 4 : 5)
                    .background(heroCapsuleFill, in: Capsule())
                    .foregroundStyle(heroPrimaryText)
            }

            Text(task.title)
                .font(.system(size: compact ? 15 : 24, weight: .black, design: .rounded))
                .lineLimit(compact ? 1 : 2)
                .minimumScaleFactor(compact ? 0.72 : 0.9)
                .foregroundStyle(heroPrimaryText)

            VStack(alignment: .leading, spacing: compact ? 6 : 8) {
                HStack {
                    Text(relativeDueBadgeText(for: task, now: entry.date))
                        .font(.system(size: compact ? 10 : 14, weight: .heavy, design: .rounded))
                        .foregroundStyle(heroPrimaryText)

                    Spacer(minLength: 8)

                    Text(relativeDueDescription(for: task, now: entry.date))
                        .font(.system(size: compact ? 10 : 12, weight: .bold, design: .rounded))
                        .foregroundStyle(heroSecondaryText)
                        .lineLimit(1)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(heroTrackFill)
                        Capsule()
                            .fill(heroProgressFill)
                            .frame(width: max(geometry.size.width * riskBarFill(for: task, now: entry.date), 28))
                    }
                }
                .frame(height: compact ? 6 : 8)
            }
        }
        .padding(compact ? 10 : 16)
        .background(
            LinearGradient(
                colors: [
                    color.mix(with: heroShadowMixColor, by: usesDarkAppearance ? 0.24 : 0.08),
                    color.mix(with: heroShadowMixColor, by: usesDarkAppearance ? 0.42 : 0.22),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: compact ? 24 : 28, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 24 : 28, style: .continuous)
                .stroke(heroStroke, lineWidth: 1)
        )
    }

    private func taskRow(for task: TaskItem, compact: Bool) -> some View {
        let color = urgencyColor(for: task, now: entry.date)

        return HStack(alignment: .center, spacing: compact ? 10 : 12) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(color.opacity(0.14))
                    .frame(width: compact ? 56 : 72, height: compact ? 6 : 8)

                Capsule()
                    .fill(color)
                    .frame(width: max((compact ? 56 : 72) * riskBarFill(for: task, now: entry.date), 12), height: compact ? 6 : 8)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: compact ? 13 : 16, weight: .bold, design: .rounded))
                    .foregroundStyle(ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(relativeDueDescription(for: task, now: entry.date))
                    .font(.system(size: compact ? 10 : 12, weight: .medium, design: .rounded))
                    .foregroundStyle(mutedInk)
                    .lineLimit(1)
                }

            Spacer(minLength: 8)

            Text(relativeDueBadgeText(for: task, now: entry.date))
                .font(.system(size: compact ? 10 : 13, weight: .heavy, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, compact ? 10 : 12)
        .padding(.vertical, compact ? 7 : 11)
        .background(panelFill, in: RoundedRectangle(cornerRadius: compact ? 18 : 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 18 : 22, style: .continuous)
                .stroke(panelStroke, lineWidth: 1)
        )
    }

    private var ink: Color {
        usesDarkAppearance
            ? Color(red: 0.95, green: 0.96, blue: 0.98)
            : Color(red: 0.09, green: 0.11, blue: 0.16)
    }

    private var mutedInk: Color {
        usesDarkAppearance
            ? Color(red: 0.69, green: 0.73, blue: 0.79)
            : Color(red: 0.35, green: 0.38, blue: 0.44)
    }

    private var backgroundTop: Color {
        usesDarkAppearance
            ? Color(red: 0.10, green: 0.11, blue: 0.15)
            : Color(red: 0.93, green: 0.96, blue: 0.99)
    }

    private var backgroundMiddle: Color {
        usesDarkAppearance
            ? Color(red: 0.13, green: 0.14, blue: 0.18)
            : Color(red: 0.99, green: 0.98, blue: 0.97)
    }

    private var backgroundBottom: Color {
        usesDarkAppearance
            ? Color(red: 0.07, green: 0.08, blue: 0.11)
            : Color.white
    }

    private var panelFill: Color {
        usesDarkAppearance
            ? Color(red: 0.14, green: 0.16, blue: 0.20).opacity(0.92)
            : Color.white.opacity(0.68)
    }

    private var panelStroke: Color {
        usesDarkAppearance
            ? Color(red: 0.29, green: 0.33, blue: 0.40).opacity(0.82)
            : Color.white.opacity(0.78)
    }

    private var heroShadowMixColor: Color {
        Color.black
    }

    private var heroPrimaryText: Color {
        usesDarkAppearance
            ? Color(red: 0.97, green: 0.98, blue: 0.99)
            : .white
    }

    private var heroSecondaryText: Color {
        usesDarkAppearance
            ? Color(red: 0.87, green: 0.90, blue: 0.95)
            : Color.white.opacity(0.9)
    }

    private var heroCapsuleFill: Color {
        usesDarkAppearance
            ? Color.black.opacity(0.22)
            : Color.white.opacity(0.14)
    }

    private var heroTrackFill: Color {
        usesDarkAppearance
            ? Color.black.opacity(0.24)
            : Color.white.opacity(0.16)
    }

    private var heroProgressFill: Color {
        usesDarkAppearance
            ? Color.white.opacity(0.88)
            : Color.white.opacity(0.92)
    }

    private var heroStroke: Color {
        usesDarkAppearance
            ? Color.white.opacity(0.08)
            : Color.white.opacity(0.12)
    }

    private func urgencyColor(for task: TaskItem, now: Date) -> Color {
        guard let dueDate = task.effectiveDue else {
            return Color.blue.opacity(0.55)
        }

        let hoursLeft = dueDate.timeIntervalSince(now) / 3600
        if hoursLeft <= 0 {
            return .red
        }
        if hoursLeft <= 24 {
            return .orange
        }
        if hoursLeft <= 72 {
            return .yellow
        }
        return .blue
    }

    private func riskBarFill(for task: TaskItem, now: Date) -> CGFloat {
        guard let dueDate = task.effectiveDue else {
            return 0.16
        }

        let hoursLeft = dueDate.timeIntervalSince(now) / 3600
        if hoursLeft <= 0 {
            return 1.0
        }
        if hoursLeft <= 24 {
            return 0.94
        }
        if hoursLeft <= 72 {
            return 0.72
        }
        if hoursLeft <= 168 {
            return 0.48
        }
        return 0.26
    }

    private func ringProgress(for task: TaskItem, now: Date) -> CGFloat {
        guard let dueDate = task.effectiveDue else {
            return 0.12
        }

        let hoursLeft = max(dueDate.timeIntervalSince(now) / 3600, 0)
        if hoursLeft <= 24 {
            return 1
        }

        return max(1 - min(hoursLeft / 168, 1), 0.18)
    }

    private func relativeDueText(for task: TaskItem, now: Date) -> String {
        guard let dueDate = task.effectiveDue else {
            return "No due"
        }

        let components = Calendar.current.dateComponents([.hour], from: now, to: dueDate)
        if let hours = components.hour {
            if hours <= 0 {
                return "Now"
            }
            if hours < 48 {
                return "\(hours)h"
            }
        }

        let days = max(Calendar.current.dateComponents([.day], from: now, to: dueDate).day ?? 0, 0)
        return "\(days)d"
    }

    private func relativeDueBadgeText(for task: TaskItem, now: Date) -> String {
        guard let dueDate = task.effectiveDue else {
            return "No due"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: dueDate, relativeTo: now)
    }

    private func relativeDueDescription(for task: TaskItem, now: Date) -> String {
        guard let dueDate = task.effectiveDue else {
            return "No deadline"
        }

        if dueDate < now {
            return "Overdue"
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: dueDate, relativeTo: now)
    }

    private func riskLabel(for task: TaskItem, now: Date) -> String {
        guard let dueDate = task.effectiveDue else {
            return "No Due"
        }

        let hoursLeft = dueDate.timeIntervalSince(now) / 3600
        if hoursLeft <= 0 {
            return "Overdue"
        }
        if hoursLeft <= 24 {
            return "Critical"
        }
        if hoursLeft <= 72 {
            return "Warning"
        }
        if hoursLeft <= 168 {
            return "Watch"
        }
        return "Safe"
    }
}

private extension Color {
    func mix(with other: Color, by amount: CGFloat) -> Color {
        let amount = min(max(amount, 0), 1)
        let lhs = NSColor(self).usingColorSpace(.deviceRGB) ?? .white
        let rhs = NSColor(other).usingColorSpace(.deviceRGB) ?? .white

        return Color(
            red: lhs.redComponent + (rhs.redComponent - lhs.redComponent) * amount,
            green: lhs.greenComponent + (rhs.greenComponent - lhs.greenComponent) * amount,
            blue: lhs.blueComponent + (rhs.blueComponent - lhs.blueComponent) * amount,
            opacity: lhs.alphaComponent + (rhs.alphaComponent - lhs.alphaComponent) * amount
        )
    }
}

struct BrinkWidget: Widget {
    let kind = BrinkShared.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BrinkWidgetProvider()) { entry in
            BrinkWidgetView(entry: entry)
        }
        .configurationDisplayName("Brink Deadlines")
        .description("Keep the most urgent deadlines visible on your desktop.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

@main
struct BrinkWidgetBundle: WidgetBundle {
    var body: some Widget {
        BrinkWidget()
    }
}
