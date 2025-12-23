//
//  NativeEditableTextView.swift
//  Postie
//
//  Created by Nunu Nugraha on 23/12/25.
//

import SwiftUI
import AppKit

struct NativeEditableTextView: NSViewRepresentable {
    @Binding var text: String // Dua arah: SwiftUI <-> AppKit

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        textView.delegate = context.coordinator
        textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.drawsBackground = false
        
        // --- 🛡️ ANTI-SMART QUOTES ARMOR ---
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        // Cek agar kursor tidak loncat ke awal setiap ngetik
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NativeEditableTextView
        init(_ parent: NativeEditableTextView) { self.parent = parent }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            // Kirim hasil ketikan balik ke HomeViewModel
            self.parent.text = textView.string
        }
    }
}
