//
//  RequestRowView.swift
//  Postie
//
//  Created by Nunu Nugraha on 27/12/25.
//

import SwiftUI

struct RequestRowView: View {
    let request: RequestPreset
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
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
            Button(action: {
                viewModel.deleteRequestFromCollection(id: request.id)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}
