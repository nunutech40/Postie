//
//  OnboardingSlideView.swift
//  Postie
//
//  Created by Nunu Nugraha on 11/01/26.
//

import SwiftUI

struct OnboardingSlideView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // --- Screenshot dengan efek mockup macOS ---
            Image(imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(12) // Rounded corners ala macOS window
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                .frame(maxHeight: 400) // Limit height untuk consistency
                .padding(.horizontal, 60)
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
            }
            
            Spacer()
        }
    }
}
