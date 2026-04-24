import Foundation
import SwiftUI
import UniformTypeIdentifiers

enum TaskTransferFormat: String, CaseIterable, Identifiable {
    case json
    case csv

    var id: String { rawValue }

    var contentType: UTType {
        switch self {
        case .json:
            return .json
        case .csv:
            return .commaSeparatedText
        }
    }

    var suggestedFilename: String {
        switch self {
        case .json:
            return "Brink-Tasks.json"
        case .csv:
            return "Brink-Tasks.csv"
        }
    }
}

struct TaskTransferDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.json, .commaSeparatedText]
    }

    static var writableContentTypes: [UTType] {
        [.json, .commaSeparatedText]
    }

    let rootTasks: [TaskItem]
    let format: TaskTransferFormat

    init(rootTasks: [TaskItem], format: TaskTransferFormat) {
        self.rootTasks = rootTasks
        self.format = format
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let format = TaskTransferCodec.format(for: configuration.contentType)
        self.rootTasks = try TaskTransferCodec.decode(data: data, format: format)
        self.format = format
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try TaskTransferCodec.encode(tasks: rootTasks, format: format)
        return .init(regularFileWithContents: data)
    }
}

enum TaskTransferCodec {
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private static let csvHeaders = ["id", "parentID", "title", "notes", "dueDate", "status"]

    static func format(for contentType: UTType) -> TaskTransferFormat {
        contentType.conforms(to: .json) ? .json : .csv
    }

    static func decode(data: Data, format: TaskTransferFormat) throws -> [TaskItem] {
        switch format {
        case .json:
            return try jsonDecoder.decode(TaskSnapshot.self, from: data).rootTasks
        case .csv:
            guard let string = String(data: data, encoding: .utf8) else {
                throw CocoaError(.fileReadInapplicableStringEncoding)
            }
            return try decodeCSV(string)
        }
    }

    static func encode(tasks: [TaskItem], format: TaskTransferFormat) throws -> Data {
        switch format {
        case .json:
            return try jsonEncoder.encode(TaskSnapshot(rootTasks: tasks))
        case .csv:
            return Data(encodeCSV(tasks).utf8)
        }
    }

    private static func encodeCSV(_ tasks: [TaskItem]) -> String {
        var rows = [csvHeaders]
        rows.append(contentsOf: flatten(tasks: tasks, parentID: nil))
        return rows.map { $0.map(escapeCSVField).joined(separator: ",") }.joined(separator: "\n")
    }

    private static func flatten(tasks: [TaskItem], parentID: UUID?) -> [[String]] {
        tasks.flatMap { task in
            let row = [
                task.id.uuidString,
                parentID?.uuidString ?? "",
                task.title,
                task.notes ?? "",
                task.dueDate.map { ISO8601DateFormatter().string(from: $0) } ?? "",
                task.status.rawValue,
            ]
            return [row] + flatten(tasks: task.children, parentID: task.id)
        }
    }

    private static func decodeCSV(_ string: String) throws -> [TaskItem] {
        let rows = parseCSVRows(string)
        guard !rows.isEmpty else {
            return []
        }

        let contentRows = rows.dropFirst().filter { !$0.allSatisfy(\.isEmpty) }

        struct CSVRow {
            let id: UUID
            let parentID: UUID?
            let title: String
            let notes: String?
            let dueDate: Date?
            let status: TaskStatus
        }

        let formatter = ISO8601DateFormatter()
        var orderedRows: [CSVRow] = []

        for columns in contentRows {
            let padded = columns + Array(repeating: "", count: max(0, csvHeaders.count - columns.count))
            let id = UUID(uuidString: padded[0]) ?? UUID()
            let parentID = UUID(uuidString: padded[1])
            let title = padded[2].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else {
                continue
            }
            let notes = padded[3].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : padded[3]
            let dueDate = formatter.date(from: padded[4])
            let status = TaskStatus(rawValue: padded[5]) ?? .pending
            orderedRows.append(CSVRow(id: id, parentID: parentID, title: title, notes: notes, dueDate: dueDate, status: status))
        }

        var tasksByID: [UUID: TaskItem] = [:]
        var childIDsByParent: [UUID: [UUID]] = [:]
        var rootIDs: [UUID] = []

        for row in orderedRows {
            tasksByID[row.id] = TaskItem(
                id: row.id,
                title: row.title,
                notes: row.notes,
                dueDate: row.dueDate,
                status: row.status
            )

            if let parentID = row.parentID, parentID != row.id {
                childIDsByParent[parentID, default: []].append(row.id)
            } else {
                rootIDs.append(row.id)
            }
        }

        func buildTree(for id: UUID, visiting: inout Set<UUID>) -> TaskItem? {
            guard var task = tasksByID[id], !visiting.contains(id) else {
                return nil
            }

            visiting.insert(id)
            let childIDs = childIDsByParent[id] ?? []
            task.children = childIDs.compactMap { childID in
                buildTree(for: childID, visiting: &visiting)
            }
            visiting.remove(id)
            return task
        }

        return rootIDs.compactMap { id in
            var visiting = Set<UUID>()
            return buildTree(for: id, visiting: &visiting)
        }
    }

    private static func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return field
    }

    private static func parseCSVRows(_ string: String) -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var insideQuotes = false
        let characters = Array(string)
        var index = 0

        while index < characters.count {
            let character = characters[index]

            if insideQuotes {
                if character == "\"" {
                    if index + 1 < characters.count, characters[index + 1] == "\"" {
                        field.append("\"")
                        index += 1
                    } else {
                        insideQuotes = false
                    }
                } else {
                    field.append(character)
                }
            } else {
                switch character {
                case "\"":
                    insideQuotes = true
                case ",":
                    row.append(field)
                    field = ""
                case "\n":
                    row.append(field)
                    rows.append(row)
                    row = []
                    field = ""
                case "\r":
                    break
                default:
                    field.append(character)
                }
            }

            index += 1
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }

        return rows
    }
}
