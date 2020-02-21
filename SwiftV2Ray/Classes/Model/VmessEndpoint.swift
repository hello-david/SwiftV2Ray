//
//  VmessEndpoint.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/3.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation

struct VmessEndpoint: Codable, Hashable {
    var url: String? = nil
    var path: String? = nil
    var info: Dictionary<String, Any> = [:]
    
    enum InfoKey: String, CodingKey {
        case address = "add"
        case port
        case type
        case host
        case aid
        case uuid = "id"
        case tls
        case net
        case ps
    }
    
    enum CodingKeys: String, CodingKey {
        case url
        case path
        case info
    }
    
    static func generatePoints(with vmessUrls:[String]) -> [VmessEndpoint] {
        var array: [VmessEndpoint] = Array()
        for url in vmessUrls {
            if url.count > 0 && url.hasPrefix("vmess://") {
                array.append(VmessEndpoint.init(url))
            }
        }
        return array
    }
    
    // MARK: -
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        url != nil ? try container.encode(url, forKey: .url) : nil
        path != nil ? try container.encode(path, forKey: .path) : nil
        
        if !info.isEmpty, let jsonData = try? JSONSerialization.data(withJSONObject: info) {
            try container.encode(jsonData, forKey: .info)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = (values.contains(.url) == true) ? try values.decode(String.self, forKey: .url) : nil
        path = (values.contains(.path) == true) ? try values.decode(String.self, forKey: .path) : nil
        
        if values.contains(.info), let jsonData = try? values.decode(Data.self, forKey: .info) {
            info = (try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]) ?? [String: Any]()
        } else {
            info = [String: Any]()
        }
    }
    
    init(_ url: String?) {
        self.url = url?.replacingOccurrences(of: "\r", with: "")
        self.path = self.url?.replacingOccurrences(of: "vmess://", with: "")
        
        guard let path = self.path else {
            return
        }
        
        guard let base64Data = Data.init(base64Encoded: path) else {
            return
        }
        
        guard let dic = try? JSONSerialization.jsonObject(with: base64Data, options: [.allowFragments, .fragmentsAllowed, .mutableContainers, .mutableLeaves]) else {
            return
        }
        
        self.info = dic as! Dictionary<String, Any>
    }
    
    // MARK: -
    static func == (lhs: VmessEndpoint, rhs: VmessEndpoint) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}
