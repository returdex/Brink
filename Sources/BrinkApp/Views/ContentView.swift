import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Bindable var store: TaskStore
    @State private var showingComposer = false
    @State private var showingImporter = false
    @State private var showingExporter = false
    @State private var exportFormat: TaskTransferFormat = .json

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            HSplitView {
                detail
                TaskEditorView(store: store)
                    .frame(minWidth: 310, idealWidth: 340, maxWidth: 380)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    store.prepareDraft(parentID: nil)
                    showingComposer = true
                } label: {
                    Label("New Task", systemImage: "plus")
                }

                Button {
                    store.prepareDraft(parentID: store.selectedTaskID)
                    showingComposer = true
                } label: {
                    Label("New Child", systemImage: "arrow.turn.down.right")
                }
                .disabled(store.selectedTaskID == nil)

                Button(role: .destructive) {
                    store.deleteSelectedTask()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .disabled(store.selectedTaskID == nil)

                Menu {
                    Button("Import JSON or CSV…") {
                        showingImporter = true
                    }

                    Divider()

                    Button("Export JSON…") {
                        exportFormat = .json
                        showingExporter = true
                    }

                    Button("Export CSV…") {
                        exportFormat = .csv
                        showingExporter = true
                    }
                } label: {
                    Label("Import Export", systemImage: "square.and.arrow.up.on.square")
                }

                Button {
                    store.requestNotificationAuthorization()
                } label: {
                    Label("Notifications", systemImage: "bell.badge")
                }
            }
        }
        .sheet(isPresented: $showingComposer) {
            TaskComposerView(store: store)
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                guard let url = urls.first else {
                    return
                }
                store.importTasks(from: url)
            case let .failure(error):
                store.activeAlert = AppAlert(title: L10n.string("Import failed"), message: error.localizedDescription)
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: store.exportDocument(format: exportFormat),
            contentType: exportFormat.contentType,
            defaultFilename: exportFormat.suggestedFilename
        ) { result in
            store.handleExportResult(result, format: exportFormat)
        }
        .alert(item: Binding(
            get: { store.activeAlert },
            set: { store.activeAlert = $0 }
        )) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .task {
            store.bootstrapAfterLaunch()

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                store.refreshClock()
            }
        }
    }

    private var sidebar: some View {
        List {
            Section("Overview") {
                MetricRow(title: "Active", value: "\(store.activeCount)", icon: "bolt.fill")
                MetricRow(title: "Completed", value: "\(store.completedCount)", icon: "checkmark.circle.fill")
                    .foregroundStyle(.secondary)
                MetricRow(title: "Storage", value: L10n.string("Local"), icon: "externaldrive")
                    .foregroundStyle(.secondary)
            }

            Section("Tasks") {
                ForEach(store.sortedRootTasks) { task in
                    SidebarTaskRow(
                        task: task,
                        selectedTaskID: store.selectedTaskID,
                        now: store.now
                    ) { selectedID in
                        store.selectTask(selectedID)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Brink")
    }

    private var detail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let task = store.mostUrgentTask {
                    CompactRiskCard(task: task, now: store.now)
                }

                TaskBoardView(
                    tasks: store.sortedRootTasks,
                    now: store.now,
                    selectedTaskID: store.selectedTaskID
                ) { selectedID in
                    store.selectTask(selectedID)
                }
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [
                    BrinkTheme.canvasTop,
                    BrinkTheme.canvasBottom,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private struct MetricRow: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .font(.headline.monospacedDigit())
        }
    }
}

private struct SidebarTaskRow: View {
    let task: TaskItem
    let selectedTaskID: UUID?
    let now: Date
    let onSelect: (UUID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            taskButton(task)

            if !task.visibleChildren.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(task.visibleChildren) { child in
                        taskButton(child, isChild: true)
                    }
                }
                .padding(.leading, 12)
            }
        }
    }

    private func taskButton(_ task: TaskItem, isChild: Bool = false) -> some View {
        let snapshot = UrgencyEngine.snapshot(for: task, now: now)

        return Button {
            onSelect(task.id)
        } label: {
            HStack(spacing: 10) {
                Circle()
                    .fill(snapshot.level.tint)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(isChild ? .subheadline : .headline)
                        .lineLimit(1)
                    Text(snapshot.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(selectedTaskID == task.id ? Color.accentColor.opacity(0.12) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
