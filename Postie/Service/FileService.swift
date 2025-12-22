//
//  FileService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import AppKit
import Foundation
import UniformTypeIdentifiers

/**
 # FILE SERVICE (PORTABLE PRESET ENGINE)
 
 ## 1. TUJUAN (PURPOSE)
 FileService dirancang sebagai jembatan (bridge) antara state internal aplikasi Postie dengan sistem berkas (file system) macOS.
 Fokus utamanya adalah memfasilitasi "File-based Persistence" agar user dapat menyimpan dan memuat koleksi request API dalam format yang portable (.json).
 
 ## 2. TEKNOLOGI (TECH STACK)
 - **AppKit (NSSavePanel & NSOpenPanel):** Menggunakan komponen UI native macOS untuk menjamin integritas desain dan fungsionalitas sistem operasi.
 - **UniformTypeIdentifiers (UTType):** Mengimplementasikan standar modern Apple untuk penyaringan tipe file (Filtering), menggantikan ekstensi string yang lama demi keamanan data.
 - **Swift Concurrency (@MainActor):** Menjamin seluruh interaksi jendela dialog berjalan di Main Thread untuk mencegah "UI Glitches" atau crash akibat akses thread yang tidak aman.
 - **macOS Sandboxing & Powerbox:** Memanfaatkan sistem keamanan macOS di mana aplikasi hanya diberikan izin akses (Permission) pada file spesifik yang dipilih user melalui panel ini, tanpa membutuhkan izin akses disk penuh.

 ## 3. ALGORITMA & FLOW (LOGIC STREAM)
 Alur kerja (flow) dari service ini mengikuti urutan sekuensial berikut:
 
 1. **Initialization:** Instansiasi objek Panel (Open/Save) ke dalam memori lokal fungsi.
 2. **Constraint Configuration:** - Mengunci tipe konten hanya pada `.json`.
    - Mengatur parameter interaksi (Single Selection, Default Filename).
 3. **Execution (runModal):** - Aplikasi memicu "XPC Service" eksternal (Open and Save Panel Service) untuk merender jendela Finder.
    - Eksekusi kode pada Main Thread akan ditangguhkan (Blocked) sementara sampai user memberikan input.
 4. **User Interception:** - Jika user menekan **OK**: Service menangkap URL path file tersebut.
    - Jika user menekan **Cancel**: Service mengembalikan nilai `nil`.
 5. **Memory Cleanup (ARC):** - Setelah fungsi mengembalikan nilai (Return), objek Panel dihancurkan secara otomatis oleh ARC.
    - RAM aplikasi tetap terjaga (Plateau) karena tidak ada referensi panel yang tersimpan secara permanen (Stateless).

 ## 4. CATATAN PERFORMA (PERFORMANCE INSIGHT)
 Service ini berkontribusi pada efisiensi Postie (stabil di ~36MB RAM) karena tidak memuat metadata file secara manual; beban pemrosesan visual Finder didelegasikan sepenuhnya ke proses sistem macOS terpisah.
 */

struct FileService {
    
    /// **Logic: Save Dialog Interface**
    /// Membuka jendela dialog standar macOS untuk menentukan lokasi simpan file.
    /// 1. Membatasi tipe file hanya ke `.json`.
    /// 2. `runModal()`: Memblokir eksekusi sementara sampai user menekan Save/Cancel.
    /// 3. Mengembalikan URL lokasi file yang dipilih oleh user.
    @MainActor
    static func getSaveURL() -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "request-api.json"
        panel.title = "Save Request Preset"
        
        return panel.runModal() == .OK ? panel.url : nil
    }
    
    /// **Logic: Open Dialog Interface**
    /// Membuka jendela dialog standar macOS untuk memilih file yang akan dibuka.
    /// 1. `allowsMultipleSelection = false`: Memastikan hanya satu file yang dimuat dalam satu waktu.
    /// 2. Filter file `.json` untuk mencegah user memilih file yang tidak kompatibel.
    @MainActor
    static func getOpenURL() -> URL? {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.title = "Load Request Preset"
        
        return panel.runModal() == .OK ? panel.url : nil
    }
}
