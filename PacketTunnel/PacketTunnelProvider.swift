//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by David.Dai on 2020/1/17.
//  Copyright © 2020 david. All rights reserved.
//

import NetworkExtension
import Core

class PacketTunnelProvider: NEPacketTunnelProvider {
    let serverIp = "127.0.0.1"
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverIp)
        networkSettings.mtu = 1480
        let ipv4Settings = NEIPv4Settings(addresses: [serverIp], subnetMasks: ["255.255.255.0"])
        networkSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings
        
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
    
    func proxyPackets(_ completion: (() -> Void)?) {
        self.packetFlow.readPacketObjects { (inPackets) in
            self.packetFlow.writePacketObjects(inPackets)
            completion?()
        }
    }
    
    func proxyPackets() {
        self.packetFlow.readPackets {[weak self] (packets: [Data], protocols: [NSNumber]) in
            for packet in packets {
                
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
