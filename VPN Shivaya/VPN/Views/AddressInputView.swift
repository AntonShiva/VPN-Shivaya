//
//  AddressInputView.swift
//  VPN Shivaya
//
//  Created by Anton Rasen on 11.02.2025.
//

import SwiftUI

struct AddressInputView: View {
    @Binding var vlessAddress: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Большое поле для ввода
                TextEditor(text: $vlessAddress)
                    .font(.system(size: 16))
                    .frame(height: UIScreen.main.bounds.height / 3) // Треть экрана
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding()
                
                // Placeholder когда поле пустое
                if vlessAddress.isEmpty {
                    Text("Вставьте VLESS адрес")
                        .foregroundStyle(.gray)
                        .padding(.horizontal)
                        .position(x: UIScreen.main.bounds.width / 2, y: 30)
                }
                
                Spacer()
                
                Button("Сохранить") {
                    isPresented = false
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: 200, height: 60)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.bottom, 30)
            }
            .navigationTitle("Добавление адреса")
            .navigationBarItems(trailing: Button("Отмена") {
                isPresented = false
            })
        }
    }
}

#Preview {
    AddressInputView(
        vlessAddress: .constant(""),
        isPresented: .constant(true)
    )
}


