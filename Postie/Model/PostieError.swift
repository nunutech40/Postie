//
//  PostieError.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//
import Foundation

enum PostieError: LocalizedError {
    case invalidURL
    case timeout
    case noInternet
    case serverDown // <-- Tambahin ini, Nu!
    case serverError(Int)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Format URL tidak valid."
        case .timeout: return "Server lelet (Timeout). Coba lagi nanti."
        case .noInternet: return "Internet lo mati, Nu. Cek koneksi."
        case .serverDown: return "Server mati atau alamat salah (Connection Refused)." // <-- Pesan user-friendly
        case .serverError(let code): return "Server error (Kode: \(code))."
        case .unknown(let msg): return msg
        }
    }
}
