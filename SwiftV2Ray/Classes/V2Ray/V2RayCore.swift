//
//  V2RayCore..swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/11/27.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation
import Core

class V2RayCore {
    static let `shared` = V2RayCore()
    var serverPoint: VmessEndpoint? = nil
    private var core: CoreInstance? = nil
    
    func start(serverPoint: VmessEndpoint, completion: ((_ error: Error?) -> Void)?) {
        if core != nil {
            try? core?.close()
            core = nil
        }
        
        let config = V2RayConfig.parse(fromJsonFile: "config")!
        let configData = try? JSONEncoder().encode(config)
        var startError: Error? = nil
        do{
            let config = CoreConfig.init()
            try config.xxX_Marshal(configData, deterministic: true)// go里面protobuf编码
            core = CoreNew(config, nil)
            try core?.start()
            self.serverPoint = serverPoint
        } catch let error {
            startError = error
            self.serverPoint = nil
        }
        
        completion?(startError)
    }
    
    func close() {
        guard core != nil else {
            return
        }
        
        try? core?.close()
        self.serverPoint = nil
    }
}
