//
//  V2RayConfig.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/11/30.
//  Copyright © 2019 david. All rights reserved.
//

import Foundation

// doc: https://www.V2Ray.com/chapter_02/01_overview.html
struct V2RayConfig: Codable {
    var log: V2RayLog = V2RayLog()
    var api: V2RayApi?
    var dns: V2RayDns = V2RayDns()
    var stats: V2RayStats?
    var routing: V2RayRouting? = V2RayRouting()
    var policy: V2RayPolicy?
    var inbounds: [V2RayInbound]?
    var outbounds: [V2RayOutbound]?
    var transport: V2RayTransport?
}

// MARK: - Log
struct V2RayLog: Codable {
    var loglevel: logLevel = .info
    var error: String = ""
    var access: String = ""
    
    enum logLevel: String, Codable {
        case debug
        case info
        case warning
        case error
        case none
    }
}

// MARK: - API
struct V2RayApi: Codable {

}

// MARK: - DNS
struct V2RayDns: Codable {
    var servers: [String] = ["1.1.1.1", "8.8.8.8", "8.8.4.4", "119.29.29.29", "114.114.114.114", "223.5.5.5", "223.6.6.6"]
}

// MARK: - Stats
struct V2RayStats: Codable {

}

// MARK: - Routing
struct V2RayRouting: Codable {
    var strategy: String = "rules"
    var settings: V2RayRoutingSetting = V2RayRoutingSetting()
    
    struct V2RayRoutingSetting: Codable {
        enum domainStrategy: String, Codable {
            case AsIs
            case IPIfNonMatch
            case IPOnDemand
        }

        var domainStrategy: domainStrategy = .IPIfNonMatch
        var rules: [V2RayRoutingSettingRule] = [V2RayRoutingSettingRule()]
        
        struct V2RayRoutingSettingRule: Codable {
            var type: String? = "field"
            var domain: [String]? = ["geosite:cn", "geosite:speedtest"]
            var ip: [String]? = ["geoip:cn", "geoip:private"]
            var port: String?
            var network: String?
            var source: [String]?
            var user: [String]?
            var inboundTag: [String]?
            var `protocol`: [String]? // ["http", "tls", "bittorrent"]
            var outboundTag: String? = "direct"
        }
    }
}

// MARK: - Policy
struct V2RayPolicy: Codable {
    
}

// MARK: - Inbound
struct V2RayInbound: Codable {
    var port: String = "1080"
    var listen: String = "127.0.0.1"
    var `protocol`: V2RayProtocolInbound = .socks
    var tag: String? = nil
    var streamSettings: V2RayStreamSettings? = nil
    var sniffing: V2RayInboundSniffing? = nil
    var allocate: V2RayInboundAllocate? = nil

    var settingHttp: V2RayInboundHttp = V2RayInboundHttp()
    var settingSocks: V2RayInboundSocks = V2RayInboundSocks()
    var settingShadowsocks: V2RayInboundShadowsocks? = nil
    var settingVMess: V2RayInboundVMess? = nil

    enum CodingKeys: String, CodingKey {
        case port
        case listen
        case `protocol`
        case tag
        case streamSettings
        case sniffing
        case settings
    }
    
    enum V2RayProtocolInbound: String, Codable {
        case http
        case shadowsocks
        case socks
        case vmess
    }
    
    struct V2RayInboundAllocate: Codable {
        var strategy: strategy = .always    // always or random
        var refresh: Int = 2                // val is 2-5 where strategy = random
        var concurrency: Int = 3            // suggest 3, min 1
        
        enum strategy: String, Codable {
            case always
            case random
        }
    }

    struct V2RayInboundSniffing: Codable {
        var enabled: Bool = false
        var destOverride: [dest] = [.tls, .http]
        
        enum dest: String, Codable {
            case tls
            case http
        }
    }

    struct V2RayInboundHttp: Codable {
        var timeout: Int = 360
        var allowTransparent: Bool?
        var userLevel: Int?
        var accounts: [V2RayInboundHttpAccount]?
        
        struct V2RayInboundHttpAccount: Codable {
            var user: String?
            var pass: String?
        }
    }

    struct V2RayInboundShadowsocks: Codable {
        var email, method, password: String?
        var udp: Bool = false
        var level: Int = 0
        var ota: Bool = true
        var network: String = "tcp" // "tcp" | "udp" | "tcp,udp"
    }

    struct V2RayInboundSocks: Codable {
        var auth: String = "noauth" // noauth | password
        var accounts: [V2RayInboundSockAccount]?
        var udp: Bool = true
        var ip: String?
        var timeout: Int = 360
        var userLevel: Int?
        
        struct V2RayInboundSockAccount: Codable {
            var user: String?
            var pass: String?
        }
    }

