//
//  HistoryService.swift
//  Postie
//
//  Created by Nunu Nugraha on 24/12/25.
//

import Foundation

struct HistoryService {
    
    private static let historyFileName = "request-history.json"
    private static let maxHistoryCount = 10
    
    private static func getHistoryFileURL() throws -> URL {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw PostieError.unknown("Could not find application support directory.")
        }
        
        let appDirectory = appSupportURL.appendingPathComponent("Postie")
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return appDirectory.appendingPathComponent(historyFileName)
    }
    
    static func load() -> [RequestPreset] {
        do {
            let fileURL = try getHistoryFileURL()
            let data = try Data(contentsOf: fileURL)
            let history = try JSONDecoder().decode([RequestPreset].self, from: data)
            return history
        } catch {
            // It's okay if the file doesn't exist or is invalid, just return an empty array.
            return []
        }
    }
    
    static func save(history: [RequestPreset]) {
        do {
            let fileURL = try getHistoryFileURL()
            var historyToSave = history
            if historyToSave.count > maxHistoryCount {
                historyToSave = Array(historyToSave.prefix(maxHistoryCount))
            }
            let data = try JSONEncoder().encode(historyToSave)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Log the error or handle it as needed. For now, we'll just print it.
            print("Failed to save history: \(error.localizedDescription)")
        }
    }
    
    static func add(request: RequestPreset, to history: [RequestPreset]) -> [RequestPreset] {
        var updatedHistory = history
        
        // Remove existing item if it's the same based on content, not ID
        updatedHistory.removeAll { $0.url == request.url && $0.method == request.method && $0.requestBody == request.requestBody && $0.rawHeaders == request.rawHeaders && $0.authToken == request.authToken }
        
        // Add new request to the top
        updatedHistory.insert(request, at: 0)
        
        // Trim to max count
        if updatedHistory.count > maxHistoryCount {
            updatedHistory = Array(updatedHistory.prefix(maxHistoryCount))
        }
        
        return updatedHistory
    }
}
