//
//  NativeEditableTextView.swift
//  Postie
//
//  Created by Nunu Nugraha on 23/12/25.
//

import SwiftUI
import AppKit

/**
 # NATIVE EDITABLE TEXT VIEW (ANTI-SMART QUOTES EDITOR)
 
 ## 1. TUJUAN (PURPOSE)
 NativeEditableTextView diciptakan untuk menyelesaikan limitasi kritis pada `TextEditor` bawaan SwiftUI di macOS.
 Masalah utama pada `TextEditor` adalah fitur "Smart Typography" (Smart Quotes & Smart Dashes) yang secara otomatis mengubah tanda petik lurus (`"`) menjadi melengkung (`“`).
 Hal ini menyebabkan payload JSON menjadi korup/invalid saat dikirim ke server (Error: Unexpected character 'â').
 
 ## 2. TEKNOLOGI (TECH STACK)
 - **NSViewRepresentable:** Bertindak sebagai jembatan (bridge) untuk menyematkan komponen AppKit ke dalam hierarki View SwiftUI.
 - **NSTextView (AppKit):** Engine teks dasar macOS yang memberikan kontrol granular tingkat rendah atas perilaku input teks.
 
 ## 3. MENGGANTIKAN (REPLACES)
 Komponen ini menggantikan `TextEditor` SwiftUI di bagian Sidebar (URL, Headers, dan Body Payload).
 Berbeda dengan `NativeTextView` yang bersifat Read-Only, komponen ini mendukung interaksi dua arah (Two-way Binding).

 ## 4. LOGIKA & ARMOR (LOGIC & PROTECTION)
 - **Anti-Smart Quotes Armor:** Mematikan secara eksplisit fitur substitusi otomatis macOS agar karakter yang diketik tetap murni (Raw Strings).
 - **Cursor Management:** Fungsi `updateNSView` menyertakan pengecekan string untuk mencegah kursor "melompat" ke posisi awal setiap kali user mengetik satu karakter.
 - **Coordinator:** Bertindak sebagai delegasi untuk mengirimkan setiap perubahan teks kembali ke ViewModel secara real-time.
 */

/**
 ## 3. ALGORITMA & FLOW (INPUT LOGIC STREAM)
 Alur kerja komponen ini dirancang untuk menjamin integritas data (Raw String) dan kenyamanan UX:
 
 1. **Initialization (makeNSView):** - Membungkus `NSTextView` ke dalam `NSScrollView` untuk mendukung area input yang dinamis.
 - **Disabling Smart Features:** Algoritma secara eksplisit mematikan `isAutomaticQuoteSubstitutionEnabled` dan `isAutomaticDashSubstitutionEnabled`. Ini adalah "Kill Switch" untuk mencegah macOS mengubah karakter ASCII standar menjadi karakter tipografi cantik yang merusak struktur JSON.
 
 2. **Two-Way Binding (Coordinator):** - Saat user mengetik, `NSTextViewDelegate` (Coordinator) menangkap event `textDidChange`.
 - Data dari level AppKit (Raw String) langsung dikirimkan kembali ke `@Binding` SwiftUI secara real-time.
 
 3. **Diff-Based Sync (updateNSView):** - **Algoritma Pencegahan Kursor Loncat:** Saat State di SwiftUI berubah, fungsi ini dipicu.
 - Kita menggunakan logika pembanding `if textView.string != text`.
 - **Logic:** String hanya akan disuntikkan ke `NSTextView` jika ada perbedaan konten secara fundamental (misalnya saat Load Preset). Jika perubahan berasal dari ketikan user sendiri, sinkronisasi diabaikan untuk menjaga posisi kursor (Insertion Point) tetap stabil.
 */

struct NativeEditableTextView: NSViewRepresentable {
    /// Binding dua arah untuk sinkronisasi teks dengan ViewModel.
    @Binding var text: String

    /// Inisialisasi dan konfigurasi dasar NSTextView.
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false // Mencegah penyimpanan format teks (bold/italic).
        textView.drawsBackground = false
        
        // --- 🛡️ MATIKAN FITUR OTOMATIS MACOS ---
        // Mencegah error 'Unexpected character â' pada JSON parser.
        textView.isAutomaticQuoteSubstitutionEnabled = false // Matikan " " -> “ ”
        textView.isAutomaticDashSubstitutionEnabled = false  // Matikan -- -> —
        textView.isAutomaticSpellingCorrectionEnabled = false // Matikan Autocorrect.
        textView.isAutomaticTextReplacementEnabled = false   // Matikan Text Replacement.
        
        return scrollView
    }

    /// Sinkronisasi data dari SwiftUI State ke AppKit View.
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        // Validasi konten untuk menjaga integritas posisi kursor.
        if textView.string != text {
            textView.string = text
        }
    }

    /// Membuat jembatan delegasi untuk menangani event dari AppKit.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// Kelas perantara untuk menangani event delegate NSTextView.
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NativeEditableTextView
        init(_ parent: NativeEditableTextView) { self.parent = parent }
        
        /// Dipicu setiap kali ada perubahan teks pada NSTextView.
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            // Mengirimkan string terbaru kembali ke @Binding.
            self.parent.text = textView.string
        }
    }
}
