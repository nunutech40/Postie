//
//  HomeViewModel.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Combine
import Foundation
import SwiftUI

// MARK: - Main ViewModel Class

class HomeViewModel: ObservableObject {
    
    // MARK: - Request Input State
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
    
    // MARK: - Request Output State
    @Published var response: APIResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Download State
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading = false
    @Published var downloadInfo: String = ""
    @Published var totalBytesKnown: Bool = false
    
    // MARK: - History State
    @Published var requestHistory: [RequestPreset] = []
    
    // MARK: - Collection State
    @Published var collections: [RequestCollection] = []
    @Published var selectedCollectionID: UUID?
    @Published var editingCollectionID: UUID?
    @Published var showingNewCollectionAlert = false
    @Published var newCollectionName = ""
    @Published var showingDeleteCollectionAlert = false
    @Published var collectionToDeleteID: UUID?
    @Published var showingRenameCollectionAlert = false
    @Published var collectionToRenameID: UUID?
    @Published var newCollectionEditedName = ""
    
    var selectedCollection: RequestCollection? {
        guard let selectedID = selectedCollectionID else { return nil }
        return collections.first { $0.id == selectedID }
    }
    
    var selectedCollectionIndex: Int? {
        guard let selectedID = selectedCollectionID else { return nil }
        return collections.firstIndex { $0.id == selectedID }
    }
    
    // MARK: - Environment State
    @Published var environments: [PostieEnvironment] = []
    @Published var selectedEnvironmentID: UUID?

    var selectedEnvironment: PostieEnvironment? {
        guard let selectedID = selectedEnvironmentID else { return nil }
        return environments.first { $0.id == selectedID }
    }
    
    // MARK: - UI State
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var searchQuery: String = ""
    @Published var showSearch: Bool = false
    @Published var showRawResponse: Bool = false
    
    // MARK: - Constants
    let methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
    
    // MARK: - Private Properties
    private var currentRequestTask: Task<Void, Never>?
    private var currentDownloadTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
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
        self.collections = CollectionService.loadAuto()
        
        if collections.isEmpty {
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
}

// MARK: - Request Execution

extension HomeViewModel {
    
