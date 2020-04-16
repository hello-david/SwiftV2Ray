//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by David.Dai on 2020/1/17.
//  Copyright © 2020 david. All rights reserved.
//

import NetworkExtension
import libtun2socks
import V2rayCore

class PacketTunnelProvider: NEPacketTunnelProvider {
    var message: PacketTunnelMessage? = nil
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // 启动Tun2scoks和V2rayCore
        if let configData = message?.configData {
            // ...
            
            V2rayCoreStartWithJsonData(configData)
        } else {
            completionHandler(NSError(domain: "PacketTunnel", code: -1, userInfo: ["error" : "读取不到配置"]))
            return
        }

        // 配置PacketTunel
        self.setupTunnel(message: message!) {(error) in
            completionHandler(error)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        message = try? JSONDecoder().decode(PacketTunnelMessage.self, from: messageData)
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func wake() {
        
    }
}

extension PacketTunnelProvider {
    func setupTunnel(message: PacketTunnelMessage, _ completion: @escaping((_ error: Error?) -> Void)) {
        guard let serverIP = message.serverIP else {
            completion(NSError(domain: "PacketTunnel", code: -1, userInfo: ["error" : "没有IP地址"]))
            return
        }
        
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverIP)
        networkSettings.mtu = 1500
        
        let ipv4Settings = NEIPv4Settings(addresses: [serverIP], subnetMasks: ["255.255.255.0"])
        var includeRoutes: Array<NEIPv4Route> = []
        for route in message.ipv4IncludedRoutes {
            includeRoutes.append(NEIPv4Route(destinationAddress: route.0, subnetMask: route.1))
        }
        var excludeRoutes: Array<NEIPv4Route> = []
        for route in message.ipv4ExcludedRoutes {
            excludeRoutes.append(NEIPv4Route(destinationAddress: route.0, subnetMask: route.1))
        }
        ipv4Settings.includedRoutes = includeRoutes.count == 0 ? [NEIPv4Route.default()] : includeRoutes
        ipv4Settings.excludedRoutes = excludeRoutes
        networkSettings.ipv4Settings = ipv4Settings
        networkSettings.dnsSettings =  NEDNSSettings(servers: message.dnsServers)
        
        let proxySettings = NEProxySettings()
        proxySettings.httpEnabled = true
        proxySettings.httpsEnabled = true
        proxySettings.autoProxyConfigurationEnabled = true
        proxySettings.exceptionList = message.proxyExeptionList
        proxySettings.matchDomains = message.proxyMatchDomains
        networkSettings.proxySettings = proxySettings
        
        self.setTunnelNetworkSettings(networkSettings) {error in
            completion(error)
        }
    }
}
