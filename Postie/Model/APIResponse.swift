//
//  APIResponse.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

struct APIResponse {
    let statusCode: Int
    let latency: Double
    let headers: [String: String] // <--- WAJIB DITAMBAH
    let body: String
}
