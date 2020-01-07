//
//  HomeContentView.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/14.
//  Copyright © 2019 david. All rights reserved.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
struct HomeContentView: View {
    var body: some View {
        NavigationView {
            HomeContentInternalView()
                .navigationBarTitle("")
                .navigationBarHidden(true)
        }
    }
}

@available(iOS 13.0, *)
struct HomeContentInternalView: View {
    @EnvironmentObject private var viewModel: SUHomeContentViewModel
    
    var body: some View {
        List {
            Section {
                HStack {
                    Toggle(viewModel.serviceOpen ? "已连接" : "未连接", isOn: $viewModel.serviceOpen)
                }
                HStack {
                    Picker(selection: $viewModel.proxyMode, label: Text("代理方式")) {
                        Text("自动配置").tag(ProxyMode.auto)
                        Text("全局代理").tag(ProxyMode.global)
                        Text("直连").tag(ProxyMode.direct)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            Section(header: Text("服务节点")) {
                SubscribeRow(subscribeText: viewModel.subscribeUrl?.host, actionSelectRow: {
                    self.viewModel.requestServices(withUrl: self.viewModel.subscribeUrl, completion: nil)
                }, onCommitAddress: {(addr) in
                    let url = URL.init(string: addr)
                    self.viewModel.requestServices(withUrl: url, completion: { error in
                        guard error == nil else { return }
                        self.viewModel.subscribeUrl = url
                        self.viewModel.storeServices()
                    })
                })
                
                ForEach(viewModel.serviceEndPoints, id: \.self) { endpoint in
                    ServiceInfoRow(info: endpoint, isActive: endpoint == self.viewModel.activingEndpoint ? true : false, actionSelectRow: {
                        self.viewModel.activingEndpoint = endpoint
                        self.viewModel.storeServices()
                    })
                }
            }
            .buttonStyle(DefaultButtonStyle())
        }
        .listStyle(GroupedListStyle())
        .padding(.top, 0)
        .background(Color.init(UIColor.systemGroupedBackground))
    }
}

// MARK:-
@available(iOS 13.0, *)
struct SubscribeRow: View {
    let subscribeText: String?
    var actionSelectRow: (() -> Void)? = nil
    var onCommitAddress: ((_ addr: String) -> Void)? = nil
    @State private var address: String = ""
    @State private var pushed = false
    
    var body: some View {
        Button(action: actionSelectRow != nil ? actionSelectRow! : {}) {
            HStack {
                Image(systemName: "paperplane").renderingMode(.original)
                VStack {
                    if subscribeText != nil {
                        HStack {
                            Text(subscribeText!).foregroundColor(Color.black)
                            NavigationLink(destination: SubscribeRowDetail(actionBack: { self.pushed = false }), isActive: $pushed) {
                                EmptyView()
                            }.frame(width: 0, height: 0)
                            Spacer()
                            Button(action: { self.pushed = true }) {
                                Image(systemName: "ellipsis").renderingMode(.original)
                            }
                        }
                    }
                    else {
                        TextField("请输入Vmess订阅地址", text: $address, onCommit: {
                            guard let onCommitAddress = self.onCommitAddress else {
                                return
                            }
                            onCommitAddress(self.address)
                        })
                            .tag("TextFiled")
                            .foregroundColor(Color.black)
                            .textFieldStyle(PlainTextFieldStyle())
                            .textContentType(UITextContentType.URL)
                    }
                }
            }
        }
    }
}

@available(iOS 13.0, *)
struct SubscribeRowDetail: View {
    let actionBack: () -> Void
    @EnvironmentObject private var viewModel: SUHomeContentViewModel
    
    var body: some View {
        List {
            Section {
                Text(viewModel.subscribeUrl?.absoluteString ?? "")
            }
            Section {
                Button(action: { self.viewModel.requestServices(withUrl: self.viewModel.subscribeUrl, completion: nil) }) {
                    HStack {
                        Spacer()
                        Text("更新节点")
                        Spacer()
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

// MARK:-
@available(iOS 13.0, *)
struct ServiceInfoRow: View {
    let info: VmessEndpoint
    let isActive: Bool
    let actionSelectRow: () -> Void
    @State private var pushed = false
    
    var body: some View {
        Button(action: actionSelectRow) {
            VStack {
                HStack {
                    Image(systemName: isActive ? "star.fill" : "star").renderingMode(.original)
                    Text(info.info[VmessEndpoint.InfoKey.ps.stringValue] as! String)
                        .foregroundColor(Color.black)
                    Spacer()
                    Button(action: { self.pushed = true }) {
                        Image(systemName: "ellipsis").renderingMode(.original)
                        NavigationLink(destination: ServiceInfoRowDetail(actionBack: { self.pushed = false }), isActive: $pushed) {
                            EmptyView()
                        }.frame(width: 0, height: 0)
                    }
                }
            }
        }
    }
}

@available(iOS 13.0, *)
struct ServiceInfoRowDetail: View {
    let actionBack: () -> Void
    
    var body: some View {
        HStack {
            Text("Service")
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: actionBack) {
            Image(systemName: "chevron.left")
        })
    }
}

// MARK:-
@available(iOS 13.0, *)
struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeContentView().environmentObject(SUHomeContentViewModel())
            SubscribeRowDetail(actionBack: {}).environmentObject(SUHomeContentViewModel())
            ServiceInfoRowDetail(actionBack: {}).environmentObject(SUHomeContentViewModel())
        }
    }
}
