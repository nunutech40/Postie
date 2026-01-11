//
//  AboutView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    // private var buildNumber: String {
    //     Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    // }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Icon
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .symbolEffect(.pulse, isActive: true)
                    .padding(.top, 20)
                
                // App Info Card
                VStack(spacing: 6) {
                    Text("Postie \(appVersion)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Created by Nunu Nugraha")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // Description
                VStack(spacing: 12) {
                    Text("A native macOS HTTP client built for speed and simplicity.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                    
                    Text("Postie is an API testing tool built 100% native with SwiftUI & AppKit. No Electron, no bloat—just pure performance under 50MB RAM.")
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // Features Highlight
                VStack(alignment: .leading, spacing: 10) {
                    FeatureRow(icon: "bolt.fill", title: "Ultra-Lightweight", description: "< 50 MB RAM usage")
                    FeatureRow(icon: "hare.fill", title: "Instant Start", description: "No splash screen")
                    FeatureRow(icon: "cube.fill", title: "Zero Dependencies", description: "100% Apple SDK")
                    FeatureRow(icon: "magnifyingglass", title: "Search & Highlight", description: "Find in response")
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                .shadow(radius: 2)
                
                // Footer
                Text("© 2025 Nunu Nugraha Logic Inc.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 10)
            }
            .padding()
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}
