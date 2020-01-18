//
//  HomeContentViewModel.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/5.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation
import Alamofire
import Combine
import NetworkExtension

enum ProxyMode: Int {
    case auto = 0
    case global = 1
    case direct = 2
}

@available(iOS 13.0, *)
class SUHomeContentViewModel: ObservableObject, Codable {
    @Published var serviceOpen: Bool = false
    @Published var subscribeUrl: URL? = nil
    @Published var activingEndpoint: VmessEndpoint? = nil
    @Published var serviceEndPoints: [VmessEndpoint] = []
    @Published var proxyMode: ProxyMode = .auto
    
    enum CodingKeys: String, CodingKey {
        case subscribeUrl
        case activingEndpoint
        case serviceEndPoints
        case proxyMode
    }
    
    init() {
        loadServices()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        subscribeUrl != nil ? try container.encode(subscribeUrl?.absoluteString, forKey: .subscribeUrl) : nil
        activingEndpoint != nil ? try container.encode(activingEndpoint, forKey: .activingEndpoint) : nil
        try container.encode(proxyMode.rawValue, forKey: .proxyMode)
        try container.encode(serviceEndPoints, forKey: .serviceEndPoints)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let string = values.contains(.subscribeUrl) ? try values.decode(String.self, forKey: .subscribeUrl) : nil
        subscribeUrl = string != nil ? URL.init(string: string!) : nil
        activingEndpoint = values.contains(.activingEndpoint) ? try values.decode(VmessEndpoint.self, forKey: .activingEndpoint) : nil
        proxyMode = ProxyMode(rawValue: try values.decode(Int.self, forKey: .proxyMode)) ?? .auto
        serviceEndPoints = try values.decode([VmessEndpoint].self, forKey: .serviceEndPoints)
    }
    
    func requestServices(withUrl requestUrl: URL?, completion: ((_ error: Error?)-> Void)?) {
        guard let url = requestUrl else {
            return
        }
        
        AirportTool.getSubscribeVmessPoints(url) {[weak self] (serverPoints, error) in
            guard error == nil else {
                if completion != nil {
                    completion!(error)
                }
                return
            }
            
            self?.serviceEndPoints = serverPoints!
            if self?.activingEndpoint == nil {
                self?.activingEndpoint = self?.serviceEndPoints.first
            }
            
            if completion != nil {
                completion!(nil)
            }
        }
    }
    
    func storeServices() {
        guard let data = try? PropertyListEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "VmessService")
        UserDefaults.standard.synchronize()
    }
    
    func loadServices() {
        guard let data = UserDefaults.standard.data(forKey: "VmessService") else { return }
        let viewModel = try? PropertyListDecoder().decode(SUHomeContentViewModel.self, from: data)
        self.serviceEndPoints = viewModel?.serviceEndPoints ?? []
        self.activingEndpoint = viewModel?.activingEndpoint
        self.proxyMode = viewModel?.proxyMode ?? .auto
        self.subscribeUrl = viewModel?.subscribeUrl
    }
}

// MARK: - iOS13以下
class HomeContentViewModel: NSObject, Codable {
    var serviceOpen: Bool = false
    var subscribeUrl: URL? = nil
    var activingEndpoint: VmessEndpoint? = nil
    var serviceEndPoints: [VmessEndpoint] = []
    var proxyMode: ProxyMode = .auto
    
    enum CodingKeys: String, CodingKey {
        case subscribeUrl
        case activingEndpoint
        case serviceEndPoints
        case proxyMode
    }
    
    override init() {
        super.init()
        self.loadServices()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        subscribeUrl != nil ? try container.encode(subscribeUrl?.absoluteString, forKey: .subscribeUrl) : nil
        activingEndpoint != nil ? try container.encode(activingEndpoint, forKey: .activingEndpoint) : nil
        try container.encode(proxyMode.rawValue, forKey: .proxyMode)
        try container.encode(serviceEndPoints, forKey: .serviceEndPoints)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let string = values.contains(.subscribeUrl) ? try values.decode(String.self, forKey: .subscribeUrl) : nil
        subscribeUrl = string != nil ? URL.init(string: string!) : nil
        activingEndpoint = values.contains(.activingEndpoint) ? try values.decode(VmessEndpoint.self, forKey: .activingEndpoint) : nil
        proxyMode = ProxyMode(rawValue: try values.decode(Int.self, forKey: .proxyMode)) ?? .auto
        serviceEndPoints = try values.decode([VmessEndpoint].self, forKey: .serviceEndPoints)
    }
    
    func openService(completion: ((_ error: Error?)-> Void)?) {
        guard let serverPoint = self.activingEndpoint else {
            completion?(NSError(domain: "ErrorDomain", code: -1, userInfo: ["error" : "没有激活服务节点"]))
            return
        }
        
        V2RayCore.shared.start(serverPoint: serverPoint) { (error) in
            guard error != nil else {
                completion?(error)
                return
            }
            
            VPNHelper.shared.open { (manager, error) in
                guard error == nil else {
                    completion?(error)
                    return
                }
                
                if manager?.connection.status == .some(.connected) {
                    completion?(nil)
                    return
                }
                
                completion?(NSError(domain: "SwiftV2Ray", code: -1, userInfo: ["error" : "连接失败"]))
            }
        }
    }
    
    func closeService() {
        V2RayCore.shared.close()
        VPNHelper.shared.close()
    }
    
    func requestServices(withUrl requestUrl: URL?, completion: ((_ error: Error?)-> Void)?) {
        guard let url = requestUrl else {
            return
        }

        AirportTool.getSubscribeVmessPoints(url) {[weak self] (serverPoints, error) in
            guard error == nil else {
                if completion != nil {
                    completion!(error)
                }
                return
            }
            
            self?.serviceEndPoints = serverPoints!
            if self?.activingEndpoint == nil {
                self?.activingEndpoint = self?.serviceEndPoints.first
            }
            
            if completion != nil {
                completion!(nil)
            }
        }
    }
    
    func storeServices() {
        guard let data = try? PropertyListEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "VmessService")
        UserDefaults.standard.synchronize()
    }
    
    func loadServices() {
        guard let data = UserDefaults.standard.data(forKey: "VmessService") else { return }
        let viewModel = try? PropertyListDecoder().decode(HomeContentViewModel.self, from: data)
        self.serviceEndPoints = viewModel?.serviceEndPoints ?? []
        self.activingEndpoint = viewModel?.activingEndpoint
        self.proxyMode = viewModel?.proxyMode ?? .auto
        self.subscribeUrl = viewModel?.subscribeUrl
    }
}
