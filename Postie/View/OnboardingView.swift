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
                    title: "Kirim Request dengan Mudah",
                    description: "Interface yang bersih dan intuitif untuk mengirim HTTP request. Pilih method, masukkan URL, tambahkan headers dan body, lalu klik Send. Response langsung muncul dengan JSON yang sudah di-format otomatis."
                )
                .tag(0)

                OnboardingSlideView(
                    imageName: "collection-request",
                    title: "Organisir dengan Collections",
                    description: "Kelompokkan request API kamu ke dalam collections. Mudah untuk manage, save, dan load kembali. Cocok untuk project dengan banyak endpoint yang perlu di-test secara berkala."
                )
                .tag(1)

                OnboardingSlideView(
                    imageName: "historyreq",
                    title: "Request History & Environment",
                    description: "10 request terakhir otomatis tersimpan untuk akses cepat. Manage multiple environments (dev, staging, production) dengan variabel seperti {{baseURL}} dan {{apiKey}} untuk workflow yang lebih efisien."
                )
                .tag(2)

                OnboardingSlideView(
                    imageName: "about-app",
                    title: "Native, Ringan, dan Cepat",
                    description: "Dibangun 100% native dengan SwiftUI & AppKit. Konsumsi RAM di bawah 50MB, tanpa Electron bloat. Instant start, zero dependencies, dan performa maksimal untuk testing API sehari-hari."
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
                    Text(selection == 3 ? (isFromSettings ? "Close" : "Mulai Pakai Postie") : "Next")
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
