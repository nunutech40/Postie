//
//  LatencyEvaluator.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//
import SwiftUI

// MARK: - LATENCY HELPER
struct LatencyEvaluator {
    
    // Standar Kecepatan API (dalam milidetik) -> Return Color doang
    static func evaluate(_ ms: Double) -> Color {
        switch ms {
        case 0..<200:
            return .green // Kilat
        case 200..<600:
            return Color(nsColor: .systemGreen) // Aman
        case 600..<1200:
            return .orange // Mulai kerasa loading
        default:
            return .red // Lemot
        }
    }
}
