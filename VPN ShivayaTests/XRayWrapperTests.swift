//
//  XRayWrapperTests.swift
//  VPN ShivayaTests
//
//  Created by Anton Rasen on 12.02.2025.
//

import Foundation
import XCTest
@testable import VPN_Shivaya
import XRayCoreIOSWrapper

final class XRayWrapperTests: XCTestCase {
    func testXRayBasicFunctionality() async throws {
        // 1. Получаем путь к ресурсам теста
        let testBundle = Bundle(for: type(of: self))
        let assetsPath = testBundle.resourcePath ?? testBundle.bundlePath
        print("📂 Assets path: \(assetsPath)")
        
        // 2. Устанавливаем директории и переменные окружения
        XRaySetAssetsDirectory(assetsPath)
        XRaySetXrayEnv("xray.location.asset", assetsPath)
        XRaySetMemoryLimit()
        print("✅ Окружение настроено")
        
        // 3. Создаем VLESS конфигурацию
        let vlessConfig = """
        {
            "log": {
                "loglevel": "debug"
            },
            "inbounds": [{
                "port": 10808,
                "protocol": "socks",
                "settings": {
                    "auth": "noauth",
                    "udp": true
                }
            }],
            "outbounds": [{
                "protocol": "vless",
                "settings": {
                    "vnext": [{
                        "address": "15.188.100.215",
                        "port": 22222,
                        "users": [{
                            "id": "05519058-d2ac-4f28-9e4a-2b2a1386749e",
                            "encryption": "none"
                        }]
                    }]
                },
                "streamSettings": {
                    "network": "ws",
                    "security": "tls",
                    "tlsSettings": {
                        "serverName": "telegram-channel-vlessconfig.sohala.uk",
                        "allowInsecure": false
                    },
                    "wsSettings": {
                        "path": "/telegram-channel-vlessconfig-ws",
                        "headers": {
                            "Host": "telegram-channel-vlessconfig.sohala.uk"
                        }
                    }
                },
                "tag": "proxy"
            }]
        }
        """
        
        // 4. Создаем простой логгер для отладки
        class TestLogger: NSObject, XRayLoggerProtocol {
            func logInput(_ s: String?) {
                if let log = s {
                    print("🔵 XRay Log: \(log)")
                }
            }
        }
        
        let logger = TestLogger()
        var error: NSError?
        
        // 5. Запускаем XRay
        print("🚀 Запускаем XRay...")
        guard let configData = vlessConfig.data(using: .utf8) else {
            throw NSError(domain: "XRayTest", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка кодирования конфигурации"])
        }
        
        let success = XRayStartXray(configData, logger, &error)
        
        // Проверяем успешность запуска
        XCTAssertTrue(success, "XRay должен успешно запуститься")
        if let error = error {
            print("❌ Ошибка запуска XRay: \(error)")
            throw error
        }
        
        print("✅ XRay запущен успешно")
        
        // 6. Даем время на инициализацию
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 секунды
        
        // 7. Проверяем реальное соединение
        print("🌐 Проверяем соединение...")
        let isConnected = await testConnection()
        XCTAssertTrue(isConnected, "Должно быть активное соединение через прокси")
        
        // 8. Останавливаем XRay
        print("🛑 Останавливаем XRay")
        XRayStopXray()
    }
    
    private func testConnection() async -> Bool {
        print("🔄 Настройка прокси...")
        let configuration = URLSessionConfiguration.default
        configuration.connectionProxyDictionary = [
            kCFProxyHostNameKey: "127.0.0.1",
            kCFProxyPortNumberKey: 10808,
            kCFProxyTypeKey: kCFProxyTypeSOCKS
        ]
        
        print("📡 Создание сессии...")
        let session = URLSession(configuration: configuration)
        guard let url = URL(string: "https://www.google.com") else {
            print("❌ Неверный URL")
            return false
        }
        
        do {
            print("🌐 Отправка запроса...")
            let (_, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Неверный тип ответа")
                return false
            }
            
            let isSuccess = (200...299).contains(httpResponse.statusCode)
            print(isSuccess ? "✅ Соединение успешно (код \(httpResponse.statusCode))" : "❌ Ошибка соединения (код \(httpResponse.statusCode))")
            return isSuccess
        } catch {
            print("❌ Ошибка соединения: \(error)")
            return false
        }
    }
    
    override func tearDown() {
        super.tearDown()
        XRayStopXray()
        print("🧹 Тест завершен, XRay остановлен")
    }
}
