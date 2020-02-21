//
//  PacketTunelMessage.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2020/2/21.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import Foundation
import NetworkExtension

struct PacketTunelMessage: Codable {
    var configData: Data? = nil
    
    static func messageTo(_ prividerSession: NETunnelProviderSession?,
                          _ message: PacketTunelMessage,
                          _ completion: @escaping((_ error: Error?,_ response: PacketTunelMessage?)->Void)) {
        guard let prividerSession = prividerSession else {
            completion(NSError(domain: "PacketTunelMessage", code: -1, userInfo: ["error" : "没有session"]), nil)
            return
        }
        
        do {
            try prividerSession.sendProviderMessage(JSONEncoder().encode(message), responseHandler: { (response) in
                guard let response = response else {
                    completion(nil, nil)
                    return
                }
                
                try? completion(nil, JSONDecoder().decode(PacketTunelMessage.self, from: response))
            })
        } catch let error {
            completion(error, nil)
        }
    }
}
