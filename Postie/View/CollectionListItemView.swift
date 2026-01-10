//
//  CollectionListItemView.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct CollectionListItemView: View {
    @Binding var collection: RequestCollection // Change to Binding
    @ObservedObject var viewModel: HomeViewModel // ViewModel to access confirmation/rename functions

    var body: some View {
        HStack {
            Text(collection.name)
            Spacer()
            // Three-dot button for actions
            Button(action: {}) {
                Image(systemName: "ellipsis.circle")
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button("Rename") {
                    viewModel.confirmRenameCollection(id: collection.id)
                }
                Button("Delete", role: .destructive) {
                    viewModel.confirmDeleteCollection(id: collection.id)
                }
            }
        }
    }
}
