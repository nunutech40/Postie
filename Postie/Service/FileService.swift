//
//  FileService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import AppKit
import Foundation

struct FileService {
    
    /// **Logic: Save Dialog Interface**
    /// Membuka jendela dialog standar macOS untuk menentukan lokasi simpan file.
    /// 1. Membatasi tipe file hanya ke `.json`.
    /// 2. `runModal()`: Memblokir eksekusi sementara sampai user menekan Save/Cancel.
    /// 3. Mengembalikan URL lokasi file yang dipilih oleh user.
    @MainActor
    static func getSaveURL() -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "request-api.json"
        panel.title = "Save Request Preset"
        
        return panel.runModal() == .OK ? panel.url : nil
    }
    
    /// **Logic: Open Dialog Interface**
    /// Membuka jendela dialog standar macOS untuk memilih file yang akan dibuka.
    /// 1. `allowsMultipleSelection = false`: Memastikan hanya satu file yang dimuat dalam satu waktu.
    /// 2. Filter file `.json` untuk mencegah user memilih file yang tidak kompatibel.
    @MainActor
    static func getOpenURL() -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.title = "Load Request Preset"
        
        return panel.runModal() == .OK ? panel.url : nil
    }
}
