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
    private var core: CoreInstance? = nil
    
    func start(with configData: Data) {
        if core != nil {
            try? core?.close()
            core = nil
        }
    
        do{
            let config = CoreConfig.init()
            try config.xxX_Marshal(configData, deterministic: true) // protobuf marshal
            core = CoreNew(config, nil)
            try core?.start()
        } catch {
            print(error)
        }
    }
    
    func close() {
        guard core != nil else {
            return
        }
        
        try? core?.close()
    }
}
