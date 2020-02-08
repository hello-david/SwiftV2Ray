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
    let serverIP = "xxxx"
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        var vconfig: V2RayConfig? = V2RayConfig.parse(fromJsonFile: "config")
        if var config = vconfig {
            do {
                var vnext = Outbound.VMess.Item()
                vnext.address = serverIP
                config.outbounds?[0].settingVMess?.vnext = [vnext]
                vconfig = config
                
                let configData = try JSONEncoder().encode(config)
                Tun2socksStartV2Ray(self, configData)
            } catch let error {
                completionHandler(error)
                return
            }
        } else {
            completionHandler(NSError(domain: "PacketTunnel", code: -1, userInfo: ["error" : "读取不到配置"]))
            return
        }
        
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverIP)
        networkSettings.mtu = 1400
        
        let ipv4Settings = NEIPv4Settings(addresses: [serverIP], subnetMasks: ["255.255.255.0"])
        networkSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings
        
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.8"])
        networkSettings.dnsSettings = dnsSettings
        
        let proxySettings = NEProxySettings()
        proxySettings.httpEnabled = true
        proxySettings.httpsEnabled = true
        proxySettings.autoProxyConfigurationEnabled = true
        networkSettings.proxySettings = proxySettings
        
        self.setTunnelNetworkSettings(networkSettings) {[weak self] error in
            guard error == nil else {
                NSLog(error.debugDescription)
                completionHandler(error)
                return
            }
            
            self?.proxyPackets()
            completionHandler(nil)
        }
    }
    
    func proxyPackets() {
        self.packetFlow.readPackets {[weak self] (packets: [Data], protocols: [NSNumber]) in
            for packet in  packets {
                Tun2socksInputPacket(packet)
            }
            self?.proxyPackets()
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
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

extension PacketTunnelProvider: Tun2socksPacketFlowProtocol {
    func writePacket(_ packet: Data!) {
        self.packetFlow.writePackets([packet], withProtocols: [AF_INET as NSNumber])
    }
}
