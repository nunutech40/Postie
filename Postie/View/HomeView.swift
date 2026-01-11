//
//  HomeView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import SwiftUI

// MARK: - MAIN VIEW (The Container)
struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    // 1. STATE BUAT BUKA SETTINGS
    @State private var showSettings = false
    @State private var isShowingCollectionView = false
    
    var body: some View {
        HStack(spacing: 0) {
            // 1. LEFT COLUMN: Configuration
            RequestSidebar(viewModel: viewModel)
                .frame(width: 400)
                .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // 2. RIGHT COLUMN: Result
            ResponsePanel(viewModel: viewModel)
                .background(Color(NSColor.controlBackgroundColor))
        }
        // 2. TAMBAH TOOLBAR DI POJOK KANAN ATAS
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isShowingCollectionView = true
                }) {
                    Image(systemName: "folder.badge.plus")
                        .foregroundColor(.secondary)
                }
                .help("Collection") // Tooltip pas di hover mouse
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.secondary)
                }
                .help("Settings & Guide") // Tooltip pas di hover mouse
            }
        }
        .sheet(isPresented: $isShowingCollectionView) {
            CollectionView(viewModel: viewModel)
        }
        // 3. SHEET PEMANGGIL SETTINGS
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: viewModel)
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let msg = viewModel.errorMessage {
                Text(msg)
            }
        }
    }
}

struct RequestSidebar: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TargetSectionView(viewModel: viewModel)
                    Divider()
                    HeadersSectionView(viewModel: viewModel)
                    Divider()
                    BodySectionView(viewModel: viewModel)
                }
                .padding()
            }
            
            // Di dalam RequestSidebar (HomeView.swift)
            SendButtonView(
                action: {
                    // Logika Deteksi: File Gede vs JSON Biasa
                    if viewModel.urlString.contains(".zip") ||
                        viewModel.urlString.contains(".mp4") ||
                        viewModel.urlString.contains("bytes=") {
                        Task { viewModel.runDownload() }
                    } else {
                        viewModel.runRealRequest()
                    }
                },
                // Pastikan tombol sadar kalau lagi download ATAU lagi request biasa
                isLoading: viewModel.isLoading || viewModel.isDownloading
            )
        }
    }
}

// MARK: - COMPONENT 2: RIGHT PANEL (Result)
struct ResponsePanel: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            Color(NSColor.controlBackgroundColor).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // --- KASUS 1: SEDANG DOWNLOAD ---
                if viewModel.isDownloading {
                    Spacer()
                    DownloadProgressView(viewModel: viewModel)
                    Spacer()
                }
                // --- KASUS 2: ADA RESPON ---
                else if let response = viewModel.response {
                    VStack(alignment: .leading, spacing: 0) {
                        ResponseHeaderView(response: response, viewModel: viewModel)
                        Divider()
                        ResponseRendererView(response: response, viewModel: viewModel)
                    }
                }
                // --- KASUS 3: KOSONG ---
                else {
                    EmptyStateView()
                }
            }
        }
    }
}

// ==========================================
// SUB-COMPONENTS (ATOMIC VIEWS)
// ==========================================

struct ResponseRendererView: View {
    let response: APIResponse
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar (hanya untuk text-based responses)
            let contentType = response.headers["Content-Type"] ?? ""
            let isTextBased = contentType.contains("application/json") || 
                              contentType.contains("text/") || 
                              contentType.isEmpty
            
            if isTextBased {
                SearchBarView(viewModel: viewModel)
            }
            
            // Content Renderer
            if contentType.contains("application/json") {
                // Kasus 1: JSON (Pretty Print)
                NativeTextView(
                    text: response.body,
                    searchQuery: $viewModel.searchQuery,
                    showSearch: $viewModel.showSearch
                )
            } else if contentType.contains("text/html") {
                // Kasus 2: HTML
                WebView(htmlString: response.body)
            } else if contentType.starts(with: "image/") {
                // Kasus 3: Gambar (PNG, JPEG, dll)
                if let nsImage = NSImage(data: response.rawData) {
                    ScrollView {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                } else {
                    // Fallback jika data gambar rusak
                    NativeTextView(
                        text: "Failed to load image data.",
                        searchQuery: $viewModel.searchQuery,
                        showSearch: $viewModel.showSearch
                    )
                }
            } else {
                // Kasus 4: Fallback ke plain text
                NativeTextView(
                    text: response.body,
                    searchQuery: $viewModel.searchQuery,
                    showSearch: $viewModel.showSearch
                )
            }
        }
    }
}

