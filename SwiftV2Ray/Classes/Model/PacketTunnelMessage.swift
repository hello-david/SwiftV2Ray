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
    var ipv4IncludedRoutes: ipv4Routes = []
    var ipv4ExcludedRoutes: ipv4Routes = []
    var dnsServers: [String] = ["8.8.8.8", "8.8.4.8"]
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
}

extension PacketTunnelMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case configData
        case ipv4IncludedRoutes
        case ipv4ExcludedRoutes
        case dnsServers
        case proxyExeptionList
        case proxyMatchDomains
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        configData != nil ? try container.encode(configData, forKey: .configData) : nil
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
        configData = try values.decode(Data.self, forKey: .configData)
        dnsServers = try values.decode(Array.self, forKey: .dnsServers)
        let ipv4ExcludedRoutesData = try values.decode(Data.self, forKey: .ipv4ExcludedRoutes)
        ipv4ExcludedRoutes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(ipv4ExcludedRoutesData) as! PacketTunnelMessage.ipv4Routes
        let ipv4IncludedRoutesData = try values.decode(Data.self, forKey: .ipv4IncludedRoutes)
        ipv4IncludedRoutes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(ipv4IncludedRoutesData) as! PacketTunnelMessage.ipv4Routes
        proxyMatchDomains = values.contains(.proxyMatchDomains) ? try values.decode(Array.self, forKey: .proxyMatchDomains) : nil
        proxyExeptionList = values.contains(.proxyExeptionList) ? try values.decode(Array.self, forKey: .proxyExeptionList) : nil
    }
}
