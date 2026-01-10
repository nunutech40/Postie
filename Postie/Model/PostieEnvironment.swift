//
//  PostieEnvironment.swift
//  Postie
//
//  Created by Nunu Nugraha on 25/12/25.
//

import Foundation

struct PostieEnvironment: Codable, Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var variables: [String: String]

    static func == (lhs: PostieEnvironment, rhs: PostieEnvironment) -> Bool {
        lhs.id == rhs.id
    }
}
