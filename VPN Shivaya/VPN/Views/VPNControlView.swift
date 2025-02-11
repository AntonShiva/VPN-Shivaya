//
//  ContentView.swift
//  VPN Shivaya
//
//  Created by Anton Rasen on 10.02.2025.
//

import SwiftUI

struct VPNControlView: View {
    @State private var isConnected = false
      @State private var isShowingAddressInput = false
      @State private var vlessAddress = ""
      
      var body: some View {
          VStack(spacing: 20) {
              // Статус соединения
              Text(isConnected ? "Подключено" : "Отключено")
                  .font(.headline)
                  .foregroundStyle(isConnected ? .green : .red)
              
              // Кнопка подключения
              Button(action: {
                  isConnected.toggle()
              }) {
                  Text(isConnected ? "Отключить" : "Подключить")
                      .font(.title2)
                      .fontWeight(.semibold)
                      .foregroundStyle(.white)
                      .frame(width: 200, height: 60)
                      .background(isConnected ? .red : .blue)
                      .clipShape(RoundedRectangle(cornerRadius: 30))
              }
              .buttonStyle(.plain)
              
              // Кнопка добавления адреса
              Button(action: {
                  isShowingAddressInput = true
              }) {
                  Text("Добавьте свой адрес")
                      .font(.title2)
                      .fontWeight(.semibold)
                      .foregroundStyle(.white)
                      .frame(width: 200, height: 60)
                      .background(.green)
                      .clipShape(RoundedRectangle(cornerRadius: 30))
              }
              .buttonStyle(.plain)
              .sheet(isPresented: $isShowingAddressInput) {
                  AddressInputView(vlessAddress: $vlessAddress, isPresented: $isShowingAddressInput)
              }
          }
          .padding()
      }
}

#Preview {
    VPNControlView()
}
