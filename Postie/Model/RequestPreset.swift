//
//  RequestPreset.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

struct RequestPreset: Codable {
    let method: String
    let url: String
    let authToken: String
    let rawHeaders: String
    let requestBody: String
}
