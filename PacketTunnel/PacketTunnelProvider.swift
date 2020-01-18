//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by David.Dai on 2020/1/17.
//  Copyright © 2020 david. All rights reserved.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // 将App的数据转发到本地端口给V2Ray-Core进行转发
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "192.168.3.14")
        let ipv4Settings = NEIPv4Settings(addresses: ["10.10.10.10"], subnetMasks: ["255.255.255.0"])
        networkSettings.mtu = 1400
        networkSettings.ipv4Settings = ipv4Settings
        networkSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
        
        // 配置
        self.setTunnelNetworkSettings(networkSettings) { error in
            guard error == nil else {
                NSLog(error.debugDescription)
                completionHandler(error)
                return
            }
            completionHandler(nil)
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
