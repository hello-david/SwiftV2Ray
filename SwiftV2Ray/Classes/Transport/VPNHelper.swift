//
//  VPNHelper.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/27.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation
import NetworkExtension

class VPNHelper {
    static let `shared` = VPNHelper()
    var manager: NETunnelProviderManager? = nil
    
    func open(completion: @escaping((_ manager: NETunnelProviderManager?,  _ error: Error?) -> Void)) {
        let closure = { (manager: NETunnelProviderManager?, error: Error?) in
            var openError = error
            if manager != nil {
                manager?.isOnDemandEnabled = true
                manager?.isEnabled = true
                do {
                    try manager?.connection.startVPNTunnel()
                } catch let starError {
                    NSLog(starError.localizedDescription)
                    openError = starError
                }
            }
            
            completion(manager, openError)
        }
        
        // 获取VPN配置
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let vpnManagers = managers else {
                closure(nil, error)
                return
            }
            
            for manager in vpnManagers {
                if (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier == "com.david.SwiftV2Ray.PacketTunnel" {
                    closure(manager, nil)
                    return
                }
            }
            
            let manager = NETunnelProviderManager()
            manager.protocolConfiguration = NETunnelProviderProtocol()
            (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier = "com.david.SwiftV2Ray.PacketTunnel"
            manager.protocolConfiguration?.serverAddress = "SwiftV2Ray Provide"
            manager.localizedDescription = "SwiftV2Ray VPN"
            manager.saveToPreferences(completionHandler: { (error) in
                if error != nil {
                    closure(nil, error)
                    return
                }
                
                manager.loadFromPreferences(completionHandler: { (error) in
                    closure(manager, error)
                })
            })
        }
    }
    
    func close() {
        manager?.connection.stopVPNTunnel()
    }
}
