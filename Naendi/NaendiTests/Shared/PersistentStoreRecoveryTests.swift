import Foundation
import Testing
@testable import Naendi

struct PersistentStoreRecoveryTests {
    @Test("store recovery removes the database and its sidecar files")
    func removesStoreFamily() throws {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "store-recovery-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        let storeURL = directory.appending(path: "default.store")
        let family = PersistentStoreRecovery.storeFamilyURLs(for: storeURL)
        for url in family {
            #expect(FileManager.default.createFile(atPath: url.path, contents: Data()))
        }

        try PersistentStoreRecovery.removeStore(at: storeURL)

        for url in family {
            #expect(!FileManager.default.fileExists(atPath: url.path))
        }
    }

    @Test("store recovery succeeds when no store exists")
    func missingStoreIsSafe() throws {
        let storeURL = FileManager.default.temporaryDirectory
            .appending(path: "missing-store-\(UUID().uuidString).store")

        try PersistentStoreRecovery.removeStore(at: storeURL)
    }
}
