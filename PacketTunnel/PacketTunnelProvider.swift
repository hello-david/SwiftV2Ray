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
    var message: PacketTunelMessage? = nil
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        self.setupTunnel(message: message!) {[weak self] (error) in
            self?.proxyPackets()
            completionHandler(error)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        message = try? JSONDecoder().decode(PacketTunelMessage.self, from: messageData)
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
    // 设置PacketTunnel
    func setupTunnel(message: PacketTunelMessage, _ completion: @escaping((_ error: Error?) -> Void)) {
        var config: V2RayConfig
        if let configData = message.configData {
            do {
                 config = try JSONDecoder().decode(V2RayConfig.self, from: configData)
                 Tun2socksStartV2Ray(self, configData)
             } catch let error {
                 completion(error)
                 return
             }
        } else {
            completion(NSError(domain: "PacketTunnel", code: -1, userInfo: ["error" : "读取不到配置"]))
            return
        }
        
        let serverIP = self.getIPAddress(domainName: (config.outbounds?[0].settingVMess?.vnext[0].address)!)
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
        
        self.setTunnelNetworkSettings(networkSettings) {error in
            completion(error)
        }
    }
    
    // 域名解析
    func getIPAddress(domainName: String) -> String {
        var result = ""
        let host = CFHostCreateWithName(nil,domainName as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses.firstObject as? NSData {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                let numAddress = String(cString: hostname)
                result = numAddress
                print(numAddress)
            }
        }
        return result
    }
}

extension PacketTunnelProvider: Tun2socksPacketFlowProtocol {
    func proxyPackets() {
        self.packetFlow.readPackets {[weak self] (packets: [Data], protocols: [NSNumber]) in
            for packet in  packets {
                Tun2socksInputPacket(packet)
            }
            self?.proxyPackets()
        }
    }
    
    func writePacket(_ packet: Data!) {
        self.packetFlow.writePackets([packet], withProtocols: [AF_INET as NSNumber])
    }
}
