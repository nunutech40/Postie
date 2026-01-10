//
//  CollectionListItemView.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct CollectionListItemView: View {
    @Binding var collection: RequestCollection
    @ObservedObject var viewModel: HomeViewModel // ViewModel to access editingCollectionID

    var body: some View {
        if viewModel.editingCollectionID == collection.id {
            TextField("Collection Name", text: $collection.name)
                .textFieldStyle(.plain)
                .onSubmit {
                    viewModel.editingCollectionID = nil
                }
        } else {
            Text(collection.name)
                .onTapGesture(count: 2) {
                    viewModel.editingCollectionID = collection.id
                }
        }
    }
}
