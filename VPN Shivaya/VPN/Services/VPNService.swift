//
//  VPNService.swift
//  VPN Shivaya
//
//  Created by Anton Rasen on 11.02.2025.
//

import Foundation
import NetworkExtension
import Network

class VPNService {
    static let shared = VPNService()
    private var tunnelProviderManager: NETunnelProviderManager?
    
    func initialize() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        
        var tunnelManagers = managers ?? []
        var tunnelNames: Set<String> = []
        
        // Проходим по всем менеджерам
        for (index, manager) in tunnelManagers.enumerated().reversed() {
            if let tunnelName = manager.localizedDescription {
                tunnelNames.insert(tunnelName)
            }
            
            // Проверяем протокол
            guard let proto = manager.protocolConfiguration as? NETunnelProviderProtocol else {
                continue
            }
            
            // Проверяем и мигрируем конфигурацию если нужно
            if migrateConfigurationIfNeeded(proto, name: manager.localizedDescription ?? "unknown") {
                try await manager.saveToPreferences()
            }
        }
        
        self.tunnelProviderManager = tunnelManagers.first ?? NETunnelProviderManager()
    }
    
    private func migrateConfigurationIfNeeded(_ proto: NETunnelProviderProtocol, name: String) -> Bool {
        // Проверяем нужна ли миграция
        guard let config = proto.providerConfiguration else {
            return false
        }
        
        var needsMigration = false
        var newConfig = config
        
        // Проверяем и обновляем параметры конфигурации
        if config["VPNType"] as? String != "VLESS" {
            newConfig["VPNType"] = "VLESS"
            needsMigration = true
        }
        
        // Если нужна миграция - обновляем конфигурацию
        if needsMigration {
            proto.providerConfiguration = newConfig
        }
        
        return needsMigration
    }
    
    func startVPN() async throws {
        // Если менеджер не инициализирован - инициализируем
        if tunnelProviderManager == nil {
            try await initialize()
        }
        
        guard let manager = tunnelProviderManager else {
            throw NSError(domain: "VPNError", code: -1, userInfo: [NSLocalizedDescriptionKey: "VPN manager not initialized"])
        }
        
        // Настраиваем протокол если еще не настроен
        if manager.protocolConfiguration == nil {
            let proto = NETunnelProviderProtocol()
            proto.providerBundleIdentifier = "com.Anton-Reasin.VPN.Shivaya.VPNShivayaTunnel"
            proto.serverAddress = "VPN Server"
            
            // Добавляем VLESS конфигурацию
            var providerConfig: [String: Any] = [:]
            providerConfig["VPNType"] = "VLESS"
            proto.providerConfiguration = providerConfig
            
            manager.protocolConfiguration = proto
            manager.localizedDescription = "VPN Shivaya"
            manager.isEnabled = true
            
            try await manager.saveToPreferences()
            try await manager.loadFromPreferences()
        }
        
        // Запускаем VPN
        try manager.connection.startVPNTunnel()
    }
    
    func stopVPN() {
        tunnelProviderManager?.connection.stopVPNTunnel()
    }
}
