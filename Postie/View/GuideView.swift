//
//  GuideView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import SwiftUI

struct GuideView: View {
    @State private var showOnboarding = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // HEADER dengan tombol onboarding
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Interface Guide")
                            .font(.title2).bold()
                        Text("Complete guide to every input component in Postie.")
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showOnboarding = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Tutorial")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)
                
                // ==========================================
                // 1. TARGET SECTION (Method & URL)
                // ==========================================
                GuideSection(title: "1. TARGET (Destination)", icon: "network") {
                    GuideRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "HTTP Method",
                        desc: "Defines the action type. Use `GET` to fetch data, `POST` to send new data, `PUT/PATCH` to update, and `DELETE` to remove."
                    )
                    
                    GuideRow(
                        icon: "link",
                        title: "Target URL",
                        desc: "The server endpoint address. Must include the protocol `http://` or `https://`."
                    )
                }
                
                // ==========================================
                // 2. HEADERS SECTION (Token & Metadata)
                // ==========================================
                GuideSection(title: "2. HEADERS (Metadata)", icon: "tag.fill") {
                    GuideRow(
                        icon: "key.fill",
                        title: "Bearer Token (Shortcut)",
                        desc: "Dedicated field for authentication. When filled, Postie automatically creates the header `Authorization: Bearer <your_token>`."
                    )
                    
                    GuideRow(
                        icon: "list.bullet.rectangle",
                        title: "Custom Headers",
                        desc: "Additional metadata in `Key: Value` format. Use new lines to separate headers.\nExample:\n`Content-Type: application/json`\n`X-Api-Key: 12345`"
                    )
                }
                
                // ==========================================
                // 3. BODY SECTION (Payload)
                // ==========================================
                GuideSection(title: "3. BODY PAYLOAD (Request Data)", icon: "doc.text.fill") {
                    GuideRow(
                        icon: "curlybraces",
                        title: "JSON Editor",
                        desc: "This field is only active for `POST`, `PUT`, or `PATCH` methods. Ensure valid JSON format (use double quotes for keys & strings)."
                    )
                    
                    // Tips Validasi JSON
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Tip: If the server responds with 400 Bad Request, check for trailing commas (,) in your JSON object.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // ==========================================
                // 4. LATENCY EVALUATOR (Performance)
                // ==========================================
                GuideSection(title: "4. LATENCY INDICATOR (Performance)", icon: "stopwatch.fill") {
                    Text("Color indicators on responses show server health:")
                        .font(.caption).foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        LatencyRow(color: .green, label: "EXCELLENT (< 200ms)", desc: "Instant response. Excellent user experience.")
                        Divider()
                        LatencyRow(color: Color(nsColor: .systemGreen), label: "GOOD (200-600ms)", desc: "Modern API standard speed.")
                        Divider()
                        LatencyRow(color: .orange, label: "AVERAGE (600-1200ms)", desc: "Noticeable delay. Consider optimization.")
                        Divider()
                        LatencyRow(color: .red, label: "SLOW (> 1200ms)", desc: "Very slow. Potential timeout risk.")
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                }
                
                // ==========================================
                // NEW SECTION: PRESETS (Save & Load)
                // ==========================================
                GuideSection(title: "Presets (Save & Load)", icon: "tray.full.fill") {
                    GuideRow(
                        icon: "square.and.arrow.down",
                        title: "Save Request",
                        desc: "Save the entire configuration (Method, URL, Headers, and Body) to a `.json` file. Perfect for documenting APIs or sharing configurations with your team."
                    )
                    
                    GuideRow(
                        icon: "folder",
                        title: "Browse / Load Request",
                        desc: "Open a previously saved preset file. Postie will automatically populate all input fields with the data from the file."
                    )
                }
                
                // Footer Space
                Spacer().frame(height: 20)
            }
            .padding()
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isFromSettings: true)
        }
    }
}

// MARK: - REUSABLE COMPONENTS

struct GuideSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor)) // Warna background kontras
            .cornerRadius(10)
        }
    }
}

struct GuideRow: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(desc)
                    .font(.caption) // Ukuran pas buat baca panjang
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true) // Wrap text
                    .lineSpacing(2)
            }
        }
    }
}

struct LatencyRow: View {
    let color: Color
    let label: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .shadow(color: color.opacity(0.5), radius: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .bold()
                    .foregroundColor(color)
                
                Text(desc)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
    }
}
