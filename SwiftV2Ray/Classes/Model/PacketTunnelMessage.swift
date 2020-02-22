//
//  PacketTunnelMessage.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2020/2/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import NetworkExtension

struct PacketTunnelMessage {
    typealias ipv4Routes =  [(String, String)]
    
    var configData: Data? = nil
    var serverIP: String? = nil
    var ipv4IncludedRoutes: ipv4Routes = []
    var ipv4ExcludedRoutes: ipv4Routes = []
    var dnsServers: [String] = ["8.8.8.8", "8.8.4.4"]
    var proxyExeptionList: [String]? = nil // 不代理列表
    var proxyMatchDomains: [String]? = nil // 需代理域名
    
    static func messageTo(_ prividerSession: NETunnelProviderSession?,
                          _ message: PacketTunnelMessage,
                          _ completion: @escaping((_ error: Error?,_ response: PacketTunnelMessage?)->Void)) {
        guard let prividerSession = prividerSession else {
            completion(NSError(domain: "PacketTunnelMessage", code: -1, userInfo: ["error" : "没有session"]), nil)
            return
        }
        
        do {
            try prividerSession.sendProviderMessage(JSONEncoder().encode(message), responseHandler: { (response) in
                guard let response = response else {
                    completion(nil, nil)
                    return
                }
                
                try? completion(nil, JSONDecoder().decode(PacketTunnelMessage.self, from: response))
            })
        } catch let error {
            completion(error, nil)
        }
    }
    
    // 域名解析
    static func getIPAddress(domainName: String) -> String {
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

extension PacketTunnelMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case configData
        case serverIP
        case ipv4IncludedRoutes
        case ipv4ExcludedRoutes
        case dnsServers
        case proxyExeptionList
        case proxyMatchDomains
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(configData, forKey: .configData)
        try? container.encode(serverIP, forKey: .serverIP)
        try container.encode(dnsServers, forKey: .dnsServers)
        let ipv4IncludedRoutesData = try NSKeyedArchiver.archivedData(withRootObject: ipv4IncludedRoutes, requiringSecureCoding: true)
        try container.encode(ipv4IncludedRoutesData, forKey: .ipv4IncludedRoutes)
        let ipv4ExcludedRoutesData = try NSKeyedArchiver.archivedData(withRootObject: ipv4ExcludedRoutes, requiringSecureCoding: true)
        try container.encode(ipv4ExcludedRoutesData, forKey: .ipv4ExcludedRoutes)
        proxyExeptionList != nil ? try container.encode(proxyExeptionList, forKey: .proxyExeptionList) : nil
        proxyMatchDomains != nil ? try container.encode(proxyMatchDomains, forKey: .proxyMatchDomains) : nil
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        configData = try? values.decode(Data.self, forKey: .configData)
        serverIP = try? values.decode(String.self, forKey: .serverIP)
        dnsServers = try values.decode(Array.self, forKey: .dnsServers)
        let ipv4ExcludedRoutesData = try values.decode(Data.self, forKey: .ipv4ExcludedRoutes)
        ipv4ExcludedRoutes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(ipv4ExcludedRoutesData) as! PacketTunnelMessage.ipv4Routes
        let ipv4IncludedRoutesData = try values.decode(Data.self, forKey: .ipv4IncludedRoutes)
        ipv4IncludedRoutes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(ipv4IncludedRoutesData) as! PacketTunnelMessage.ipv4Routes
        proxyMatchDomains = values.contains(.proxyMatchDomains) ? try values.decode(Array.self, forKey: .proxyMatchDomains) : nil
        proxyExeptionList = values.contains(.proxyExeptionList) ? try values.decode(Array.self, forKey: .proxyExeptionList) : nil
    }
}