// MARK: - Search Bar Component
struct SearchBarView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        if viewModel.showSearch {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
                
                TextField("Search in response...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: {
                    viewModel.showSearch = false
                    viewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .bottom
            )
        }
    }
}

// MARK: - Sidebar Components
struct TargetSectionView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showHistory = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // --- HEADER DENGAN ICON YANG LURUS & PRO ---
            HStack(alignment: .center) {
                SectionHeader(title: "TARGET")
                    .frame(maxHeight: .infinity)
                
                Spacer()
                
                // Group Tombol dengan frame yang konsisten
                HStack(spacing: 14) {
                    // Clear URL Button
                    if !viewModel.urlString.isEmpty {
                        Button(action: { 
                            viewModel.urlString = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                                .frame(width: 18, height: 18)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                        .help("Clear URL")
                    }
                    
                    Button(action: { showHistory = true }) {
                        Image(systemName: "clock")
                            .font(.system(size: 13, weight: .medium))
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .help("Request History")
                    .popover(isPresented: $showHistory, arrowEdge: .bottom) {
                        HistoryView(viewModel: viewModel, showHistory: $showHistory)
                    }
                }
            }
            .frame(height: 20)
            .padding(.bottom, 4)
            
            // --- METHOD & URL INPUT ---
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Picker("", selection: $viewModel.selectedMethod) {
                        ForEach(viewModel.methods, id: \.self) { m in Text(m) }
                    }
                    .labelsHidden()
                    .frame(width: 90)
                    .pickerStyle(.menu)

                    if !viewModel.environments.isEmpty {
                        Picker("Environment", selection: $viewModel.selectedEnvironmentID) {
                            ForEach(viewModel.environments) { env in
                                Text(env.name).tag(env.id as UUID?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    Spacer()
                }
                
                NativeEditableTextView(text: $viewModel.urlString)
                    .font(.system(.body, design: .monospaced))
                    .autocorrectionDisabled(true)
                    .frame(height: 50)
                    .padding(4)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2)))
            }
        }
    }
}

struct HeadersSectionView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SectionHeader(title: "HEADERS")
                Spacer()
                // Clear Headers Button
                if !viewModel.rawHeaders.isEmpty {
                    Button(action: { 
                        viewModel.rawHeaders = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .help("Clear Headers")
                }
            }
            
            // Auth Shortcut
            HStack {
                Image(systemName: "key.fill").foregroundColor(.secondary)
                TextField("Bearer Token (Optional)", text: $viewModel.authToken)
                    .textFieldStyle(.plain)
                
                // Clear Token Button
                if !viewModel.authToken.isEmpty {
                    Button(action: { 
                        viewModel.authToken = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2)))
            
            // Raw Headers Input
            VStack(alignment: .leading, spacing: 4) {
                Text("Custom Headers (Key: Value)").font(.caption2).foregroundColor(.secondary)
                NativeEditableTextView(text: $viewModel.rawHeaders)
                    .font(.system(.caption, design: .monospaced))
                    .frame(height: 80)
                    .autocorrectionDisabled(true)
                    .padding(4)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2)))
            }
        }
    }
}

struct BodySectionView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        // Cuma render kalau method butuh body
        if ["POST", "PUT", "PATCH"].contains(viewModel.selectedMethod) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    SectionHeader(title: "BODY PAYLOAD")
                    Spacer()
                    
                    // Clear Body Button
                    if !viewModel.requestBody.isEmpty {
                        Button(action: { 
                            viewModel.requestBody = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                        .help("Clear Body")
                    }
                    
                    Text("JSON").font(.caption2).padding(.horizontal, 4)
                        .background(Color.gray.opacity(0.2)).cornerRadius(4)
                }
                
                NativeEditableTextView(text: $viewModel.requestBody)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(height: 200)
                    .autocorrectionDisabled(true)
                    .padding(4)
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.2)))
            }
        } else {
            EmptyView()
        }
    }
}

struct SendButtonView: View {
    var action: () -> Void
    var isLoading: Bool // 1. Terima status loading
    
