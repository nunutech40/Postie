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
    
    // 3. CUSTOM SESSION CONFIGURATION (Biar bisa set Timeout)
    private static var customSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0 // Timeout 30 detik
        config.urlCache = nil // Fresh data terus, gak perlu cache
        config.waitsForConnectivity = true // Tunggu koneksi kalo tiba-tiba ilang
        return URLSession(configuration: config)
    }
    
    static func performRequest(url: String,
                               method: String,
                               headers: [String: String],
                               body: String?) async throws -> APIResponse {
        
        // Cek Validasi URL
        guard let urlObj = URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw PostieError.invalidURL
        }
        
        var request = URLRequest(url: urlObj)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        if let bodyStr = body, !bodyStr.isEmpty, ["POST", "PUT", "PATCH"].contains(method) {
            request.httpBody = bodyStr.data(using: .utf8)
        }
        
        do {
            let startTime = Date()
            // Pakai customSession bukan URLSession.shared
            let (data, response) = try await customSession.data(for: request)
            let endTime = Date()
            
            let latencyMs = endTime.timeIntervalSince(startTime) * 1000
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PostieError.unknown("Respon bukan HTTP.")
            }
            
            // Ekstraksi Headers
            var responseHeaders = [String: String]()
            httpResponse.allHeaderFields.forEach { (key, value) in
                if let k = key as? String, let v = value as? String {
                    responseHeaders[k] = v
                }
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            let prettyBody = prettyPrintJSON(responseString)
            
            return APIResponse(
                statusCode: httpResponse.statusCode,
                latency: latencyMs,
                headers: responseHeaders,
                body: prettyBody
            )
            
        } catch let error as URLError {
            // MAPPING URLError ke PostieError
            switch error.code {
            case .timedOut:
                throw PostieError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                throw PostieError.noInternet
            default:
                throw PostieError.unknown(error.localizedDescription)
            }
        } catch {
            throw error
        }
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
