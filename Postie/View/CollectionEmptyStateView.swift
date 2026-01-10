//
//  CollectionEmptyStateView.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct CollectionEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No Collection Selected")
                .font(.title2)
            Text("Select a collection from the sidebar or create a new one.")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CollectionEmptyStateView()
}
