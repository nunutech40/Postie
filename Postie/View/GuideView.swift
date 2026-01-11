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
                        Text("Panduan lengkap setiap komponen input di Postie.")
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
                GuideSection(title: "1. TARGET (Tujuan)", icon: "network") {
                    GuideRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "HTTP Method",
                        desc: "Menentukan jenis aksi. Gunakan `GET` untuk mengambil data, `POST` untuk mengirim data baru, `PUT/PATCH` untuk update, dan `DELETE` untuk menghapus."
                    )
                    
                    GuideRow(
                        icon: "link",
                        title: "Target URL",
                        desc: "Alamat server tujuan (Endpoint). Wajib menyertakan protokol `http://` atau `https://`."
                    )
                }
                
                // ==========================================
                // 2. HEADERS SECTION (Token & Metadata)
                // ==========================================
                GuideSection(title: "2. HEADERS (Metadata)", icon: "tag.fill") {
                    GuideRow(
                        icon: "key.fill",
                        title: "Bearer Token (Shortcut)",
                        desc: "Kolom khusus untuk autentikasi. Jika diisi, Postie otomatis membuat header `Authorization: Bearer <token_anda>`."
                    )
                    
                    GuideRow(
                        icon: "list.bullet.rectangle",
                        title: "Custom Headers",
                        desc: "Metadata tambahan dalam format `Key: Value`. Gunakan baris baru untuk memisahkan header.\nContoh:\n`Content-Type: application/json`\n`X-Api-Key: 12345`"
                    )
                }
                
                // ==========================================
                // 3. BODY SECTION (Payload)
                // ==========================================
                GuideSection(title: "3. BODY PAYLOAD (Isi Paket)", icon: "doc.text.fill") {
                    GuideRow(
                        icon: "curlybraces",
                        title: "JSON Editor",
                        desc: "Area ini hanya aktif untuk method `POST`, `PUT`, atau `PATCH`. Pastikan format JSON valid (menggunakan tanda kutip ganda untuk key & string)."
                    )
                    
                    // Tips Validasi JSON
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Tips: Jika server merespon 400 Bad Request, cek kembali tanda koma (,) di akhir JSON object anda.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                }
                
                // ==========================================
                // 4. LATENCY EVALUATOR (Warna Warni)
                // ==========================================
                GuideSection(title: "4. LATENCY INDICATOR (Kecepatan)", icon: "stopwatch.fill") {
                    Text("Indikator warna pada respon menunjukkan kesehatan server:")
                        .font(.caption).foregroundColor(.secondary)
                        .padding(.bottom, 4)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        LatencyRow(color: .green, label: "EXCELLENT (< 200ms)", desc: "Respon instan. User experience sangat baik.")
                        Divider()
                        LatencyRow(color: Color(nsColor: .systemGreen), label: "GOOD (200-600ms)", desc: "Standar kecepatan API modern.")
                        Divider()
                        LatencyRow(color: .orange, label: "AVERAGE (600-1200ms)", desc: "Terasa ada jeda (loading). Perlu optimasi.")
                        Divider()
                        LatencyRow(color: .red, label: "SLOW (> 1200ms)", desc: "Sangat lambat. Berpotensi timeout.")
                    }
                    .background(Color(NSColor.textBackgroundColor))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                }
                
                // ==========================================
                // NEW SECTION: PRESETS (Save & Load)
                // ==========================================
                GuideSection(title: "Presets (Simpan & Buka)", icon: "tray.full.fill") {
                    GuideRow(
                        icon: "square.and.arrow.down",
                        title: "Save Request",
                        desc: "Simpan seluruh konfigurasi (Method, URL, Headers, dan Body) ke dalam file `.json`. Sangat berguna untuk mendokumentasikan API atau berbagi konfigurasi dengan tim."
                    )
                    
                    GuideRow(
                        icon: "folder",
                        title: "Browse / Load Request",
                        desc: "Membuka file preset yang sudah disimpan sebelumnya. Postie akan otomatis mengisi kembali semua kolom input sesuai dengan data di dalam file tersebut."
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
