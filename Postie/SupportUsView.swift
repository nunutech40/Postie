//
//  SupportUsView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import SwiftUI

struct SupportUsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.pink)
            
            Text("Support Development")
                .font(.title2).bold()
            
            Text("Postie dibangun sendirian dengan penuh cinta (dan kopi). Jika aplikasi ini membantu pekerjaanmu, traktir saya kopi!")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Link(destination: URL(string: "https://saweria.co/nunu")!) { // Ganti link lo
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                    Text("Buy me a Coffee")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.pink)
                .cornerRadius(10)
            }
            .buttonStyle(.plain) // Biar link jadi kayak tombol
            
            Spacer()
        }
        .padding()
    }
}
