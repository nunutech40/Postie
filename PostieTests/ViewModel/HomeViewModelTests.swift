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
    func testLoadingStateSequenceCombine() async {
        // 1. ARRANGE
        // Pakai URL yang pasti gagal INSTAN (tanpa nunggu timeout koneksi)
        sut.urlString = ""
        
        let expectationStarted = XCTestExpectation(description: "Spinner harus NYALA (true)")
        let expectationFinished = XCTestExpectation(description: "Spinner harus MATI (false)")
        
        // 2. ACT: Gunakan sink yang lebih cerdas
        var hasStarted = false
        let cancellable = sut.$isLoading
            .dropFirst() // Abaikan nilai awal (false)
            .sink { isLoading in
                if isLoading && !hasStarted {
                    hasStarted = true
                    expectationStarted.fulfill()
                } else if !isLoading && hasStarted {
                    expectationFinished.fulfill()
                }
            }
        
        // Jalankan request
        sut.runRealRequest()
        
        // 3. ASSERT: Tunggu kedua checkpoint terpenuhi
        // Gunakan timeout yang lebih manusiawi untuk networking (misal 5 detik)
        await fulfillment(of: [expectationStarted, expectationFinished], timeout: 5.0, enforceOrder: true)
        
        XCTAssertFalse(sut.isLoading)
        cancellable.cancel()
    }
}
