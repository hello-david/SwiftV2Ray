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
    private var openVPNClosure: ((_ error: Error?) -> Void)? = nil
    
    func open(_ configData: Data, completion: @escaping((_ error: Error?) -> Void)) {
        guard openVPNClosure == nil else {
            completion(NSError(domain: "VPNHelper", code: -1, userInfo: ["error" : "正在处理中"]))
            return
        }
        self.openVPNClosure = completion
        
        let fetchClosure = {[weak self] (manager: NETunnelProviderManager?, error: Error?) in
            var openError = error
            guard let manager = manager else {
                completion(openError)
                return
            }
            
            guard manager.connection.status != .connected else {
                completion(nil)
                self?.openVPNClosure = nil
                return
            }
            
            manager.isOnDemandEnabled = true
            manager.isEnabled = true
            do {
                // 先发送配置到PacketTunel上
                let session = manager.connection as? NETunnelProviderSession
                try session?.sendProviderMessage(configData, responseHandler: { (data) in
                    print("发送配置成功")
                    do {
                        try manager.connection.startVPNTunnel()
                    } catch let starError {
                        NSLog(starError.localizedDescription)
                        openError = starError
                    }
                    
                    guard openError == nil else {
                        completion(openError)
                        self?.stopObservingStatus(manager)
                        return
                    }
                    
                    self?.observeStatus(manager)
                    self?.manager = manager
                })
            }
            catch let error {
                completion(error)
                self?.stopObservingStatus(manager)
            }
        }
        
        // 获取VPN配置
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard let vpnManagers = managers else {
                fetchClosure(nil, error)
                return
            }
            
            for manager in vpnManagers {
                if (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier == "com.david.SwiftV2Ray.PacketTunnel" {
                    fetchClosure(manager, nil)
                    return
                }
            }
            
            let manager = NETunnelProviderManager()
            manager.protocolConfiguration = NETunnelProviderProtocol()
            (manager.protocolConfiguration as? NETunnelProviderProtocol)?.providerBundleIdentifier = "com.david.SwiftV2Ray.PacketTunnel"
            manager.protocolConfiguration?.serverAddress = "127.0.0.1"
            manager.localizedDescription = "SwiftV2Ray VPN"
            manager.saveToPreferences(completionHandler: { (error) in
                if error != nil {
                    fetchClosure(nil, error)
                    return
                }
                
                manager.loadFromPreferences(completionHandler: { (error) in
                    fetchClosure(manager, error)
                })
            })
        }
    }
    
    func close() {
        guard let manager = self.manager else {
            return
        }
        
        manager.connection.stopVPNTunnel()
        self.stopObservingStatus(manager)
    }
    
    private func observeStatus(_ manager: NETunnelProviderManager) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main,using: {
            [weak self] notification in
            let connection = notification.object as? NEVPNConnection
            switch connection?.status {
                case .none:
                    print("无")
                
                case .some(.invalid):
                    print("无效")
                    self?.openVPNClosure?(NSError(domain: "VPNHelper", code: (connection?.status)!.rawValue, userInfo: ["error" : "连接无效"]))
                    self?.openVPNClosure = nil
                
                case .some(.connecting):
                    print("VPN通道连接中")
                
                case .some(.connected):
                    print("VPN通道连接上了")
                    self?.openVPNClosure?(nil)
                    self?.openVPNClosure = nil
                
                case .some(.reasserting):
                    print("断言")
                    self?.openVPNClosure?(NSError(domain: "VPNHelper", code: (connection?.status)!.rawValue, userInfo: ["error" : "断言"]))
                    self?.openVPNClosure = nil
                
                case .some(.disconnecting):
                    print("VPN通道断开连接了")
                    self?.openVPNClosure?(NSError(domain: "VPNHelper", code: (connection?.status)!.rawValue, userInfo: ["error" : "断开连接"]))
                    self?.openVPNClosure = nil
                
                case .some(_):
                    print("其他")
                    self?.openVPNClosure?(NSError(domain: "VPNHelper", code: (connection?.status)!.rawValue, userInfo: ["error" : "其他"]))
                    self?.openVPNClosure = nil
            }
        })
    }

    private func stopObservingStatus(_ manager: NETunnelProviderManager) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection)
    }
}
