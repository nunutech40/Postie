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
            // Sidebar: List of collections
            VStack {
                List(selection: $viewModel.selectedCollectionID) {
                    ForEach($viewModel.collections) { $collection in
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
                        // Tag for selection must be on the item that provides the selection value
                        // In this case, it should be on the view that *represents* the row's selection value
                        // which is implicitly handled by the ForEach when used with List selection.
                        // However, for explicit tagging for selection consistency, it's better to put it on the container.
                        // If we can't put it on the container, we rely on SwiftUI's implicit behavior.
                        // Let's rely on implicit behavior for now and see if selection breaks.
                        // If it breaks, we might need to rethink the conditional view and use an overlay or similar.
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
            
        } detail: {
            VStack {
                // Content: Requests in the selected collection
                if let selectedCollection = viewModel.selectedCollection {
                    List {
                        ForEach(selectedCollection.requests) { request in
                            HStack {
                                Text(request.method)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(MethodColor.color(for: request.method))
                                    .cornerRadius(4)
                                
                                Text(request.url).lineLimit(1)
                                Spacer()
                                Button(action: {
                                    viewModel.loadRequestFromCollection(request: request)
                                    dismiss()
                                }) {
                                    Image(systemName: "arrow.up.forward.app")
                                }
                            }
                        }
                        .onDelete(perform: viewModel.deleteRequestFromCollection)
                    }
                } else {
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
        .frame(minWidth: 700, minHeight: 400)
        .overlay(
            Group {
                if viewModel.showToast {
                    ToastView(message: viewModel.toastMessage)
                        .transition(.opacity.animation(.easeInOut))
                }
            },
            alignment: .bottom
        )
    }
}