//
//  AirportTool.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/3.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation
import Alamofire

class AirportTool {
    // 从订阅地址获取Vmess节点信息
    static func getSubscribeVmessPoints(_ url: URLConvertible, _ completion: @escaping ((_ serverPoint: [VmessEndpoint]?, _ error: Error?) -> Void)) {
        Alamofire.request(url).responseString { (request) in
            request.result.ifSuccess {
                guard let responseData = request.result.value else {
                    completion(nil, NSError.init(domain: "AirportTool", code: -99, userInfo: ["error": "没有数据"]) as Error)
                    return
                }
             
                guard let base64Data = Data.init(base64Encoded: responseData)else {
                    completion(nil, NSError.init(domain: "AirportTool", code: -100, userInfo: ["error": "不是Base64数据"]) as Error)
                    return
                }
                
                let stringWithDecode = NSString(data:base64Data, encoding:String.Encoding.utf8.rawValue)
                let vmessUrlArray = stringWithDecode?.components(separatedBy: "\n")
                guard let array = vmessUrlArray else {
                    completion(nil, NSError.init(domain: "AirportTool", code: -101, userInfo: ["error": "没有获得服务器节点"]) as Error)
                    return
                }
                
                completion(VmessEndpoint.generatePoints(with: array), nil)
            }
            
            request.result.ifFailure {
                completion(nil, request.result.error)
            }
        }
    }
}
