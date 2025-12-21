//
//  NativeTextView.swift
//  Postie
//
//  Created by Nunu Nugraha on 22/12/25.
//

import SwiftUI
import AppKit

struct NativeTextView: NSViewRepresentable {
    let text: String

    // 1. Inisialisasi awal (Cuma jalan sekali)
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        
        // Agar teks melebar mengikuti lebar window
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        return scrollView
    }

    // 2. Tiap kali 'text' berubah, fungsi ini jalan
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // --- LOGIKA RESET MEMORI ---
        // Kita kosongkan dulu storage-nya secara total
        // Ini lebih ampuh buat nurunin RAM daripada cuma set string kosong
        textView.textStorage?.setAttributedString(NSAttributedString(string: ""))
        
        // Baru isi dengan data baru
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
