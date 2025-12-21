//
//  NetworkServiceTests.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import XCTest
@testable import Postie

final class NetworkServiceTests: XCTestCase {

    /// **Test: Logika Merapikan JSON (Pretty Print)**
    /// Algoritma: Memastikan string satu baris jadi berjenjang (indented).
    func testPrettyPrintJSONValid() {
        // 1. Arrange
        let rawJSON = "{\"id\":1,\"name\":\"Nunu\"}"
        
        // 2. Act
        let result = NetworkService.prettyPrintJSON(rawJSON)
        
        // 3. Assert (Cek apakah ada karakter newline dan spasi indentasi)
        XCTAssertTrue(result.contains("\n"), "Hasil harus memiliki baris baru")
        XCTAssertTrue(result.contains("  "), "Hasil harus memiliki spasi indentasi")
    }

    /// **Test: Penanganan JSON Rusak**
    /// Memastikan fungsi tidak crash dan mengembalikan string asli jika JSON tidak valid.
    func testPrettyPrintJSONInvalid() {
        let invalidJSON = "{ ini bukan json }"
        let result = NetworkService.prettyPrintJSON(invalidJSON)
        XCTAssertEqual(result, invalidJSON, "Jika gagal, harus balikkan string asli")
    }

    /// **Test: Validasi URL Kosong atau Spasi**
    /// Memastikan service melempar error PostieError.invalidURL.
    func testPerformRequestInvalidURL() async {
        let messyURL = "   "
        
        do {
            _ = try await NetworkService.performRequest(
                url: messyURL,
                method: "GET",
                headers: [:],
                body: nil
            )
            XCTFail("Harusnya melempar error invalidURL")
        } catch let error as PostieError {
            XCTAssertEqual(error.localizedDescription, "Format URL tidak valid.")
        } catch {
            XCTFail("Error yang dilempar salah jenis")
        }
    }
}