    /// Execute HTTP request with current configuration
    @discardableResult
    @MainActor
    func runRealRequest() -> Task<Void, Never> {
        saveRequestToCache()
        
        // Cancel any existing request
        currentRequestTask?.cancel()
        
        self.isLoading = true
        self.errorMessage = nil
        self.response = nil
        
        currentRequestTask = Task {
            defer {
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
    
    /// Cancel ongoing request
    @MainActor
    func cancelRequest() {
        currentRequestTask?.cancel()
        self.isLoading = false
    }
    
    /// Parse raw headers text into dictionary
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
    
    /// Save current request configuration to cache
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
}

// MARK: - Download Management

extension HomeViewModel {
    
    /// Execute download with progress tracking
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
    
    /// Cancel ongoing download
    @MainActor
    func cancelDownload() {
        currentDownloadTask?.cancel()
        self.isDownloading = false
        self.downloadInfo = "Download cancelled."
    }
}

// MARK: - History Management

extension HomeViewModel {
    
    /// Add current request to history
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
    
    /// Load request from history into current form
    @MainActor
    func loadRequestFromHistory(request: RequestPreset) {
        self.selectedMethod = request.method
        self.urlString = request.url
        self.authToken = request.authToken
        self.rawHeaders = request.rawHeaders
        self.requestBody = request.requestBody
    }
}

// MARK: - Collection Management

extension HomeViewModel {
    
    /// Load collections from file
    @MainActor
    func loadCollections() {
        guard let url = FileService.getOpenURL() else { return }
        
        do {
            let loadedCollections = try CollectionService.load(from: url)
            self.collections = loadedCollections
            selectFirstCollection()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    /// Save collections to file
    @MainActor
    func saveCollections() {
        guard let url = FileService.getSaveURL() else { return }
        
        do {
            try CollectionService.save(collections: self.collections, to: url)
            showToast(message: "Collections Saved")
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    /// Show dialog to create new collection
    @MainActor
    func showAddCollectionAlert() {
        self.newCollectionName = ""
        self.showingNewCollectionAlert = true
    }

    /// Create new collection
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
        self.editingCollectionID = newCollection.id
        CollectionService.saveAuto(collections: collections)
    }
    
    /// Confirm collection deletion
    @MainActor
    func confirmDeleteCollection(id: UUID) {
        self.collectionToDeleteID = id
        self.showingDeleteCollectionAlert = true
    }
    
    /// Delete collection
    @MainActor
    func performDeleteCollection() {
        guard let id = collectionToDeleteID else { return }
        self.collections.removeAll(where: { $0.id == id })
        self.collectionToDeleteID = nil
        selectFirstCollection()
        CollectionService.saveAuto(collections: collections)
    }
    
    /// Confirm collection rename
    @MainActor
    func confirmRenameCollection(id: UUID) {
        self.collectionToRenameID = id
        if let collection = collections.first(where: { $0.id == id }) {
            self.newCollectionEditedName = collection.name
        }
        self.showingRenameCollectionAlert = true
    }
    
    /// Rename collection
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
        CollectionService.saveAuto(collections: collections)
    }
    
    /// Add current request to selected collection
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
            CollectionService.saveAuto(collections: collections)
        }
    }
    
    /// Load request from collection into current form
    @MainActor
    func loadRequestFromCollection(request: RequestPreset) {
        self.selectedMethod = request.method
        self.urlString = request.url
        self.authToken = request.authToken
        self.rawHeaders = request.rawHeaders
        self.requestBody = request.requestBody
    }
    
    /// Delete request from collection by ID
    @MainActor
    func deleteRequestFromCollection(id: UUID) {
        guard let collectionIndex = selectedCollectionIndex else { return }
        collections[collectionIndex].requests.removeAll(where: { $0.id == id })
        CollectionService.saveAuto(collections: collections)
    }
    
    /// Delete request from collection by index
    @MainActor
    func deleteRequestFromCollection(at offsets: IndexSet) {
        guard let collectionIndex = selectedCollectionIndex else { return }
        collections[collectionIndex].requests.remove(atOffsets: offsets)
        CollectionService.saveAuto(collections: collections)
    }
}

// MARK: - Environment Management

extension HomeViewModel {
    
    /// Add new environment
    @MainActor
    func addEnvironment(_ environment: PostieEnvironment) {
        environments.append(environment)
        forceSaveEnvironments()
    }
    
    /// Update existing environment
    @MainActor
    func updateEnvironment(_ environment: PostieEnvironment) {
        if let index = environments.firstIndex(where: { $0.id == environment.id }) {
            environments[index] = environment
            forceSaveEnvironments()
        }
    }
    
    /// Delete environment
    @MainActor
    func deleteEnvironment(at offsets: IndexSet) {
        environments.remove(atOffsets: offsets)
        forceSaveEnvironments()
    }
    
    /// Save environments and ensure valid selection
    func forceSaveEnvironments() {
        EnvironmentService.save(environments: environments)
        if selectedEnvironmentID == nil || !environments.contains(where: { $0.id == selectedEnvironmentID }) {
            selectedEnvironmentID = environments.first?.id
        }
    }
    
    /// Substitute environment variables in string
    private func substituteVariables(in string: String) -> String {
        guard let environment = selectedEnvironment else { return string }
        
        var result = string
        for (key, value) in environment.variables {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        
        return result
    }
}

// MARK: - Response Actions

extension HomeViewModel {
    
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

// MARK: - UI Helpers

extension HomeViewModel {
    
    /// Show toast notification
    func showToast(message: String) {
        self.toastMessage = message
        self.showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }
    
    /// Show toast message with auto-dismiss
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showToast = false
        }
    }
}
