//
//  NetworkService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import Foundation

struct NetworkService {
    
    /// **Algorithm: Custom Session Configuration**
    /// Membuat sesi kustom untuk mengontrol perilaku jaringan aplikasi.
    /// 1. `timeoutIntervalForRequest`: Membatasi waktu tunggu respon (30 detik).
    /// 2. `urlCache = nil`: Mematikan cache agar testing API selalu mendapatkan data terbaru dari server.
    /// 3. `waitsForConnectivity`: Menunda request jika koneksi hilang sementara, alih-alih langsung gagal.
    private static var customSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.urlCache = nil
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }
    
    /// **Logic: Perform HTTP Request**
    /// Alur Eksekusi:
    /// 1. **Validation**: Membersihkan URL dari spasi liar dan memvalidasi formatnya.
    /// 2. **Preparation**: Injeksi Method, Headers, dan Body (khusus POST/PUT/PATCH).
    /// 3. **Latency Tracking**: Menghitung waktu mulai dan akhir request untuk mendapatkan durasi milidetik.
    /// 4. **Response Parsing**: Mengonversi `HTTPURLResponse` menjadi `APIResponse` yang bersih.
    /// 5. **Error Mapping**: Menangkap `URLError` sistem dan menerjemahkannya ke `PostieError` yang manusiawi.
    static func performRequest(url: String,
                               method: String,
                               headers: [String: String],
                               body: String?) async throws -> APIResponse {
        
        guard let urlObj = URL(string: url.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw PostieError.invalidURL
        }
        
        var request = URLRequest(url: urlObj)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        // Hanya sertakan body jika method mendukung payload
        if let bodyStr = body, !bodyStr.isEmpty, ["POST", "PUT", "PATCH"].contains(method) {
            request.httpBody = bodyStr.data(using: .utf8)
        }
        
        do {
            let startTime = Date()
            let (data, response) = try await customSession.data(for: request)
            let endTime = Date()
            
            let latencyMs = endTime.timeIntervalSince(startTime) * 1000
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PostieError.unknown("Respon server bukan format HTTP.")
            }
            
            // Konversi metadata headers dari sistem ke Dictionary standar [String: String]
            var responseHeaders = [String: String]()
            httpResponse.allHeaderFields.forEach { (key, value) in
                if let k = key as? String, let v = value as? String {
                    responseHeaders[k] = v
                }
            }
            
            let responseString = String(data: data, encoding: .utf8) ?? ""
            
            return APIResponse(
                statusCode: httpResponse.statusCode,
                latency: latencyMs,
                headers: responseHeaders,
                body: prettyPrintJSON(responseString)
            )
            
        } catch let error as URLError {
            // Pemetaan error sistem macOS ke bahasa yang dimengerti user
            switch error.code {
            case .timedOut: throw PostieError.timeout
            case .notConnectedToInternet, .networkConnectionLost: throw PostieError.noInternet
            default: throw PostieError.unknown(error.localizedDescription)
            }
        } catch {
            throw error
        }
    }
    
    /// **Logic: JSON Beautifier**
    /// Mengubah string JSON mentah menjadi format yang terbaca (Indented).
    /// Menggunakan `JSONSerialization` untuk parse dan encode ulang dengan opsi `.prettyPrinted`.
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
