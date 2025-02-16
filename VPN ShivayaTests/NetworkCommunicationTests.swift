//
//  NetworkCommunicationTests.swift
//  VPN ShivayaTests
//
//  Created by Anton Rasen on 10.02.2025.
//

import Foundation
import XCTest
import NetworkExtension
import Network
@testable import VPN_Shivaya


final class NetworkCommunicationTests: XCTestCase {
    
    func testTunnelCommunication() async throws {
        // 1. Создаем тестовое сообщение
        let testMessage = "test_message"
        let messageData = testMessage.data(using: .utf8)!
        
        // 2. Создаем и настраиваем менеджер
        let manager = NETunnelProviderManager()
        let providerProtocol = NETunnelProviderProtocol()
        
        // Важно: правильный bundle identifier
        providerProtocol.providerBundleIdentifier = "com.Anton-Reasin.VPN-Shivaya.VPNShivayaTunnel"
        
        // Добавляем обязательные настройки
        providerProtocol.serverAddress = "localhost"
        providerProtocol.disconnectOnSleep = false
        providerProtocol.includeAllNetworks = true
        
        // Добавляем конфигурацию
        providerProtocol.providerConfiguration = ["VPNType": "VLESS"]
        
        // Применяем настройки к менеджеру
        manager.protocolConfiguration = providerProtocol
        manager.localizedDescription = "VPN Shivaya Test"
        manager.isEnabled = true
        
        // Важно: сохраняем настройки
        try await manager.saveToPreferences()
        try await manager.loadFromPreferences()
        
        // 3. Проверяем сессию
        guard let providerSession = manager.connection as? NETunnelProviderSession else {
            XCTFail("Не удалось получить сессию туннеля")
            return
        }
        
        // 4. Запускаем туннель
        try manager.connection.startVPNTunnel()
        
        // Ждем подключения
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        // 5. Отправляем сообщение
        let responseData = try await withCheckedThrowingContinuation { continuation in
            do {
                try providerSession.sendProviderMessage(messageData) { responseData in
                    continuation.resume(returning: responseData ?? Data())
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
        
        // 6. Проверяем ответ
        let responseString = String(data: responseData, encoding: .utf8)
        XCTAssertEqual(responseString, testMessage)
        
        // 7. Останавливаем туннель
        manager.connection.stopVPNTunnel()
    }
}
