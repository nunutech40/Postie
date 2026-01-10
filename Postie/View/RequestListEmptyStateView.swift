//
//  RequestListEmptyStateView.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct RequestListEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("Empty Collection")
                .font(.title2)
            Text("Add the current request or load an existing collection.")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    RequestListEmptyStateView()
}
