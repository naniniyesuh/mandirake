import SwiftUI
import UniformTypeIdentifiers

/// Yedek dosyasının içeriği: tüm yoğurt ve anne sütü kayıtları
nonisolated struct BackupPayload: Codable {
    var version = 1
    var exportedAt = Date()
    var batches: [YogurtBatch]
    var bags: [MilkBag]
    var fermentStart: Date?
    var lastFermentMinutes: Int?
}

/// .json olarak kaydedilen / açılan yedek belgesi
nonisolated struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var payload: BackupPayload

    init(payload: BackupPayload) {
        self.payload = payload
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        payload = try Self.decode(data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return FileWrapper(regularFileWithContents: try encoder.encode(payload))
    }

    static func decode(_ data: Data) throws -> BackupPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(BackupPayload.self, from: data)
    }
}
