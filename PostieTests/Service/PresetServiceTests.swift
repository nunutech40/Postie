//
//  PresetServiceTests.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import XCTest
@testable import Postie // Pastikan nama project lo benar

final class PresetServiceTests: XCTestCase {

    // Helper untuk membuat URL file sementara di folder /tmp macOS
    var temporaryFileURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("test-preset.json")
    }

    /// **Test: Integrity of Save and Load**
    /// Algoritma:
    /// 1. Buat dummy data RequestPreset.
    /// 2. Simpan ke folder temporary.
    /// 3. Baca kembali file tersebut.
    /// 4. Bandingkan apakah data asli == data yang dibaca.
    func testSaveAndLoadPreset() throws {
        // 1. ARRANGE (Siapkan data)
        let originalPreset = RequestPreset(
            method: "POST",
            url: "https://api.test.com",
            authToken: "secret-token",
            rawHeaders: "Content-Type: application/json",
            requestBody: "{\"name\": \"test\"}"
        )
        
        let fileURL = temporaryFileURL

        // 2. ACT (Lakukan aksi)
        try PresetService.save(preset: originalPreset, to: fileURL)
        let loadedPreset = try PresetService.load(from: fileURL)

        // 3. ASSERT (Validasi hasil)
        XCTAssertEqual(originalPreset.method, loadedPreset.method, "Method harus sama")
        XCTAssertEqual(originalPreset.url, loadedPreset.url, "URL harus sama")
        XCTAssertEqual(originalPreset.authToken, loadedPreset.authToken, "Token harus sama")
        XCTAssertEqual(originalPreset.requestBody, loadedPreset.requestBody, "Body harus sama")
        
        // Cleanup: Hapus file setelah tes selesai
        try? FileManager.default.removeItem(at: fileURL)
    }

    /// **Test: Handling Corrupted Data**
    /// Memastikan PresetService melempar error jika file yang dibaca bukan JSON yang valid.
    func testLoadInvalidJSONThrowsError() throws {
        let fileURL = temporaryFileURL
        let invalidData = "ini bukan json".data(using: .utf8)!
        
        try invalidData.write(to: fileURL)
        
        // Assert: Harus melempar error saat di-load
        XCTAssertThrowsError(try PresetService.load(from: fileURL)) { error in
            print("✅ Berhasil menangkap error sesuai ekspektasi: \(error)")
        }
        
        try? FileManager.default.removeItem(at: fileURL)
    }
}
