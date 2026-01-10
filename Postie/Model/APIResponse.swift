//
//  APIResponse.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Foundation

struct APIResponse {
    let statusCode: Int
    let latency: Double
    let headers: [String: String]
    let body: String
    let rawData: Data
}
