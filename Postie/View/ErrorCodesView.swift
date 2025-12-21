//
//  ErrorCodesView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//


import SwiftUI

struct ErrorCodesView: View {
    @Environment(\.dismiss) var dismiss
    
    // Akses data static langsung (Cepat & Ringan)
    let codes = HTTPCodeData.all
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "book.fill").foregroundColor(.blue)
                Text("HTTP Status Code Dictionary").font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // List Content
            List {
                ForEach(codes, id: \.range) { category in
                    Section(header: Text("\(category.range) - \(category.title)")
                        .foregroundColor(category.color)
                        .fontWeight(.bold)) {
                            
                        ForEach(category.items, id: \.code) { item in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(item.code)")
                                    .font(.system(.subheadline, design: .monospaced))
                                    .bold()
                                    .padding(6)
                                    .background(category.color.opacity(0.1))
                                    .cornerRadius(4)
                                    .foregroundColor(category.color)
                                    .frame(width: 50)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(item.desc)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true) // Wrap text panjang
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .frame(width: 500, height: 600)
    }
}

// MARK: - DATA & MODEL (HARDCODED IS BETTER HERE)

struct HTTPCodeCategory {
    let range: String
    let title: String
    let color: Color
    let items: [HTTPCodeItem]
}

struct HTTPCodeItem {
    let code: Int
    let title: String
    let desc: String
}

// Data Store (Singleton Pattern yang efisien)
struct HTTPCodeData {
    static let all: [HTTPCodeCategory] = [
        HTTPCodeCategory(range: "1xx", title: "Informational", color: .gray, items: [
            HTTPCodeItem(code: 100, title: "Continue", desc: "Bagian pertama request diterima, silakan lanjutkan."),
            HTTPCodeItem(code: 101, title: "Switching Protocols", desc: "Server setuju ganti protokol (misal ke WebSocket).")
        ]),
        HTTPCodeCategory(range: "2xx", title: "Success", color: .green, items: [
            HTTPCodeItem(code: 200, title: "OK", desc: "Request sukses standar."),
            HTTPCodeItem(code: 201, title: "Created", desc: "Resource baru berhasil dibuat."),
            HTTPCodeItem(code: 204, title: "No Content", desc: "Sukses, tapi tanpa konten respon.")
        ]),
        HTTPCodeCategory(range: "3xx", title: "Redirection", color: .blue, items: [
            HTTPCodeItem(code: 301, title: "Moved Permanently", desc: "Resource pindah permanen ke URL baru."),
            HTTPCodeItem(code: 304, title: "Not Modified", desc: "Data tidak berubah (menggunakan Cache).")
        ]),
        HTTPCodeCategory(range: "4xx", title: "Client Errors", color: .orange, items: [
            HTTPCodeItem(code: 400, title: "Bad Request", desc: "Syntax request salah (Cek JSON/Params)."),
            HTTPCodeItem(code: 401, title: "Unauthorized", desc: "Token salah, tidak ada, atau expired."),
            HTTPCodeItem(code: 403, title: "Forbidden", desc: "Akses ditolak meski token benar."),
            HTTPCodeItem(code: 404, title: "Not Found", desc: "Endpoint/ID tidak ditemukan."),
            HTTPCodeItem(code: 429, title: "Too Many Requests", desc: "Rate limit. Tunggu sebentar.")
        ]),
        HTTPCodeCategory(range: "5xx", title: "Server Errors", color: .red, items: [
            HTTPCodeItem(code: 500, title: "Internal Server Error", desc: "Error generik di backend server."),
            HTTPCodeItem(code: 502, title: "Bad Gateway", desc: "Respon invalid dari upstream server."),
            HTTPCodeItem(code: 503, title: "Service Unavailable", desc: "Server down atau maintenance.")
        ])
    ]
}
