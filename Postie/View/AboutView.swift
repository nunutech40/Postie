//
//  AboutView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "paperplane.fill") // Icon Postie
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)
                .foregroundColor(.blue)
                .symbolEffect(.pulse, isActive: true)
            
            VStack(spacing: 4) {
                Text("Postie")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0 (Alpha)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospaced()
            }
            
            Divider().frame(width: 200)
            
            Text("A Native macOS HTTP Client.\nBuilt for speed, simplicity, and no-nonsense debugging.")
                .font(.system(size: 11))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Text("© 2025 Nunu Nugraha Logic Inc.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}
