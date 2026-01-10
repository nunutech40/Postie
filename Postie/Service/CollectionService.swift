//
//  CollectionService.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import Foundation

struct CollectionService {
    
    private static let collectionsFileName = "collections.json"
    
    private static func getCollectionsFileURL() throws -> URL {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw PostieError.unknown("Could not find application support directory.")
        }
        
        let appDirectory = appSupportURL.appendingPathComponent("Postie")
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return appDirectory.appendingPathComponent(collectionsFileName)
    }
    
    // For user-initiated save/load
    static func save(collections: [RequestCollection], to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(collections)
        try data.write(to: url)
    }

    // For user-initiated save/load
    static func load(from url: URL) throws -> [RequestCollection] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([RequestCollection].self, from: data)
    }
    
    // For auto-persistence
    static func loadAuto() -> [RequestCollection] {
        do {
            let fileURL = try getCollectionsFileURL()
            let data = try Data(contentsOf: fileURL)
            let collections = try JSONDecoder().decode([RequestCollection].self, from: data)
            return collections
        } catch {
            print("Failed to load collections automatically: \(error.localizedDescription)")
            return []
        }
    }
    
    // For auto-persistence
    static func saveAuto(collections: [RequestCollection]) {
        do {
            let fileURL = try getCollectionsFileURL()
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(collections)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save collections automatically: \(error.localizedDescription)")
        }
    }
}