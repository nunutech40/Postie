//
//  RequestCollection.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import Foundation

struct RequestCollection: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var requests: [RequestPreset]
}
