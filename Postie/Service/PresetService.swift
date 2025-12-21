//
//  PresetService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Foundation

// 1. DEFINISIKAN STRUCT-NYA DI SINI
struct RequestPreset: Codable {
    let method: String
    let url: String
    let authToken: String
    let rawHeaders: String
    let requestBody: String
}

struct PresetService {
    static func save(preset: RequestPreset, to url: URL) throws {
        let data = try JSONEncoder().encode(preset)
        try data.write(to: url)
    }

    static func load(from url: URL) throws -> RequestPreset {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(RequestPreset.self, from: data)
    }
}
