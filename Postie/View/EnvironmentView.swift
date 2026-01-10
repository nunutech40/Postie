//
//  EnvironmentView.swift
//  Postie
//
//  Created by Nunu Nugraha on 25/12/25.
//

import SwiftUI

struct EnvironmentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedEnvironmentID: UUID?
    
    var body: some View {
        HSplitView {
            environmentList
                .frame(minWidth: 150, idealWidth: 200)
            
            if let selectedID = selectedEnvironmentID,
               let index = viewModel.environments.firstIndex(where: { $0.id == selectedID }) {
                VariableEditor(environment: $viewModel.environments[index])
                    .frame(minWidth: 300)
            } else {
                Text("Select an environment to edit, or create a new one.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if selectedEnvironmentID == nil {
                selectedEnvironmentID = viewModel.environments.first?.id
            }
        }
    }
    
    private var environmentList: some View {
        VStack {
            List(selection: $selectedEnvironmentID) {
                ForEach(viewModel.environments) { env in
                    Text(env.name).tag(env.id)
                }
                .onDelete(perform: viewModel.deleteEnvironment)
            }
            .listStyle(SidebarListStyle())
            
            HStack {
                Button(action: {
                    let newEnv = PostieEnvironment(name: "New Environment", variables: [:])
                    viewModel.addEnvironment(newEnv)
                    selectedEnvironmentID = newEnv.id
                }) {
                    Image(systemName: "plus")
                }
                
                Button(action: {
                    if let selectedID = selectedEnvironmentID,
                       let indexSet = indexSet(for: selectedID) {
                        viewModel.deleteEnvironment(at: indexSet)
                    }
                }) {
                    Image(systemName: "minus")
                }
                .disabled(selectedEnvironmentID == nil)
                
                Spacer()
            }
            .padding()
        }
    }

    private func indexSet(for environmentId: UUID) -> IndexSet? {
        if let index = viewModel.environments.firstIndex(where: { $0.id == environmentId }) {
            return IndexSet(integer: index)
        }
        return nil
    }
}

struct VariableEditor: View {
    @Binding var environment: PostieEnvironment
    
    @State private var newKey: String = ""
    @State private var newValue: String = ""
    @State private var showHelp = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Environment: \(environment.name)")
                .font(.title2).bold()
            
            TextField("Environment Name", text: $environment.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Divider()
            
            HStack {
                Text("Variables").font(.headline)
                Spacer()
                Button(action: { showHelp = true }) {
                    Image(systemName: "questionmark.circle")
                }
                .buttonStyle(PlainButtonStyle())
                .popover(isPresented: $showHelp, arrowEdge: .bottom) {
                    EnvironmentHelpView()
                }
            }
            
            ForEach(environment.variables.keys.sorted(), id: \.self) { key in
                HStack {
                    TextField("Key", text: .constant(key))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Value", text: Binding(
                        get: { environment.variables[key, default: ""] },
                        set: { environment.variables[key] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        environment.variables[key] = nil
                    }) {
                        Image(systemName: "trash")
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            
            HStack {
                TextField("New Key", text: $newKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("New Value", text: $newValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addVariable) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(newKey.isEmpty)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func addVariable() {
        if !newKey.isEmpty {
            environment.variables[newKey] = newValue
            newKey = ""
            newValue = ""
        }
    }
}

struct EnvironmentHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Cara Menggunakan Environment")
                .font(.title2)

            Text("Dropdown Environment berfungsi sebagai 'saklar' untuk mengganti satu set variabel dengan set lainnya secara cepat, tanpa perlu mengedit URL atau header secara manual.")
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("Contoh Kasus:")
                    .font(.headline)

                Text("1. Buat Dua Environment:")
                    .fontWeight(.bold)
                Text("""
                     • **Environment 1: "Staging"**
                       - Variabel: `baseURL` = `https://api.staging.com`
                       - Variabel: `apiKey` = `staging-secret-123`

                     • **Environment 2: "Production"**
                       - Variabel: `baseURL` = `https://api.production.com`
                       - Variabel: `apiKey` = `prod-secret-xyz`
                     """)

                Text("2. Gunakan Variabel di Request Anda:")
                    .fontWeight(.bold)
                Text("""
                     • Di kolom URL, ketik: `{{baseURL}}/products`
                     • Di kolom Bearer Token, ketik: `{{apiKey}}`
                     """)
                
                Text("3. Hasilnya:")
                    .fontWeight(.bold)
                Text("""
                     • Saat Anda memilih **"Staging"** dari dropdown, request akan dikirim ke `https://api.staging.com/products`.
                     • Saat Anda memilih **"Production"**, request akan dikirim ke `https://api.production.com/products`.
                     """)
            }
        }
        .frame(width: 400)
        .padding()
    }
}