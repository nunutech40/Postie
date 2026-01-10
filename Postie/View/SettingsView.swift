//
//  SettingsView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        TabView {
            // TAB 1: ABOUT
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
            
            // TAB 2: ENVIRONMENTS
            EnvironmentView(viewModel: viewModel)
                .tabItem {
                    Label("Environments", systemImage: "server.rack")
                }
            
            // TAB 3: GUIDE (Panduan)
            GuideView()
                .tabItem {
                    Label("Guide", systemImage: "book.pages")
                }
            
            // TAB 4: SUPPORT
            SupportUsView()
                .tabItem {
                    Label("Support", systemImage: "heart.fill")
                }
        }
        .frame(width: 600, height: 450) // Ukuran fix buat sheet settings
        .padding()
        // Tombol Close di pojok sheet
        .overlay(
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(),
            alignment: .topTrailing
        )
        .onDisappear {
            viewModel.forceSaveEnvironments()
        }
    }
}
