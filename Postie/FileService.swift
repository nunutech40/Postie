//
//  FileService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import AppKit
import Foundation

struct FileService {
    
    @MainActor
    static func getSaveURL() -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "request-api.json"
        panel.title = "Save Request Preset"
        
        // Pakai runModal supaya simpel dan synchronous saat dipanggil
        return panel.runModal() == .OK ? panel.url : nil
    }
    
    @MainActor
    static func getOpenURL() -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.title = "Load Request Preset"
        
        return panel.runModal() == .OK ? panel.url : nil
    }
}
