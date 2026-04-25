import Foundation

struct TaskSnapshot: Codable {
    var rootTasks: [TaskItem]
}

struct TaskFileStore {
    let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileURL: URL) {
        self.fileURL = fileURL

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    static func live(fileManager: FileManager = .default) throws -> TaskFileStore {
        let baseDirectory: URL
        let appDirectory: URL

        if let containerURL = BrinkShared.appGroupIdentifiers.lazy.compactMap({
            fileManager.containerURL(forSecurityApplicationGroupIdentifier: $0)
        }).first {
            baseDirectory = containerURL
            appDirectory = baseDirectory.appendingPathComponent(
                BrinkShared.sharedDirectoryName,
                isDirectory: true
            )
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
            try migrateLegacyStoreIfNeeded(into: appDirectory, fileManager: fileManager)
        } else {
            baseDirectory = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            appDirectory = baseDirectory.appendingPathComponent(
                BrinkShared.sharedDirectoryName,
                isDirectory: true
            )
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }

        return TaskFileStore(
            fileURL: appDirectory.appendingPathComponent(BrinkShared.tasksFilename)
        )
    }

    func load() throws -> [TaskItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(TaskSnapshot.self, from: data).rootTasks
    }

    func save(_ rootTasks: [TaskItem]) throws {
        let data = try encoder.encode(TaskSnapshot(rootTasks: rootTasks))
        try data.write(to: fileURL, options: [.atomic])
    }

    private static func migrateLegacyStoreIfNeeded(into sharedDirectory: URL, fileManager: FileManager) throws {
        let sharedFileURL = sharedDirectory.appendingPathComponent(BrinkShared.tasksFilename)
        guard !fileManager.fileExists(atPath: sharedFileURL.path()) else {
            return
        }

        for legacyFileURL in try legacyFileURLs(fileManager: fileManager) {
            guard fileManager.fileExists(atPath: legacyFileURL.path()) else {
                continue
            }

            try fileManager.copyItem(at: legacyFileURL, to: sharedFileURL)
            return
        }
    }

    private static func legacyFileURLs(fileManager: FileManager) throws -> [URL] {
        let sandboxedSupportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let unsandboxedSupportDirectory = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)

        return [
            unsandboxedSupportDirectory,
            sandboxedSupportDirectory,
        ].map {
            $0.appendingPathComponent(BrinkShared.sharedDirectoryName, isDirectory: true)
                .appendingPathComponent(BrinkShared.tasksFilename)
        }
    }
}
