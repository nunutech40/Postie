//
//  HomeViewModel.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Combine
import Foundation
import SwiftUI // Pake SwiftUI aja buat ObservableObject

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
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // --- DOWNLOAD STATE ---
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading = false
    @Published var downloadInfo: String = ""
    @Published var totalBytesKnown: Bool = false
    
    let methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
    
    // --- MAIN ACTION: SEND REAL REQUEST ---
    @discardableResult
    @MainActor
    func runRealRequest() -> Task<Void, Never> {
        self.isLoading = true
        self.errorMessage = nil
        // Paksa nil dan pastikan tidak ada referensi yang nyangkut
        if self.response != nil {
            self.response = nil
        }
        
        return Task {
            do {
                var headers = parseHeaders(rawText: rawHeaders)
                if !authToken.isEmpty {
                    headers["Authorization"] = "Bearer \(authToken)"
                }
                
                let result = try await NetworkService.performRequest(
                    url: urlString,
                    method: selectedMethod,
                    headers: headers,
                    body: requestBody
                )
                
                self.response = result
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // --- HELPER LOGIC ---
    func parseHeaders(rawText: String) -> [String: String] {
        var dict = [String: String]()
        let lines = rawText.split(separator: "\n")
        
        for line in lines {
            let parts = line.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let val = parts[1].trimmingCharacters(in: .whitespaces)
                dict[key] = val
            }
        }
        return dict
    }
    
    // --- CLEAN PRESET LOGIC ---
    
    @MainActor
    func savePreset() {
        // 1. Minta URL ke spesialis jendela (FileService)
        guard let url = FileService.getSaveURL() else { return }
        
        // 2. Bungkus data
        let preset = RequestPreset(
            method: self.selectedMethod,
            url: self.urlString,
            authToken: self.authToken,
            rawHeaders: self.rawHeaders,
            requestBody: self.requestBody
        )
        
        // 3. Suruh PresetService simpan ke disk
        do {
            try PresetService.save(preset: preset, to: url)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func loadPreset() {
        // 1. Minta URL ke spesialis jendela (FileService)
        guard let url = FileService.getOpenURL() else { return }
        
        // 2. Suruh PresetService baca data
        do {
            let preset = try PresetService.load(from: url)
            
            // 3. Update State (UI otomatis berubah)
            self.selectedMethod = preset.method
            self.urlString = preset.url
            self.authToken = preset.authToken
            self.rawHeaders = preset.rawHeaders
            self.requestBody = preset.requestBody
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    // --- DOWNLOAD ACTION ---
    @MainActor
    func runDownload() async {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            self.errorMessage = "URL Invalid"
            return
        }
        
        self.isDownloading = true
        self.downloadProgress = 0.0
        self.downloadInfo = "Starting download..."
        
        // Memanggil NetworkService yang mengembalikan AsyncStream
        let stream = NetworkService.downloadWithProgress(url: url)
        
        for await update in stream {
            switch update {
            case .progress(let percent, let info):
                self.totalBytesKnown = true
                self.downloadProgress = percent
                self.downloadInfo = info
            case .indeterminate(let info):
                self.totalBytesKnown = false
                self.downloadInfo = info
            case .finished:
                self.downloadInfo = "Download Complete"
            case .error(let msg):
                self.errorMessage = msg
            }
        }
        
        self.isDownloading = false
    }
}
