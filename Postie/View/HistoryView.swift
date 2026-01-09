//
//  HistoryView.swift
//  Postie
//
//  Created by Nunu Nugraha on 24/12/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var showHistory: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("Request History")
                    .font(.title2).bold()
                    .padding(.bottom, 5)
                
                if viewModel.requestHistory.isEmpty {
                    Text("No history yet. Send a request to see it here!")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                } else {
                    ForEach(viewModel.requestHistory) { request in
                        HistoryRequestRow(request: request) {
                            viewModel.loadRequestFromHistory(request: request)
                            showHistory = false
                        }
                    }
                }
            }
            .padding()
        }
        .frame(width: 450, height: 500) // Adjusted frame for better layout
    }
}

// MARK: - REUSABLE COMPONENTS FOR HISTORY

struct HistoryRequestRow: View {
    let request: RequestPreset
    let action: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .center) {
                    Text(request.method)
                        .font(.caption).bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(methodColor(request.method))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    
                    Text(request.url)
                        .font(.body)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Spacer()
                    
                    Group {
                        if !request.rawHeaders.isEmpty || !request.authToken.isEmpty {
                            Text("H")
                        }
                        if !request.requestBody.isEmpty {
                            Text("B")
                        }
                    }
                    .font(.caption2)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(3)
                    .foregroundColor(.secondary)
                }
                
                Text(dateFormatter.string(from: request.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(10)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func methodColor(_ method: String) -> Color {
        switch method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "PATCH": return .purple
        case "DELETE": return .red
        default: return .gray
        }
    }
}
