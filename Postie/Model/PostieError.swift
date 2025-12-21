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
    case serverError(Int)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Format URL tidak valid."
        case .timeout: return "Request terlalu lama (Timeout). Server mungkin sibuk."
        case .noInternet: return "Koneksi internet terputus atau tidak stabil."
        case .serverError(let code): return "Server merespon dengan error (Kode: \(code))."
        case .unknown(let msg): return msg
        }
    }
}
