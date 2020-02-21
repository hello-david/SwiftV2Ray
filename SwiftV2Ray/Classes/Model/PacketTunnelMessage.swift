//
//  PacketTunnelMessage.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2020/2/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import NetworkExtension

struct PacketTunnelMessage: Codable {
    var configData: Data? = nil
    
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
