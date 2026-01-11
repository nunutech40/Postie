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
    
    // --- SEARCH ---
    @Published var searchQuery: String = ""
    @Published var showSearch: Bool = false
    
    // --- RESPONSE FORMATTING ---
    @Published var showRawResponse: Bool = false // Toggle between raw/formatted
    
    let methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
    
    private var currentRequestTask: Task<Void, Never>?
    private var currentDownloadTask: Task<Void, Never>?
    
    init() {
        self.requestHistory = HistoryService.load().sorted(by: { $0.timestamp > $1.timestamp })
        self.environments = EnvironmentService.load()
        if self.selectedEnvironmentID == nil {
            self.selectedEnvironmentID = self.environments.first?.id
        }

        if let cachedRequest = RequestCacheService.load() {
            self.selectedMethod = cachedRequest.method
            self.urlString = cachedRequest.url
            self.authToken = cachedRequest.authToken
            self.rawHeaders = cachedRequest.rawHeaders
            self.requestBody = cachedRequest.requestBody
        }
    }
    
    @MainActor
    func initializeCollections() {
        self.collections = CollectionService.loadAuto() // Attempt to load saved collections first
        
        if collections.isEmpty { // If no collections were loaded, create a default
            self.collections = [
                RequestCollection(name: "My Collection", requests: [])
            ]
        }
        selectFirstCollection()
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
    // (Removed savePreset and loadPreset functions as per user request)
    
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
    @Published var showingNewCollectionAlert = false
    @Published var newCollectionName = ""
    @Published var showingDeleteCollectionAlert = false
    @Published var collectionToDeleteID: UUID?
    @Published var showingRenameCollectionAlert = false
    @Published var collectionToRenameID: UUID?
    @Published var newCollectionEditedName = ""

    @MainActor
    func loadCollections() {
        guard let url = FileService.getOpenURL() else { return }
        
        do {
            let loadedCollections = try CollectionService.load(from: url)
            self.collections = loadedCollections
            selectFirstCollection()
            // No auto-save here, as this is a user-initiated load. Auto-save will happen on modifications.
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func saveCollections() {
        guard let url = FileService.getSaveURL() else { return }
        
        do {
            try CollectionService.save(collections: self.collections, to: url)
            showToast(message: "Collections Saved")
            // No auto-save here, as this is a user-initiated save. Auto-save is handled internally.
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func showAddCollectionAlert() {
        self.newCollectionName = "" // Clear previous input
        self.showingNewCollectionAlert = true
    }

    @MainActor
    func createCollection(name: String) {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.errorMessage = "Collection name cannot be empty."
            return
        }
        if collections.contains(where: { $0.name == name }) {
            self.errorMessage = "Collection with this name already exists."
            return
        }
        let newCollection = RequestCollection(name: name, requests: [])
        self.collections.append(newCollection)
        self.selectedCollectionID = newCollection.id
        self.editingCollectionID = newCollection.id // No longer needed for explicit TextField, but can be used for initial state.
        CollectionService.saveAuto(collections: collections) // AUTO-SAVE
    }
    
    @MainActor
    func confirmDeleteCollection(id: UUID) {
        self.collectionToDeleteID = id
        self.showingDeleteCollectionAlert = true
    }
    
    @MainActor
    func performDeleteCollection() {
        guard let id = collectionToDeleteID else { return }
        self.collections.removeAll(where: { $0.id == id })
        self.collectionToDeleteID = nil
        selectFirstCollection()
        CollectionService.saveAuto(collections: collections) // AUTO-SAVE
    }
    
    @MainActor
    func confirmRenameCollection(id: UUID) {
        self.collectionToRenameID = id
        if let collection = collections.first(where: { $0.id == id }) {
            self.newCollectionEditedName = collection.name
        }
        self.showingRenameCollectionAlert = true
    }
    
    @MainActor
    func performRenameCollection() {
        guard let id = collectionToRenameID else { return }
        if newCollectionEditedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.errorMessage = "Collection name cannot be empty."
            return
        }
        if collections.contains(where: { $0.name == newCollectionEditedName && $0.id != id }) {
            self.errorMessage = "Collection with this name already exists."
            return
        }
        if let index = collections.firstIndex(where: { $0.id == id }) {
            collections[index].name = newCollectionEditedName
        }
        self.collectionToRenameID = nil
        self.newCollectionEditedName = ""
        showToast(message: "Collection Renamed")
        CollectionService.saveAuto(collections: collections) // AUTO-SAVE
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
            CollectionService.saveAuto(collections: collections) // AUTO-SAVE
        }
    }
    
    @MainActor
    func loadRequestFromCollection(request: RequestPreset) {
        self.selectedMethod = request.method
        self.urlString = request.url
        self.authToken = request.authToken
        self.rawHeaders = request.rawHeaders
        self.requestBody = request.requestBody
    }
    
    @MainActor
    func deleteRequestFromCollection(id: UUID) {
        guard let collectionIndex = selectedCollectionIndex else { return }
        collections[collectionIndex].requests.removeAll(where: { $0.id == id })
        CollectionService.saveAuto(collections: collections) // AUTO-SAVE
    }
    
    @MainActor
    func deleteRequestFromCollection(at offsets: IndexSet) {
        guard let collectionIndex = selectedCollectionIndex else { return }
        collections[collectionIndex].requests.remove(atOffsets: offsets)
        CollectionService.saveAuto(collections: collections) // AUTO-SAVE
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
    
    // MARK: - Helper Functions
    
    /// Show toast message with auto-dismiss
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        // Auto-dismiss after 2 seconds
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showToast = false
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
    
    // MARK: - Response Actions
    
    /// Copy response body to clipboard
    func copyResponseToClipboard() {
        guard let response = response else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(response.body, forType: .string)
        
        showToastMessage("Response copied to clipboard")
    }
    
    /// Export response to file
    func exportResponse() {
        guard let response = response else { return }
        
        let savePanel = NSSavePanel()
        savePanel.title = "Export Response"
        savePanel.nameFieldStringValue = "response.json"
        savePanel.canCreateDirectories = true
        savePanel.allowedContentTypes = [.json, .plainText]
        
        savePanel.begin { result in
            guard result == .OK, let url = savePanel.url else { return }
            
            do {
                try response.body.write(to: url, atomically: true, encoding: .utf8)
                self.showToastMessage("Response exported successfully")
            } catch {
                self.errorMessage = "Failed to export: \(error.localizedDescription)"
            }
        }
    }
}
