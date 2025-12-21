//
//  NetworkService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Foundation

// 1. UPDATE STRUCT INI: Tambahkan 'headers'
struct APIResponse {
    let statusCode: Int
    let latency: Double
    let headers: [String: String] // <--- WAJIB DITAMBAH
    let body: String
}

struct NetworkService {
    
    static func performRequest(url: String,
                               method: String,
                               headers: [String: String],
                               body: String?) async throws -> APIResponse {
        
        guard let urlObj = URL(string: url) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }
        
        var request = URLRequest(url: urlObj)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        if let bodyStr = body, !bodyStr.isEmpty, method != "GET" {
            request.httpBody = bodyStr.data(using: .utf8)
        }
        
        let startTime = Date()
        let (data, response) = try await URLSession.shared.data(for: request)
        let endTime = Date()
        
        let latencyMs = endTime.timeIntervalSince(startTime) * 1000
        
        // 2. LOGIC EXTRAKSI HEADERS
        let httpResponse = response as? HTTPURLResponse
        let statusCode = httpResponse?.statusCode ?? 0
        
        // Ubah format headers dari [AnyHashable: Any] jadi [String: String]
        var responseHeaders = [String: String]()
        httpResponse?.allHeaderFields.forEach { (key, value) in
            if let k = key as? String, let v = value as? String {
                responseHeaders[k] = v
            }
        }
        
        let responseString = String(data: data, encoding: .utf8) ?? ""
        let prettyBody = prettyPrintJSON(responseString)
        
        return APIResponse(
            statusCode: statusCode,
            latency: latencyMs,
            headers: responseHeaders, // <--- MASUKIN KESINI
            body: prettyBody
        )
    }
    
    static func prettyPrintJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return prettyString
    }
}
