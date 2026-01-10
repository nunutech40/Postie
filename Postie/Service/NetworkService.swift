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

enum DownloadUpdate {
    case progress(Double, String)    // (Persentase 0.0-1.0, Label "10MB / 100MB")
    case indeterminate(String)      // (Label "10MB received" - jika total gaib)
    case finished
    case error(String)
}

struct NetworkService {
    
    /// **Algorithm: Custom Session Configuration**
    /// Membuat sesi kustom untuk mengontrol perilaku jaringan aplikasi.
    /// 1. `timeoutIntervalForRequest`: Membatasi waktu tunggu respon (30 detik).
    /// 2. `urlCache = nil`: Mematikan cache agar testing API selalu mendapatkan data terbaru dari server.
    /// 3. `waitsForConnectivity`: Menunda request jika koneksi hilang sementara, alih-alih langsung gagal.
    private static var customSession: URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15.0 // 30 detik kelamaan buat testing, 15s cukup
        config.urlCache = nil
        
        // MATIKAN INI! Biar kalau error langsung "jeder" keluar, nggak nunggu.
        config.waitsForConnectivity = false
        
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
                body: prettyPrintJSON(responseString),
                rawData: data
            )
            
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw PostieError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                throw PostieError.noInternet
            
            // Gunakan dua ini untuk menangkap server Vapor yang mati/off
            case .cannotConnectToHost, .cannotFindHost:
                throw PostieError.serverDown
                
            default:
                throw PostieError.unknown(error.localizedDescription)
            }
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
    
    /// **Algorithm: Stream-based Download**
    /// Membuka pipa data asinkron untuk memantau trafik download secara real-time.
    /// **OPTIMIZATION**: Update progres di-throttle untuk menghindari CPU overhead dan UI lag.
    /// - Determinate: Update dikirim setiap kenaikan 1%.
    /// - Indeterminate: Update dikirim setiap 1 MB.
    static func downloadWithProgress(url: URL) -> AsyncStream<DownloadUpdate> {
        AsyncStream { continuation in
            let task = Task {
                do {
                    // 1. Inisialisasi Stream dari URLSession
                    let (bytes, response) = try await customSession.bytes(from: url)
                    
                    // 2. Metadata
                    let totalBytes = Double(response.expectedContentLength)
                    var bytesReceived = 0.0
                    
                    // Variabel untuk throttling
                    var lastYieldedProgress = -1.0
                    let reportingIncrement = 0.01 // 1%
                    var bytesSinceLastYield = 0
                    let indeterminateReportingChunk = 1024 * 1024 // 1 MB

                    // 3. Iterasi byte-stream dengan throttling
                    for try await _ in bytes {
                        bytesReceived += 1
                        
                        if totalBytes > 0 {
                            // KASUS A: Determinate (Ada Progress Bar)
                            let progress = bytesReceived / totalBytes
                            if progress >= lastYieldedProgress + reportingIncrement {
                                let info = "\(formatBytes(bytesReceived)) / \(formatBytes(totalBytes))"
                                continuation.yield(.progress(progress, info))
                                lastYieldedProgress = progress
                            }
                        } else {
                            // KASUS B: Indeterminate (Hanya angka yang nambah)
                            bytesSinceLastYield += 1
                            if bytesSinceLastYield >= indeterminateReportingChunk {
                                let info = "\(formatBytes(bytesReceived)) downloaded"
                                continuation.yield(.indeterminate(info))
                                bytesSinceLastYield = 0
                            }
                        }
                    }
                    
                    // Pastikan update terakhir (100%) dikirim
                    if totalBytes > 0 {
                        let info = "\(formatBytes(totalBytes)) / \(formatBytes(totalBytes))"
                        continuation.yield(.progress(1.0, info))
                    }
                    
                    continuation.yield(.finished)
                    continuation.finish()
                    
                } catch {
                    // Jangan kirim error jika task dibatalkan oleh user
                    if !(error is CancellationError) {
                        continuation.yield(.error(error.localizedDescription))
                    }
                    continuation.finish()
                }
            }
            
            // Handle jika user membatalkan request dari UI
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
    
    /// **Helper: Byte Formatter**
    /// Konversi angka bytes ke format manusiawi (MB, GB, dll) untuk UI.
    private static func formatBytes(_ bytes: Double) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
