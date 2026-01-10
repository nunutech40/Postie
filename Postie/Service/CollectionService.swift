//
//  CollectionService.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import Foundation

struct CollectionService {
    
    static func save(collections: [RequestCollection], to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(collections)
        try data.write(to: url)
    }

    static func load(from url: URL) throws -> [RequestCollection] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([RequestCollection].self, from: data)
    }
}