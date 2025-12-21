//
//  HomeViewModel.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Combine
import Foundation

class HomeViewModel: ObservableObject {
    
    // --- INPUTS ---
    @Published var selectedMethod = "POST"
    @Published var urlString = "https://jsonplaceholder.typicode.com/posts"
    @Published var authToken = ""
    @Published var rawHeaders = "User-Agent: Postie-iOS\nAccept: application/json"
    @Published var requestBody = """
    {
      "title": "foo",
      "body": "bar",
      "userId": 1
    }
    """
    
    // --- OUTPUTS ---
    @Published var response: APIResponse?
    @Published var isLoading = false      // Tambahan: Buat indikator loading
    @Published var errorMessage: String?  // Tambahan: Buat nampilin error alert
    
    let methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
    
    // --- MAIN ACTION: SEND REAL REQUEST ---
    @MainActor // Wajib: Biar update UI terjadi di Main Thread
    func runRealRequest() {
        self.isLoading = true
        self.errorMessage = nil
        self.response = nil
        
        Task {
            do {
                // 1. Siapin Headers (Parsing dari TextEditor)
                var headers = parseHeaders(rawText: rawHeaders)
                
                // Inject Token otomatis kalo diisi user
                if !authToken.isEmpty {
                    headers["Authorization"] = "Bearer \(authToken)"
                }
                
                // 2. Panggil NetworkService (The Engine)
                // Kita pake 'await' karena ini butuh waktu (async)
                let result = try await NetworkService.performRequest(
                    url: urlString,
                    method: selectedMethod,
                    headers: headers,
                    body: requestBody
                )
                
                // 3. Sukses! Update UI
                self.response = result
                self.isLoading = false
                
            } catch {
                // 4. Gagal (Misal internet mati / URL ngawur)
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // --- HELPER LOGIC ---
    
    // Ubah text "Key: Value" jadi Dictionary ["Key": "Value"]
    private func parseHeaders(rawText: String) -> [String: String] {
        var dict = [String: String]()
        let lines = rawText.split(separator: "\n")
        
        for line in lines {
            // Split cuma di titik dua pertama
            let parts = line.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let val = parts[1].trimmingCharacters(in: .whitespaces)
                dict[key] = val
            }
        }
        return dict
    }
}
