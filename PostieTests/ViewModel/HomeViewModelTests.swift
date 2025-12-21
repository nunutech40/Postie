//
//  HomeViewModelTests.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import XCTest
@testable import Postie

final class HomeViewModelTests: XCTestCase {
    
    var sut: HomeViewModel!

    override func setUp() {
        super.setUp()
        sut = HomeViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// **Test: Logic Parsing Headers**
    /// Kasus: User memasukkan spasi liar, baris kosong, dan format berantakan.
    func testParseHeadersCleaningLogic() {
        // 1. Arrange
        let messyHeaders = """
        Content-Type: application/json
        X-Api-Key :  123456  
        
        Accept: */*
        """
        
        // 2. Act
        let result = sut.parseHeaders(rawText: messyHeaders)

        // 3. Assert
        XCTAssertEqual(result.count, 3, "Harus ada 3 header yang valid.")
        XCTAssertEqual(result["Content-Type"], "application/json")
        XCTAssertEqual(result["X-Api-Key"], "123456", "Spasi di key dan value harus dibersihkan.")
        XCTAssertEqual(result["Accept"], "*/*")
    }

    /// **Test: State Management (Loading Indicator)**
    /// Memastikan 'isLoading' benar-benar true saat kirim dan false saat selesai.
    @MainActor
    func testLoadingStateSequence() async {
        // 1. ARRANGE
        sut.urlString = "https://invalid-url-buat-test.com"
        
        // 2. ACT
        XCTAssertFalse(sut.isLoading)
        
        // Tangkap task-nya dan AWAIT sampai beneran beres
        let task = sut.runRealRequest()
        
        // Cek saat sedang jalan (Harus True)
        XCTAssertTrue(sut.isLoading, "Harus true saat request baru saja dipicu")
        
        // TUNGGU sampai Task internal selesai secara total
        await task.value
        
        // 3. ASSERT FINAL
        XCTAssertFalse(sut.isLoading, "Harus kembali false karena task.value sudah selesai")
    }
}
