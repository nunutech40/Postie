//
//  WebView.swift
//  Postie
//
//  Created by Nunu Nugraha on 26/12/25.
//

import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    
    let htmlString: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlString, baseURL: nil)
    }
}
