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
    
    // --- HISTORY ---
    @Published var requestHistory: [RequestPreset] = []
    
    // --- COLLECTION ---
    @Published var collections: [RequestCollection] = []
    @Published var selectedCollectionID: UUID?
    @Published var editingCollectionID: UUID?
    
    var selectedCollection: RequestCollection? {
        guard let selectedID = selectedCollectionID else { return nil }
        return collections.first { $0.id == selectedID }
    }
    
    var selectedCollectionIndex: Int? {
        guard let selectedID = selectedCollectionID else { return nil }
        return collections.firstIndex { $0.id == selectedID }
    }
    
    // --- TOAST ---
    @Published var showToast = false
    @Published var toastMessage = ""
    
    // --- ENVIRONMENT ---
    @Published var environments: [PostieEnvironment] = []
    @Published var selectedEnvironmentID: UUID?

    var selectedEnvironment: PostieEnvironment? {
        guard let selectedID = selectedEnvironmentID else { return nil }
        return environments.first { $0.id == selectedID }
    }
    
    let methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
    
    private var currentRequestTask: Task<Void, Never>?
    private var currentDownloadTask: Task<Void, Never>?
    
    init() {
        self.requestHistory = HistoryService.load().sorted(by: { $0.timestamp > $1.timestamp })
        self.environments = EnvironmentService.load()
        if self.selectedEnvironmentID == nil {
            self.selectedEnvironmentID = self.environments.first?.id
        }
        
        // Load collections from a file or initialize with a default
        // For now, let's start with a default for testing
        if collections.isEmpty {
            self.collections = [
                RequestCollection(name: "My Collection", requests: [])
            ]
        }
        selectFirstCollection()

        if let cachedRequest = RequestCacheService.load() {
            self.selectedMethod = cachedRequest.method
            self.urlString = cachedRequest.url
            self.authToken = cachedRequest.authToken
            self.rawHeaders = cachedRequest.rawHeaders
            self.requestBody = cachedRequest.requestBody
        }
    }
    
    func selectFirstCollection() {
        if selectedCollectionID == nil {
            selectedCollectionID = collections.first?.id
        }
    }
    
    // --- MAIN ACTION: SEND REAL REQUEST ---
    @discardableResult
    @MainActor
    func runRealRequest() -> Task<Void, Never> {
        saveRequestToCache()
        
        // 1. Batalkan request yang masih jalan sebelum bikin yang baru
        currentRequestTask?.cancel()
        
        self.isLoading = true
        self.errorMessage = nil
        self.response = nil
        
        // 2. Simpan task baru ke variabel
        currentRequestTask = Task {
            // 3. Gunakan defer: loading PASTI berhenti mau sukses atau gagal
            defer {
                // Pastikan tidak mematikan loading milik task baru
                if !Task.isCancelled { self.isLoading = false }
            }
            
            do {
                let finalURL = substituteVariables(in: urlString)
                let finalAuthToken = substituteVariables(in: authToken)
                let finalRawHeaders = substituteVariables(in: rawHeaders)
                let finalRequestBody = substituteVariables(in: requestBody)
                
                let headers = parseHeaders(rawText: finalRawHeaders)
                let finalHeaders = !finalAuthToken.isEmpty ?
                headers.merging(["Authorization": "Bearer \(finalAuthToken)"]) { (_, new) in new } : headers
                
                let result = try await NetworkService.performRequest(
                    url: finalURL,
                    method: selectedMethod,
                    headers: finalHeaders,
                    body: finalRequestBody
                )
                
                // 4. Cek cancellation: Jangan update UI kalau task ini sudah dibatalkan
                if !Task.isCancelled {
                    self.response = result
                    addRequestToHistory(wasSuccessful: true)
                }
            } catch {
                if !Task.isCancelled {
                    addRequestToHistory(wasSuccessful: false)
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        return currentRequestTask!
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
    
    func showToast(message: String) {
        self.toastMessage = message
        self.showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
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
            requestBody: self.requestBody,
            wasSuccessful: true
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
    
    // --- HISTORY LOGIC ---
    @MainActor
    func addRequestToHistory(wasSuccessful: Bool) {
        let preset = RequestPreset(
            method: self.selectedMethod,
            url: self.urlString,
            authToken: self.authToken,
            rawHeaders: self.rawHeaders,
            requestBody: self.requestBody,
            wasSuccessful: wasSuccessful
        )
        
        self.requestHistory = HistoryService.add(request: preset, to: self.requestHistory)
        HistoryService.save(history: self.requestHistory)
    }
    
    @MainActor
    func loadRequestFromHistory(request: RequestPreset) {
        self.selectedMethod = request.method
        self.urlString = request.url
        self.authToken = request.authToken
        self.rawHeaders = request.rawHeaders
        self.requestBody = request.requestBody
    }

    private func saveRequestToCache() {
        let requestToCache = RequestPreset(
            method: self.selectedMethod,
            url: self.urlString,
            authToken: self.authToken,
            rawHeaders: self.rawHeaders,
            requestBody: self.requestBody
        )
        RequestCacheService.save(request: requestToCache)
    }
    
    // --- COLLECTION LOGIC ---
    @MainActor
    func loadCollections() {
        guard let url = FileService.getOpenURL() else { return }
        
        do {
            // This will require CollectionService.load to be updated
            let loadedCollections = try CollectionService.load(from: url)
            self.collections = loadedCollections
            selectFirstCollection()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func saveCollections() {
        guard let url = FileService.getSaveURL() else { return }
        
        do {
            // This will require CollectionService.save to be updated
            try CollectionService.save(collections: self.collections, to: url)
            showToast(message: "Collections Saved")
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func addNewCollection() {
        let newCollection = RequestCollection(name: "New Collection", requests: [])
        self.collections.append(newCollection)
        self.selectedCollectionID = newCollection.id
        self.editingCollectionID = newCollection.id
    }
    
    @MainActor
    func deleteCollection(at offsets: IndexSet) {
        self.collections.remove(atOffsets: offsets)
        selectFirstCollection()
    }
    
    @MainActor
    func addCurrentRequestToCollection() {
        guard let index = selectedCollectionIndex else {
            showToast(message: "No Collection Selected")
            return
        }
        
        let preset = RequestPreset(
            method: self.selectedMethod,
            url: self.urlString,
            authToken: self.authToken,
            rawHeaders: self.rawHeaders,
            requestBody: self.requestBody
        )
        
        if collections[index].requests.contains(preset) {
            showToast(message: "Request already in collection")
        } else {
            self.collections[index].requests.append(preset)
            showToast(message: "Request Added")
        }
    }
    
    @MainActor
    func deleteRequestFromCollection(at offsets: IndexSet) {
        guard let index = selectedCollectionIndex else { return }
        self.collections[index].requests.remove(atOffsets: offsets)
    }
    
    @MainActor
    func loadRequestFromCollection(request: RequestPreset) {
        self.selectedMethod = request.method
        self.urlString = request.url
        self.authToken = request.authToken
        self.rawHeaders = request.rawHeaders
        self.requestBody = request.requestBody
    }
    
    // --- DOWNLOAD ACTION ---
    @MainActor
    func runDownload() {
        saveRequestToCache()
        
        currentDownloadTask?.cancel()
        
        currentDownloadTask = Task {
            let finalURL = substituteVariables(in: urlString)
            guard let url = URL(string: finalURL.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                self.errorMessage = "URL Invalid"
                return
            }
            
            self.isDownloading = true
            defer { self.isDownloading = false }
            
            let stream = NetworkService.downloadWithProgress(url: url)
            
            for await update in stream {
                // 5. Penting: Berhenti iterasi kalau task dibatalkan
                if Task.isCancelled { break }
                
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
        }
    }
    
    // --- CANCELLATION LOGIC ---
    @MainActor
    func cancelRequest() {
        currentRequestTask?.cancel()
        self.isLoading = false
    }
    
    @MainActor
    func cancelDownload() {
        currentDownloadTask?.cancel()
        self.isDownloading = false
        self.downloadInfo = "Download cancelled."
    }
    
    // --- ENVIRONMENT LOGIC ---
    @MainActor
    func addEnvironment(_ environment: PostieEnvironment) {
        environments.append(environment)
        forceSaveEnvironments()
    }
    
    @MainActor
    func updateEnvironment(_ environment: PostieEnvironment) {
        if let index = environments.firstIndex(where: { $0.id == environment.id }) {
            environments[index] = environment
            forceSaveEnvironments()
        }
    }
    
    @MainActor
    func deleteEnvironment(at offsets: IndexSet) {
        environments.remove(atOffsets: offsets)
        forceSaveEnvironments()
    }
    
    func forceSaveEnvironments() {
        EnvironmentService.save(environments: environments)
        if selectedEnvironmentID == nil || !environments.contains(where: { $0.id == selectedEnvironmentID }) {
            selectedEnvironmentID = environments.first?.id
        }
    }
    
    private func substituteVariables(in string: String) -> String {
        guard let environment = selectedEnvironment else { return string }
        
        var result = string
        for (key, value) in environment.variables {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        
        return result
    }
}
