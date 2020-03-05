//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by David.Dai on 2020/1/17.
//  Copyright © 2020 david. All rights reserved.
//

import NetworkExtension
import Tun2socks

class PacketTunnelProvider: NEPacketTunnelProvider {
    var message: PacketTunnelMessage? = nil
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // 启动Tun2scoks
        if let configData = message?.configData {
            Tun2socksStartV2Ray(self, configData)
        } else {
            completionHandler(NSError(domain: "PacketTunnel", code: -1, userInfo: ["error" : "读取不到配置"]))
            return
        }
        
        // 配置PacketTunel
        self.setupTunnel(message: message!) {[weak self] (error) in
            self?.proxyPackets()
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

extension PacketTunnelProvider: Tun2socksPacketFlowProtocol {
    func proxyPackets() {
        self.packetFlow.readPackets {[weak self] (packets: [Data], protocols: [NSNumber]) in
            for packet in  packets {
                autoreleasepool{
                    Tun2socksInputPacket(packet)
                }
            }
            
            self?.proxyPackets()
        }
    }
    
    func writePacket(_ packet: Data?) {
        self.packetFlow.writePackets([packet!], withProtocols: [AF_INET as NSNumber])
    }
}
