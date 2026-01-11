//
//  SupportUsView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import SwiftUI

struct SupportUsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Developer Avatar
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .shadow(radius: 8)
                    .foregroundStyle(.blue)
                    .padding(.top, 20)
                
                // Title
                Text("Support Indie Development")
                    .font(.title2)
                    .bold()
                
                // Developer Story
                VStack(spacing: 12) {
                    Text("Hi, I'm Nunu, the solo developer behind Postie.")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("This app was born from frustration with heavy, sluggish API clients. Postie is built 100% native with zero third-party dependencies, focusing purely on performance and efficiency.")
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    Text("Your support means everything in keeping this app free, ad-free, and continuously improving. Every coffee fuels more features and refinements! ☕️")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // Support Buttons
                VStack(spacing: 12) {
                    Link(destination: URL(string: "https://saweria.co/nunugraha17")!) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Support on Saweria")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .orange.opacity(0.4), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                    
                    Link(destination: URL(string: "https://www.buymeacoffee.com/nunutech401")!) {
                        HStack {
                            Image(systemName: "cup.and.saucer.fill")
                            Text("Buy Me a Coffee")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(color: .yellow.opacity(0.4), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                
                // Thank You Message
                VStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundStyle(.pink)
                    
                    Text("Thank you for your support!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Every contribution helps keep Postie alive and thriving.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding()
        }
    }
}
