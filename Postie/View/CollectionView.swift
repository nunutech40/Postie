//
//  CollectionView.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct CollectionView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .frame(minWidth: 700, minHeight: 400)
        .overlay(toastOverlay, alignment: .bottom)
    }

    // MARK: - Sidebar Content
    private var sidebarContent: some View {
        VStack {
            List(selection: $viewModel.selectedCollectionID) {
                ForEach($viewModel.collections) { $collection in
                    CollectionListItemView(collection: $collection, viewModel: viewModel)
                        .tag(collection.id)
                }
                .onDelete(perform: viewModel.deleteCollection)
            }
            
            Divider()
            
            HStack {
                Button(action: {
                    viewModel.addNewCollection()
                }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 8)
                .help("Add New Collection")
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Detail Content
    private var detailContent: some View {
        VStack {
            if let selectedCollection = viewModel.selectedCollection {
                if selectedCollection.requests.isEmpty {
                    RequestListEmptyStateView()
                } else {
                    List {
                        ForEach(selectedCollection.requests) { request in
                            RequestRowView(request: request, viewModel: viewModel, dismiss: _dismiss)
                        }
                        .onDelete(perform: viewModel.deleteRequestFromCollection)
                    }
                }
            } else {
                CollectionEmptyStateView()
            }
        }
        .navigationTitle(viewModel.selectedCollection?.name ?? "Collections")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.addCurrentRequestToCollection()
                }) {
                    Label("Add Current", systemImage: "plus")
                }
                .disabled(viewModel.selectedCollection == nil)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.saveCollections()
                }) {
                    Label("Save All", systemImage: "square.and.arrow.down")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    viewModel.loadCollections()
                }) {
                    Label("Load", systemImage: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Toast Overlay
    private var toastOverlay: some View {
        Group {
            if viewModel.showToast {
                ToastView(message: viewModel.toastMessage)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .padding(.bottom)
    }
}