    struct V2RayInboundVMess: Codable {
        var clients: [V2RayInboundVMessClient]?
        var `default`: V2RayInboundVMessDefault? = V2RayInboundVMessDefault()
        var detour: V2RayInboundVMessDetour?
        var disableInsecureEncryption: Bool = false
        
        struct V2RayInboundVMessClient: Codable {
            var id: String?
            var level: Int = 0
            var alterId: Int = 64
            var email: String?
        }

        struct V2RayInboundVMessDetour: Codable {
            var to: String?
        }

        struct V2RayInboundVMessDefault: Codable {
            var level: Int = 0
            var alterId: Int = 64
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        port = try container.decode(String.self, forKey: .port)
        listen = try container.decode(String.self, forKey: .listen)
        `protocol` = try container.decode(V2RayProtocolInbound.self, forKey: .`protocol`)
        
        tag = container.contains(.tag) ? try container.decode(String.self, forKey: .tag) : nil
        streamSettings = container.contains(.streamSettings) ? try container.decode(V2RayStreamSettings.self, forKey: CodingKeys.streamSettings) : nil
        sniffing = container.contains(.sniffing) ? try container.decode(V2RayInboundSniffing.self, forKey: CodingKeys.sniffing) : nil

        switch `protocol` {
        case .http:
            settingHttp = try container.decode(V2RayInboundHttp.self, forKey: CodingKeys.settings)
        case .shadowsocks:
            settingShadowsocks = try container.decode(V2RayInboundShadowsocks.self, forKey: CodingKeys.settings)
        case .socks:
            settingSocks = try container.decode(V2RayInboundSocks.self, forKey: CodingKeys.settings)
        case .vmess:
            settingVMess = try container.decode(V2RayInboundVMess.self, forKey: CodingKeys.settings)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(port, forKey: .port)
        try container.encode(listen, forKey: .listen)
        try container.encode(`protocol`, forKey: .`protocol`)

        tag == nil ? nil : try container.encode(tag, forKey: .tag)
        streamSettings == nil ? nil : try container.encode(streamSettings, forKey: .streamSettings)
        sniffing == nil ? nil : try container.encode(sniffing, forKey: .sniffing)

        switch `protocol` {
        case .http:
            try container.encode(self.settingHttp, forKey: .settings)
        case .shadowsocks:
            try container.encode(self.settingShadowsocks, forKey: .settings)
        case .socks:
            try container.encode(self.settingSocks, forKey: .settings)
        case .vmess:
            try container.encode(self.settingVMess, forKey: .settings)
        }
    }
}

// MARK: - Outbound
struct V2RayOutbound: Codable {
    var `protocol`: V2RayProtocolOutbound = .freedom
    var sendThrough: String? = nil
    var tag: String? = nil
    var streamSettings: V2RayStreamSettings? = nil
    var proxySettings: ProxySettings? = nil
    var mux: V2RayOutboundMux? = nil

    var settingBlackhole: V2RayOutboundBlackhole? = nil
    var settingFreedom: V2RayOutboundFreedom? = nil
    var settingShadowsocks: V2RayOutboundShadowsocks? = nil
    var settingSocks: V2RayOutboundSocks? = nil
    var settingVMess: V2RayOutboundVMess? = nil
    var settingDns: V2RayOutboundDns? = nil

    enum CodingKeys: String, CodingKey {
        case sendThrough
        case `protocol`
        case tag
        case streamSettings
        case proxySettings
        case mux
        case settings
    }
    
    struct ProxySettings: Codable {
        var Tag: String?
    }
    
    enum V2RayProtocolOutbound: String, Codable {
        case blackhole
        case freedom
        case shadowsocks
        case socks
        case vmess
        case dns
    }
    
    struct V2RayOutboundMux: Codable {
        var enabled: Bool = false
        var concurrency: Int = 8
    }

    struct V2RayOutboundBlackhole: Codable {
        var response: V2RayOutboundBlackholeResponse = V2RayOutboundBlackholeResponse()
        
        struct V2RayOutboundBlackholeResponse: Codable {
            var type: String? = "none" // none | http
        }
    }

    struct V2RayOutboundFreedom: Codable {
        var domainStrategy: String = "AsIs" // UseIP | AsIs
        var redirect: String?
        var userLevel: Int = 0
    }

    struct V2RayOutboundShadowsocks: Codable {
        var servers: [V2RayOutboundShadowsockServer] = [V2RayOutboundShadowsockServer()]
        
        struct V2RayOutboundShadowsockServer: Codable {
            var email: String = ""
            var address: String = ""
            var port: Int = 0
            var method: V2RayOutboundShadowsockMethod = .aes256cfb
            var password: String = ""
            var ota: Bool = false
            var level: Int = 0
        }