    var body: some View {
        VStack {
            Divider()
            Button(action: action) {
                HStack {
                    if isLoading {
                        // 2. Ganti Icon jadi Spinner kalau lagi loading
                        ProgressView()
                            .controlSize(.small)
                            .colorInvert() // Biar putih di button biru
                            .brightness(1)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    
                    Text(isLoading ? "Sending..." : "Send Request")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isLoading) // 3. INI KUNCINYA! Tombol jadi abu-abu & gak bisa diklik
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Response Components

// MARK: - RESPONSE HEADER COMPONENT

struct ResponseHeaderView: View {
    let response: APIResponse
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var showDictionary = false
    
    var body: some View {
        HStack {
            Text("RESPONSE")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // --- GRUP KANAN: SEARCH, STATUS CODE & LATENCY ---
            
            // A. TOMBOL SEARCH
            Button(action: {
                viewModel.showSearch.toggle()
                if !viewModel.showSearch {
                    viewModel.searchQuery = ""
                }
            }) {
                Image(systemName: viewModel.showSearch ? "magnifyingglass.circle.fill" : "magnifyingglass")
                    .font(.caption)
                    .foregroundColor(viewModel.showSearch ? .blue : .secondary)
            }
            .buttonStyle(.plain)
            .help("Search in Response (⌘F)")
            .keyboardShortcut("f", modifiers: .command)
            
            // B. BADGE STATUS CODE
            HStack(spacing: 6) {
                // Teks Status (Contoh: 200 OK)
                Text("\(response.statusCode) \(getStatusCodeDescription(response.statusCode))")
                    .font(.caption).bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusCodeColor(response.statusCode))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                // Tombol Info (Pentung) ℹ️
                Button(action: {
                    showDictionary = true // <--- Klik ini nyalain saklar
                }) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Lihat Kamus Error Code")
                .popover(isPresented: $showDictionary) { // <--- Popover baca saklar ini
                    ErrorCodesView() // Pastikan file ErrorCodesView.swift sudah dibuat
                }
            }
            
            // C. BADGE LATENCY (Warna-warni)
            let latencyColor = LatencyEvaluator.evaluate(response.latency)
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                Text("\(String(format: "%.0f", response.latency)) ms")
            }
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(latencyColor.opacity(0.15))
            .foregroundColor(latencyColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(latencyColor.opacity(0.5), lineWidth: 1)
            )
            .padding(.leading, 8)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // --- HELPER FUNCTIONS (Harus di dalam struct) ---
    
    private func statusCodeColor(_ code: Int) -> Color {
        if code >= 200 && code < 300 { return .green }
        if code >= 400 && code < 500 { return .orange }
        if code >= 500 { return .red }
        return .gray
    }
    
    private func getStatusCodeDescription(_ code: Int) -> String {
        switch code {
        case 200: return "OK"
        case 201: return "CREATED"
        case 204: return "NO CONTENT"
        case 400: return "BAD REQUEST"
        case 401: return "UNAUTHORIZED"
        case 403: return "FORBIDDEN"
        case 404: return "NOT FOUND"
        case 500: return "SERVER ERROR"
        case 502: return "BAD GATEWAY"
        case 503: return "UNAVAILABLE"
        default: return ""
        }
    }
}

//struct ResponseBodyView: View {
//    let content: String
//    
//    var body: some View {
//        ScrollView {
//            Text(content)
//                .font(.system(.body, design: .monospaced))
//                .textSelection(.enabled)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding()
//        }
//    }
//}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "desktopcomputer")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.3))
            Text("Ready to send requests")
                .font(.title3)
                .foregroundColor(.gray.opacity(0.5))
        }
    }
}

// MARK: - Utilities

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
    }
}

struct DownloadProgressView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Downloading Resource...")
                        .font(.headline)
                    Text(viewModel.downloadInfo)
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Tombol Cancel (Optional tapi Pro)
                Button("Cancel") {
                    viewModel.cancelDownload()
                }
                .buttonStyle(.link)
                .foregroundColor(.red)
            }
            
            if viewModel.totalBytesKnown {
                // Bar yang jalan 0% -> 100%
                ProgressView(value: viewModel.downloadProgress)
                    .progressViewStyle(.linear)
            } else {
                // Spinner/Bar pulsing kalau total data gaib
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .padding()
    }
}

