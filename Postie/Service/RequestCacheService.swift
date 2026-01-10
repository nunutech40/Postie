//
//  RequestCacheService.swift
//  Postie
//
//  Created by Nunu Nugraha on 26/12/25.
//

import Foundation

struct RequestCacheService {
    
    private static let cacheFileName = "last-request-cache.json"
    
    private static func getCacheFileURL() throws -> URL {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw PostieError.unknown("Could not find application support directory.")
        }
        
        let appDirectory = appSupportURL.appendingPathComponent("Postie")
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return appDirectory.appendingPathComponent(cacheFileName)
    }
    
    static func load() -> RequestPreset? {
        do {
            let fileURL = try getCacheFileURL()
            let data = try Data(contentsOf: fileURL)
            let preset = try JSONDecoder().decode(RequestPreset.self, from: data)
            return preset
        } catch {
            return nil
        }
    }
    
    static func save(request: RequestPreset) {
        do {
            let fileURL = try getCacheFileURL()
            let data = try JSONEncoder().encode(request)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // It's okay to fail silently for a cache
            print("Failed to save request cache: \(error.localizedDescription)")
        }
    }
}