        enum V2RayOutboundShadowsockMethod: String, Codable {
            case aes256cfb = "aes-256-cfb"
            case aes128cfb = "aes-128-cfb"
            case chacha20 = "chacha20"
            case chacha20ietf = "chacha20-ietf"
            case aes256gcm = "aes-256-gcm"
            case aes128gcm = "aes-128-gcm"
            case chacha20poly1305 = "chacha20-poly1305"
            case chacha20ietfpoly1305 = "chacha20-ietf-poly1305"
        }
    }

    struct V2RayOutboundSocks: Codable {
        var address: String = ""
        var port: String = ""
        var users: [V2RayOutboundSockUser] = [V2RayOutboundSockUser()]
        
        struct V2RayOutboundSockUser: Codable {
            var user: String = ""
            var pass: String = ""
            var level: Int = 0
        }
    }

    struct V2RayOutboundVMess: Codable {
        var vnext: [V2RayOutboundVMessItem] = [V2RayOutboundVMessItem()]
        
        struct V2RayOutboundVMessItem: Codable {
            var address: String = ""
            var port: Int = 443
            var users: [V2RayOutboundVMessUser] = [V2RayOutboundVMessUser()]
            
            struct V2RayOutboundVMessUser: Codable {
                var id: String = ""
                var alterId: Int = 64 // 0-65535
                var level: Int = 0
                var security: V2RayOutboundVMessSecurity = .auto
                
                enum V2RayOutboundVMessSecurity: String, Codable {
                    case aes128gcm = "aes-128-gcm"
                    case chacha20poly1305 = "chacha20-poly1305"
                    case auto = "auto"
                    case none = "none"
                }
            }
        }
    }

    struct V2RayOutboundDns: Codable {
        var network: String = "" // "tcp" | "udp" | ""
        var address: String = ""
        var port: Int?
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        `protocol` = try container.decode(V2RayProtocolOutbound.self, forKey: CodingKeys.`protocol`)

        tag = container.contains(.tag) ? try container.decode(String.self, forKey: .tag) : nil
        sendThrough = container.contains(.sendThrough) ? try container.decode(String.self, forKey: CodingKeys.sendThrough) : nil
        proxySettings = container.contains(.proxySettings) ?  try container.decode(ProxySettings.self, forKey: CodingKeys.proxySettings) : nil
        streamSettings = container.contains(.streamSettings) ? try container.decode(V2RayStreamSettings.self, forKey: CodingKeys.streamSettings) : nil
        mux = container.contains(.mux) ? try container.decode(V2RayOutboundMux.self, forKey: CodingKeys.mux) : nil

        switch `protocol` {
        case .blackhole:
            settingBlackhole = try container.decode(V2RayOutboundBlackhole.self, forKey: CodingKeys.settings)
        case .freedom:
            settingFreedom = try container.decode(V2RayOutboundFreedom.self, forKey: CodingKeys.settings)
        case .shadowsocks:
            settingShadowsocks = try container.decode(V2RayOutboundShadowsocks.self, forKey: CodingKeys.settings)
        case .socks:
            settingSocks = try container.decode(V2RayOutboundSocks.self, forKey: CodingKeys.settings)
        case .vmess:
            settingVMess = try container.decode(V2RayOutboundVMess.self, forKey: CodingKeys.settings)
        case .dns:
            settingDns = try container.decode(V2RayOutboundDns.self, forKey: CodingKeys.settings)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(`protocol`, forKey: .`protocol`)
        
        tag == nil ? nil : try container.encode(tag, forKey: .tag)
        streamSettings == nil ? nil : try container.encode(streamSettings, forKey: .streamSettings)
        (sendThrough == nil || sendThrough!.count <= 0) ? nil : try container.encode(sendThrough, forKey: .sendThrough)
        proxySettings == nil ? nil : try container.encode(proxySettings, forKey: .proxySettings)
        mux == nil ? nil : try container.encode(mux, forKey: .mux)

        switch `protocol` {
        case .shadowsocks:
            try container.encode(self.settingShadowsocks, forKey: .settings)
        case .socks:
            try container.encode(self.settingSocks, forKey: .settings)
        case .vmess:
            try container.encode(self.settingVMess, forKey: .settings)
        case .blackhole:
            try container.encode(self.settingBlackhole, forKey: .settings)
        case .freedom:
            try container.encode(self.settingFreedom, forKey: .settings)
        case .dns:
            try container.encode(self.settingDns, forKey: .settings)
        }
    }
}

// MARK: - Transport
struct V2RayTransport: Codable {
    var tlsSettings: V2RayStreamSettings.TlsSettings?
    var tcpSettings: V2RayStreamSettings.TcpSettings?
    var kcpSettings: V2RayStreamSettings.KcpSettings?
    var wsSettings: V2RayStreamSettings.WsSettings?
    var httpSettings: V2RayStreamSettings.HttpSettings?
    var dsSettings: V2RayStreamSettings.DsSettings?
    var quicSettings: V2RayStreamSettings.QuicSettings?
}

// MARK: - StreamSetting
struct V2RayStreamSettings: Codable {
    var network: network = .tcp
    var security: security = .none
    var sockopt: Sockopt?
    var tlsSettings: TlsSettings?
    var tcpSettings: TcpSettings?
    var kcpSettings: KcpSettings?
    var wsSettings: WsSettings?
    var httpSettings: HttpSettings?
    var dsSettings: DsSettings?
    var quicSettings: QuicSettings?
    
