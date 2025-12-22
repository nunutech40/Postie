//
//  PresetService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Foundation

/**
 # PRESET SERVICE (STORAGE ENGINE)
 
 ## 1. TUJUAN (PURPOSE)
 PresetService berfungsi sebagai engine persistensi data yang bertanggung jawab untuk melakukan serialisasi dan deserialisasi objek `RequestPreset`.
 Servis ini memungkinkan aplikasi Postie untuk bersifat "stateless" dengan memindahkan beban penyimpanan data dari RAM ke disk dalam format JSON yang portable.
 
 ## 2. TEKNOLOGI (TECH STACK)
 - **Codable Protocol:** Memanfaatkan sistem enkoding Swift yang type-safe untuk memastikan integritas data saat dikonversi.
 - **JSONEncoder & JSONDecoder:** Parser native dari framework Foundation yang sangat efisien dan teroptimasi untuk macOS.
 - **File I/O (Foundation):** Menggunakan operasi input/output langsung ke sistem berkas (Disk) untuk meminimalkan ketergantungan pada database pihak ketiga.

 

 ## 3. ALGORITMA & FLOW (LOGIC STREAM)
 Alur kerja persistensi mengikuti logika dua arah (Bi-directional):
 
 ### **A. Operasi Penulisan (Save/Write):**
 1. **Serialization:** Mengonversi struktur data `RequestPreset` menjadi aliran byte (Binary Data) menggunakan `JSONEncoder`.
 2. **Disk I/O:** Menulis data tersebut ke lokasi spesifik yang ditentukan oleh user melalui `FileService`.
 
 ### **B. Operasi Pembacaan (Load/Read):**
 1. **Data Fetching:** Membaca bitstream mentah dari file fisik di disk berdasarkan URL yang valid.
 2. **Deserialization:** Memetakan (Mapping) kembali data JSON tersebut ke dalam objek Swift `RequestPreset` melalui `JSONDecoder`.

 ## 4. CATATAN PERFORMA (SENIOR INSIGHTS)
 - **Zero Database Overhead:** Dengan menggunakan file JSON mentah, Postie tidak perlu menjalankan engine database berat (seperti SQLite atau CoreData), yang secara signifikan membantu menjaga penggunaan RAM tetap stabil di angka **36,4 MB**.
 - **Atomic File-based Persistence:** Strategi ini memungkinkan user untuk berbagi (share) koleksi request mereka dengan mudah hanya dengan mengirimkan file .json tersebut.
 - **Thread Safety:** Operasi I/O ini dijalankan secara sinkron di dalam konteks fungsi pemanggil, namun idealnya dibungkus dalam `Task` asinkron pada level ViewModel untuk menjaga responsivitas UI.
 */


struct PresetService {
    
    /// **Logic: Disk Persistence (Write)**
    /// Mengonversi objek Swift `RequestPreset` menjadi file fisik di disk.
    /// 1. **Encoding**: Menggunakan `JSONEncoder` untuk mengubah struct menjadi format `Data` (JSON).
    /// 2. **I/O**: Menulis data tersebut ke URL yang diberikan (didapat dari FileService).
    static func save(preset: RequestPreset, to url: URL) throws {
        let data = try JSONEncoder().encode(preset)
        try data.write(to: url)
    }

    /// **Logic: Disk Persistence (Read)**
    /// Mengambil data dari disk dan mengonversinya kembali ke objek Swift.
    /// 1. **Data Loading**: Membaca bitstream dari file di URL tertentu.
    /// 2. **Decoding**: Menggunakan `JSONDecoder` untuk memetakan JSON kembali ke struktur `RequestPreset`.
    static func load(from url: URL) throws -> RequestPreset {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(RequestPreset.self, from: data)
    }
}
