//
//  RequestPreset.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Foundation

struct RequestPreset: Codable, Identifiable, Equatable {
    let id: UUID = UUID()
    let method: String
    let url: String
    let authToken: String
    let rawHeaders: String
    let requestBody: String
    let timestamp: Date = Date()

    static func == (lhs: RequestPreset, rhs: RequestPreset) -> Bool {
        return lhs.id == rhs.id
    }
}
