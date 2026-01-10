//
//  MethodColor.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct MethodColor {
    static func color(for method: String) -> Color {
        switch method.uppercased() {
        case "GET":
            return .green
        case "POST":
            return .blue
        case "PUT":
            return .orange
        case "PATCH":
            return .purple
        case "DELETE":
            return .red
        default:
            return .gray
        }
    }
}
