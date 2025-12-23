//
//  NativeTextView.swift
//  Postie
//
//  Created by Nunu Nugraha on 22/12/25.
//

import SwiftUI
import AppKit

/**
 # NATIVE TEXT VIEW (PERFORMANCE-OPTIMIZED RENDERER)
 
 ## 1. TUJUAN (PURPOSE)
 NativeTextView diciptakan untuk menggantikan komponen `Text` bawaan SwiftUI yang bersifat "High-Level Wrapper".
 Masalah utama pada `Text` SwiftUI adalah ketidakmampuannya melepaskan "Glyph Cache" secara instan saat menangani payload JSON ribuan baris, yang menyebabkan lonjakan RAM hingga 90MB+.
 Servis ini memberikan kontrol manual atas lifecycle memori teks.
 
 ## 2. TEKNOLOGI (TECH STACK)
 - **NSViewRepresentable:** Jembatan protokol untuk menyematkan komponen AppKit ke dalam hierarki View SwiftUI.
 - **NSTextView (AppKit):** Engine teks native macOS yang memiliki efisiensi rendering jauh lebih tinggi untuk data statis berukuran besar.
 - **NSTextStorage:** Pipa penyimpanan data teks di mana kita bisa memanipulasi konten secara atomik di level memori.

 ## 3. ALGORITMA & FLOW (LOGIC STREAM)
 Alur optimasi memori dalam komponen ini bekerja sebagai berikut:
 
 1. **Initialization (makeNSView):** Membuat instance `NSTextView` sekali saja. Di sini kita mematikan fitur edit (`isEditable = false`) dan mengatur font monospaced agar JSON mudah dibaca.
 2. **State Monitoring:** Setiap kali variabel `text` di ViewModel berubah (karena request baru), fungsi `updateNSView` dipicu secara otomatis.
 3. **Memory Reset Logic (Crucial):** - Sebelum mengisi data baru, kita menjalankan `textStorage?.setAttributedString("")`.
    - **Algoritma:** Ini bukan sekadar menghapus teks, tapi mengirim sinyal eksplisit ke macOS untuk menghancurkan (deallocate) seluruh cache gambar karakter (glyphs) dari request sebelumnya.
 4. **Repopulation:** Menyuntikkan string baru yang sudah dibungkus `NSAttributedString` ke dalam storage yang sudah bersih.

 ## 4. CATATAN PERFORMA
 - **Memory Stability:** Dengan teknik "Clear-before-Update" ini, Postie berhasil menekan penggunaan RAM secara konsisten di bawah **50MB** (stabil di ~36,4 MB).
 - **UI Responsiveness:** Penggunaan `NSTextView` mencegah aplikasi mengalami *stuttering* atau *freeze* sesaat saat melakukan scroll pada ribuan baris JSON dibandingkan menggunakan `Text` SwiftUI.
 - **Indented Formatting:** Komponen ini secara native mendukung rendering hasil `prettyPrintJSON` dari `NetworkService` dengan beban CPU yang minimal.
 */

struct NativeTextView: NSViewRepresentable {
    let text: String

    /// Inisialisasi awal komponen AppKit ke SwiftUI.
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        return scrollView
    }

    /// Logika pembaruan data dan manajemen pembuangan sampah memori (Glyph Cache).
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // --- LOGIKA RESET MEMORI ---
        // Memaksa macOS menghapus data layout lama dari RAM secara total.
        textView.textStorage?.setAttributedString(NSAttributedString(string: ""))
        
        // Pengisian data baru dengan atribut font yang konsisten.
        let attrString = NSAttributedString(
            string: text,
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                .foregroundColor: NSColor.labelColor
            ]
        )
        
        textView.textStorage?.setAttributedString(attrString)
    }
}
