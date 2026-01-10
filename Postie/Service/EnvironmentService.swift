//
//  EnvironmentService.swift
//  Postie
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation

struct EnvironmentService {
    
    private static let environmentsFileName = "environments.json"
    
    private static func getEnvironmentsFileURL() throws -> URL {
        let fileManager = FileManager.default
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw PostieError.unknown("Could not find application support directory.")
        }
        
        let appDirectory = appSupportURL.appendingPathComponent("Postie")
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        return appDirectory.appendingPathComponent(environmentsFileName)
    }
    
    static func load() -> [PostieEnvironment] {
        do {
            let fileURL = try getEnvironmentsFileURL()
            let data = try Data(contentsOf: fileURL)
            let environments = try JSONDecoder().decode([PostieEnvironment].self, from: data)
            return environments
        } catch {
            return [
                PostieEnvironment(name: "Default", variables: ["baseURL": "https://jsonplaceholder.typicode.com"])
            ]
        }
    }
    
    static func save(environments: [PostieEnvironment]) {
        do {
            let fileURL = try getEnvironmentsFileURL()
            let data = try JSONEncoder().encode(environments)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save environments: \(error.localizedDescription)")
        }
    }
}