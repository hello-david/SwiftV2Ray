//
//  VPNHelper.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/27.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation
import NetworkExtension

class VPNHelper {
    static let `shared` = VPNHelper()
    var manager: NETunnelProviderManager? = nil
    
    func open(fromIP: String, completion: @escaping(( _ error: Error?) -> Void)) {
        guard manager == nil else {
            manager?.protocolConfiguration?.serverAddress = fromIP
            manager?.isEnabled = true
            manager?.saveToPreferences(completionHandler: { (error) in
                completion(error)
            })
            return
        }
        
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            guard error != nil else {
                return
            }
            
            
        }
    }
}
