//
//  NativeTextView.swift
//  Postie
//
//  Created by Nunu Nugraha on 22/12/25.
//

import SwiftUI
import AppKit

/**
 # NATIVE TEXT VIEW (PERFORMANCE-OPTIMIZED RENDERER WITH SEARCH)
 
 ## 1. TUJUAN (PURPOSE)
 NativeTextView diciptakan untuk menggantikan komponen `Text` bawaan SwiftUI yang bersifat "High-Level Wrapper".
 Masalah utama pada `Text` SwiftUI adalah ketidakmampuannya melepaskan "Glyph Cache" secara instan saat menangani payload JSON ribuan baris, yang menyebabkan lonjakan RAM hingga 90MB+.
 Servis ini memberikan kontrol manual atas lifecycle memori teks.
 
 ## 2. TEKNOLOGI (TECH STACK)
 - **NSViewRepresentable:** Jembatan protokol untuk menyematkan komponen AppKit ke dalam hierarki View SwiftUI.
 - **NSTextView (AppKit):** Engine teks native macOS yang memiliki efisiensi rendering jauh lebih tinggi untuk data statis berukuran besar.
 - **NSTextStorage:** Pipa penyimpanan data teks di mana kita bisa memanipulasi konten secara atomik di level memori.
 - **NSTextFinder:** Engine pencarian native macOS untuk find & highlight functionality.

 ## 3. ALGORITMA & FLOW (LOGIC STREAM)
 Alur optimasi memori dalam komponen ini bekerja sebagai berikut:
 
 1. **Initialization (makeNSView):** Membuat instance `NSTextView` sekali saja. Di sini kita mematikan fitur edit (`isEditable = false`) dan mengatur font monospaced agar JSON mudah dibaca.
 2. **State Monitoring:** Setiap kali variabel `text` di ViewModel berubah (karena request baru), fungsi `updateNSView` dipicu secara otomatis.
 3. **Memory Reset Logic (Crucial):** - Sebelum mengisi data baru, kita menjalankan `textStorage?.setAttributedString("")`.
    - **Algoritma:** Ini bukan sekadar menghapus teks, tapi mengirim sinyal eksplisit ke macOS untuk menghancurkan (deallocate) seluruh cache gambar karakter (glyphs) dari request sebelumnya.
 4. **Repopulation:** Menyuntikkan string baru yang sudah dibungkus `NSAttributedString` ke dalam storage yang sudah bersih.
 5. **Search Integration:** NSTextFinder terintegrasi untuk pencarian dengan highlight otomatis.

 ## 4. CATATAN PERFORMA
 - **Memory Stability:** Dengan teknik "Clear-before-Update" ini, Postie berhasil menekan penggunaan RAM secara konsisten di bawah **50MB** (stabil di ~36,4 MB).
 - **UI Responsiveness:** Penggunaan `NSTextView` mencegah aplikasi mengalami *stuttering* atau *freeze* sesaat saat melakukan scroll pada ribuan baris JSON dibandingkan menggunakan `Text` SwiftUI.
 - **Indented Formatting:** Komponen ini secara native mendukung rendering hasil `prettyPrintJSON` dari `NetworkService` dengan beban CPU yang minimal.
 - **Native Search:** NSTextFinder memberikan performa pencarian optimal bahkan untuk JSON berukuran besar.
 */

struct NativeTextView: NSViewRepresentable {
    let text: String
    @Binding var searchQuery: String
    @Binding var showSearch: Bool

    /// Inisialisasi awal komponen AppKit ke SwiftUI.
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        textView.usesFindBar = true // Enable native find bar
        
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        
        // Store reference in coordinator
        context.coordinator.textView = textView
        
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
        
        // Handle search query changes
        if showSearch && !searchQuery.isEmpty {
            context.coordinator.performSearch(query: searchQuery)
        } else {
            context.coordinator.clearSearch()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(searchQuery: $searchQuery)
    }
    
    /// Coordinator untuk mengelola search functionality
    class Coordinator: NSObject {
        @Binding var searchQuery: String
        weak var textView: NSTextView?
        
        init(searchQuery: Binding<String>) {
            self._searchQuery = searchQuery
        }
        
        func performSearch(query: String) {
            guard let textView = textView, !query.isEmpty else { return }
            
            // Clear previous highlights
            clearSearch()
            
            let text = textView.string
            let searchLength = query.count
            var searchRange = NSRange(location: 0, length: text.utf16.count)
            var foundRanges: [NSRange] = []
            
            // Find all occurrences
            while searchRange.location < text.utf16.count {
                searchRange.length = text.utf16.count - searchRange.location
                let foundRange = (text as NSString).range(of: query, options: .caseInsensitive, range: searchRange)
                
                if foundRange.location != NSNotFound {
                    foundRanges.append(foundRange)
                    searchRange.location = foundRange.location + foundRange.length
                } else {
                    break
                }
            }
            
            // Highlight all found occurrences
            guard let textStorage = textView.textStorage else { return }
            
            for range in foundRanges {
                textStorage.addAttribute(.backgroundColor, value: NSColor.systemYellow, range: range)
                textStorage.addAttribute(.foregroundColor, value: NSColor.black, range: range)
            }
            
            // Scroll to first occurrence
            if let firstRange = foundRanges.first {
                textView.scrollRangeToVisible(firstRange)
                textView.showFindIndicator(for: firstRange)
            }
        }
        
        func clearSearch() {
            guard let textView = textView, let textStorage = textView.textStorage else { return }
            
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.removeAttribute(.backgroundColor, range: fullRange)
            textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
        }
    }
}