    enum network: String, Codable {
        case tcp
        case kcp
        case ws
        case http
        case h2
        case domainsocket
        case quic
    }

    enum security: String, Codable {
        case none
        case tls
    }
    
    struct TlsSettings: Codable {
        var serverName: String?
        var alpn: String?
        var allowInsecure: Bool?
        var allowInsecureCiphers: Bool?
        var certificates: TlsCertificates?
        
        struct TlsCertificates: Codable {
            enum usage: String, Codable {
                case encipherment
                case verify
                case issue
            }

            var usage: usage? = .encipherment
            var certificateFile: String?
            var keyFile: String?
            var certificate: String?
            var key: String?
        }
    }

    struct TcpSettings: Codable {
        var header: TcpSettingHeader = TcpSettingHeader()
        
        struct TcpSettingHeader: Codable {
            var type: String = "none"
            var request: TcpSettingHeaderRequest?
            var response: TcpSettingHeaderResponse?
            
            struct TcpSettingHeaderRequest: Codable {
                var version: String = ""
                var method: String = ""
                var path: [String] = []
                var headers: TcpSettingHeaderRequestHeaders = TcpSettingHeaderRequestHeaders()
                
                struct TcpSettingHeaderRequestHeaders: Codable {
                    var host: [String] = []
                    var userAgent: [String] = []
                    var acceptEncoding: [String] = []
                    var connection: [String] = []
                    var pragma: String = ""

                    enum CodingKeys: String, CodingKey {
                        case host = "Host"
                        case userAgent = "User-Agent"
                        case acceptEncoding = "Accept-Encoding"
                        case connection = "Connection"
                        case pragma = "Pragma"
                    }
                }
            }
            
            struct TcpSettingHeaderResponse: Codable {
                var version, status, reason: String?
                var headers: TcpSettingHeaderResponseHeaders?
                
                struct TcpSettingHeaderResponseHeaders: Codable {
                    var contentType, transferEncoding, connection: [String]?
                    var pragma: String?

                    enum CodingKeys: String, CodingKey {
                        case contentType = "Content-Type"
                        case transferEncoding = "Transfer-Encoding"
                        case connection = "Connection"
                        case pragma = "Pragma"
                    }
                }
            }
        }
    }

    struct KcpSettings: Codable {
        var mtu: Int = 1350
        var tti: Int = 20
        var uplinkCapacity: Int = 50
        var downlinkCapacity: Int = 20
        var congestion: Bool = false
        var readBufferSize: Int = 1
        var writeBufferSize: Int = 1
        var header: KcpSettingsHeader = KcpSettingsHeader()
        
        struct KcpSettingsHeader: Codable {
            var type: KcpSettingsHeaderType = .none
            
            enum KcpSettingsHeaderType: String, Codable {
                case none = "none"
                case srtp = "srtp"
                case utp = "utp"
                case wechatVideo = "wechat-video"
                case dtls = "dtls"
                case wireguard = "wireguard"
            }
        }
    }

    struct WsSettings: Codable {
        var path: String = ""
        var headers: WsSettingsHeader = WsSettingsHeader()
        
        struct WsSettingsHeader: Codable {
            var host: String = ""
        }
    }

    struct HttpSettings: Codable {
        var host: [String] = [""]
        var path: String = ""
    }

    struct DsSettings: Codable {
        var path: String = ""
    }

    struct Sockopt: Codable {
        var mark: Int = 0
        var tcpFastOpen: Bool = false
        var tproxy: tproxy = .off // only for linux
        
        enum tproxy: String, Codable {
            case redirect
            case tproxy
            case off
        }
    }

    struct QuicSettings: Codable {
        var security: QuicSettingsSecurity = .none
        var key: String = ""
        var header: QuicSettingHeader = QuicSettingHeader()
        
        struct QuicSettingHeader: Codable {
            var type: QuicSettingsHeaderType = .none
            
            enum QuicSettingsHeaderType: String, Codable {
                case none = "none"
                case srtp = "srtp"
                case utp = "utp"
                case wechatVideo = "wechat-video"
                case dtls = "dtls"
                case wireguard = "wireguard"
            }
        }
        
        enum QuicSettingsSecurity: String, Codable {
            case none = "none"
            case aes128gcm = "aes-128-gcm"
            case chacha20poly1305 = "chacha20-poly1305"
        }
    }
}

