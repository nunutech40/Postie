//
//  OnboardingView.swift
//  Postie
//
//  Created by Nunu Nugraha on 11/01/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var selection = 0
    
    var isFromSettings: Bool = false // Kalau dibuka dari settings, bukan first launch
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button (hanya kalau dari settings)
            if isFromSettings {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
            }
            
            TabView(selection: $selection) {
                OnboardingSlideView(
                    imageName: "home-req",
                    title: "Send Requests Effortlessly",
                    description: "Clean, intuitive interface for sending HTTP requests. Choose your method, enter the URL, add headers and body, then hit Send. Responses appear instantly with beautifully formatted JSON."
                )
                .tag(0)

                OnboardingSlideView(
                    imageName: "collection-request",
                    title: "Organize with Collections",
                    description: "Group your API requests into collections for better organization. Save, load, and manage multiple endpoints with ease. Perfect for projects with recurring API testing needs."
                )
                .tag(1)

                OnboardingSlideView(
                    imageName: "historyreq",
                    title: "History & Environments",
                    description: "Your last 10 requests are automatically saved for quick access. Manage multiple environments (dev, staging, production) with variables like {{baseURL}} and {{apiKey}} for a seamless workflow."
                )
                .tag(2)

                OnboardingSlideView(
                    imageName: "about-app",
                    title: "Native, Lightweight, Blazing Fast",
                    description: "Built 100% native with SwiftUI & AppKit. Under 50MB RAM usage, no Electron bloat. Instant startup, zero dependencies, and maximum performance for your daily API testing."
                )
                .tag(3)
            }
            .tabViewStyle(.automatic)
            
            // Navigation buttons
            HStack(spacing: 20) {
                // Skip button (hanya di slide pertama dan bukan dari settings)
                if selection == 0 && !isFromSettings {
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Skip")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                // Page indicators (dots)
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == selection ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Spacer()
                
                // Next/Get Started button
                Button(action: {
                    if selection < 3 {
                        withAnimation { selection += 1 }
                    } else {
                        if isFromSettings {
                            dismiss()
                        } else {
                            hasCompletedOnboarding = true
                        }
                    }
                }) {
                    Text(selection == 3 ? (isFromSettings ? "Close" : "Get Started") : "Next")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        .frame(width: 700, height: 600)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    OnboardingView()
}
