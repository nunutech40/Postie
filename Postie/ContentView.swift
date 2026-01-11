//
//  ContentView.swift
//  Postie
//
//  Created by Nunu Nugraha on 21/12/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                HomeView()
                    .padding()
            } else {
                OnboardingView()
            }
        }
    }
}

#Preview {
    ContentView()
}
