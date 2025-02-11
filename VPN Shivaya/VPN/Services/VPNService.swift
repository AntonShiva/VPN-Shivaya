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
}
