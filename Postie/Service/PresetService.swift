//
//  PresetService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Foundation

// 1. DEFINISIKAN STRUCT-NYA DI SINI
struct RequestPreset: Codable {
    let method: String
    let url: String
    let authToken: String
    let rawHeaders: String
    let requestBody: String
}

struct PresetService {
    
    /// **Logic: Disk Persistence (Write)**
    /// Mengonversi objek Swift `RequestPreset` menjadi file fisik di disk.
    /// 1. **Encoding**: Menggunakan `JSONEncoder` untuk mengubah struct menjadi format `Data` (JSON).
    /// 2. **I/O**: Menulis data tersebut ke URL yang diberikan (didapat dari FileService).
    static func save(preset: RequestPreset, to url: URL) throws {
        let data = try JSONEncoder().encode(preset)
        try data.write(to: url)
    }

    /// **Logic: Disk Persistence (Read)**
    /// Mengambil data dari disk dan mengonversinya kembali ke objek Swift.
    /// 1. **Data Loading**: Membaca bitstream dari file di URL tertentu.
    /// 2. **Decoding**: Menggunakan `JSONDecoder` untuk memetakan JSON kembali ke struktur `RequestPreset`.
    static func load(from url: URL) throws -> RequestPreset {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(RequestPreset.self, from: data)
    }
}
