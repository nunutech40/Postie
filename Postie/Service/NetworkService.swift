//
//  NetworkService.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

/**
 # NETWORK SERVICE (CORE NETWORKING ENGINE)
 
 ## 1. TUJUAN (PURPOSE)
 NetworkService adalah jantung dari aplikasi Postie yang bertanggung jawab mengelola siklus hidup permintaan HTTP.
 Tujuannya adalah mengeksekusi request secara asinkron, menghitung latensi secara presisi, dan mentransformasi respon mentah dari server menjadi objek `APIResponse` yang siap ditampilkan ke UI.
 
 ## 2. TEKNOLOGI (TECH STACK)
 - **URLSession (Foundation):** Menggunakan engine networking native macOS tanpa library pihak ketiga (zero-dependency) untuk meminimalkan beban RAM dan ukuran binary.
 - **Swift Concurrency (Async/Await):** Mengimplementasikan pola asinkron modern untuk menjaga responsivitas Main Thread saat menunggu respon server.
 - **JSONSerialization:** Melakukan parsing dan formatting JSON menggunakan parser native Apple yang sudah dioptimasi di level sistem operasi.

 

 ## 3. ALGORITMA & FLOW (LOGIC STREAM)
 Alur eksekusi `performRequest` mengikuti logika sekuensial berikut:
 
 1. **Session Configuration:** Inisialisasi `URLSession` dengan konfigurasi `ephemeral` untuk memastikan tidak ada cache atau cookies yang tersimpan secara permanen di disk.
 2. **Request Validation:** Membersihkan URL dari karakter ilegal (whitespaces) sebelum dibungkus ke dalam objek `URLRequest`.
 3. **Payload Injection:** Menyuntikkan Method, Headers, dan Body secara selektif (hanya untuk method POST, PUT, dan PATCH).
 4. **Latency Measurement:** Menangkap `startTime` tepat sebelum request dikirim dan `endTime` segera setelah respon diterima untuk menghitung durasi milidetik yang akurat.
 5. **Error Mapping:** Menerjemahkan kode error sistem (seperti `.timedOut` atau `.notConnectedToInternet`) menjadi kategori error yang dipahami user (`PostieError`).

 ## 4. CATATAN PERFORMA & EFISIENSI (SENIOR INSIGHTS)
 - **Zero-Cache Policy:** Dengan mengatur `config.urlCache = nil`, service ini menghindari konsumsi RAM yang tidak perlu untuk menyimpan histori respon yang besar.
 - **Memory-Friendly Formatting:** Fungsi `prettyPrintJSON` memastikan payload yang berantakan dari server ditampilkan secara terstruktur (Indented) tanpa menggunakan library eksternal yang berat.
 - **Low Footprint:** Penggunaan sesi `ephemeral` secara statis membantu Postie mempertahankan target penggunaan memori di bawah 50MB meskipun menangani payload JSON yang cukup besar.
 */

import Foundation

struct NetworkService {
    
    /// **Algorithm: Custom Session Configuration**
    /// Membuat sesi kustom untuk mengontrol perilaku jaringan aplikasi.
    /// 1. `timeoutIntervalForRequest`: Membatasi waktu tunggu respon (30 detik).
    /// 2. `urlCache = nil`: Mematikan cache agar testing API selalu mendapatkan data terbaru dari server.
    /// 3. `waitsForConnectivity`: Menunda request jika koneksi hilang sementara, alih-alih langsung gagal.
    private static var customSession: URLSession {
        let config = URLSessionConfiguration.ephemeral // tidak menyimpan cookies, cache, sertifikat ke hd
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
