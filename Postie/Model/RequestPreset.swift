//
//  RequestPreset.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Foundation

struct RequestPreset: Codable, Identifiable, Equatable {
    let id: UUID
    let method: String
    let url: String
    let authToken: String
    let rawHeaders: String
    let requestBody: String
    let timestamp: Date
    let wasSuccessful: Bool

    enum CodingKeys: String, CodingKey {
        case id, method, url, authToken, rawHeaders, requestBody, timestamp, wasSuccessful
    }

    init(id: UUID = UUID(), method: String, url: String, authToken: String, rawHeaders: String, requestBody: String, timestamp: Date = Date(), wasSuccessful: Bool = true) {
        self.id = id
        self.method = method
        self.url = url
        self.authToken = authToken
        self.rawHeaders = rawHeaders
        self.requestBody = requestBody
        self.timestamp = timestamp
        self.wasSuccessful = wasSuccessful
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        method = try container.decode(String.self, forKey: .method)
        url = try container.decode(String.self, forKey: .url)
        authToken = try container.decode(String.self, forKey: .authToken)
        rawHeaders = try container.decode(String.self, forKey: .rawHeaders)
        requestBody = try container.decode(String.self, forKey: .requestBody)
        timestamp = try container.decodeIfPresent(Date.self, forKey: .timestamp) ?? Date()
        wasSuccessful = try container.decodeIfPresent(Bool.self, forKey: .wasSuccessful) ?? true
    }

    static func == (lhs: RequestPreset, rhs: RequestPreset) -> Bool {
        return lhs.method == rhs.method &&
            lhs.url == rhs.url &&
            lhs.authToken == rhs.authToken &&
            lhs.rawHeaders == rhs.rawHeaders &&
            lhs.requestBody == rhs.requestBody
    }
}
