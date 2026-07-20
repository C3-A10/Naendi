import Foundation

enum PersistentStoreRecovery {
    static func removeStore(at storeURL: URL, fileManager: FileManager = .default) throws {
        for url in storeFamilyURLs(for: storeURL) where fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    static func storeFamilyURLs(for storeURL: URL) -> [URL] {
        [
            storeURL,
            URL(fileURLWithPath: storeURL.path + "-shm"),
            URL(fileURLWithPath: storeURL.path + "-wal")
        ]
    }
}
