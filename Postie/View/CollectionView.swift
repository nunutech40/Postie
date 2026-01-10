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
        VStack {
            Text(viewModel.requestCollection.name)
                .font(.title)
                .padding()

            if viewModel.requestCollection.requests.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("Empty Collection")
                        .font(.title2)
                    Text("Add the current request or load an existing collection.")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                List {
                    ForEach(viewModel.requestCollection.requests) { request in
                        HStack {
                            Text(request.method)
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Color.blue)
                                .cornerRadius(5)
                            Text(request.url)
                                .lineLimit(1)
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
            }
            
            Divider()
            
            HStack {
                Button(action: {
                    viewModel.addCurrentRequestToCollection()
                }) {
                    Label("Add Current", systemImage: "plus")
                }
                
                Button(action: {
                    viewModel.saveCollection()
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                
                Button(action: {
                    viewModel.loadCollection()
                }) {
                    Label("Load", systemImage: "square.and.arrow.up")
                }
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
            }
            .padding()
        }
        .frame(minWidth: 600, idealWidth: 700, minHeight: 400, idealHeight: 500)
        .overlay(
            Group {
                if viewModel.showToast {
                    ToastView(message: viewModel.toastMessage)
                        .transition(.opacity.animation(.easeInOut))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    viewModel.showToast = false
                                }
                            }
                        }
                }
            }
            .padding(.bottom)
            , alignment: .bottom
        )
    }
}