//
//  SUHomeContentView.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/14.
//  Copyright © 2019 david. All rights reserved.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
struct SUHomeContentView: View {
    @EnvironmentObject private var viewModel: SUHomeContentViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("控制")) {
                    HStack {
                        Toggle(self.viewModel.serviceOpen ? "已连接" : "未连接", isOn: self.$viewModel.serviceOpen)
                    }
                    HStack {
                        Picker(selection: self.$viewModel.proxyMode, label: Text("代理方式")) {
                            Text("自动配置").tag(ProxyMode.auto)
                            Text("全局代理").tag(ProxyMode.global)
                            Text("直连").tag(ProxyMode.direct)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(header: Text("服务节点")) {
                    SubscribeRow()
                    ForEach(self.viewModel.serviceEndPoints, id: \.self) { endpoint in
                        ServiceInfoRow(info: endpoint, isActive: endpoint == self.viewModel.activingEndpoint ? true : false)
                    }
                }
                .buttonStyle(DefaultButtonStyle())
            }
            .listStyle(GroupedListStyle())
            .padding(.top, 0)
            .background(Color.init(UIColor.systemGroupedBackground))
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK:-
@available(iOS 13.0, *)
struct SubscribeRow: View {
    @EnvironmentObject private var viewModel: SUHomeContentViewModel
    @State private var address: String = (SUHomeContentViewModel().subscribeUrl != nil) ? (SUHomeContentViewModel().subscribeUrl?.absoluteString)! : ""
    @State private var pushed = false
    
    var body: some View {
        Button(action: {
            self.viewModel.requestServices(withUrl: self.viewModel.subscribeUrl, completion: nil)
        }) {
            HStack {
                Image(systemName: "paperplane").renderingMode(.original)
                VStack {
                    if self.viewModel.subscribeUrl != nil {
                        HStack {
                            Text(self.viewModel.subscribeUrl!.host!).foregroundColor(Color.black)
                            NavigationLink(destination: SubscribeRowDetail(pushed: $pushed, address: $address),
                                           isActive: $pushed) {
                                EmptyView()
                            }
                            .frame(width: 0, height: 0)
                            Spacer()
                            Button(action: { self.pushed = true }) {
                                Image(systemName: "ellipsis").renderingMode(.original)
                            }
                        }
                    }
                    else {
                        TextField("请输入Vmess订阅地址", text: $address, onCommit: {
                            let url = URL.init(string: self.address)
                            self.viewModel.requestServices(withUrl: url, completion: { error in
                                guard error == nil else { return }
                                self.viewModel.subscribeUrl = url
                                self.viewModel.storeServices()
                            })
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
    @EnvironmentObject private var viewModel: SUHomeContentViewModel
    @Binding var pushed: Bool
    @Binding var address: String
    
    var body: some View {
        List {
            Section(header: Text("订阅服务地址")) {
                TextField("请输入Vmess订阅地址", text: $address, onCommit: {
                    let url = URL.init(string: self.address)
                    self.viewModel.requestServices(withUrl: url, completion: { error in
                        guard error == nil else { return }
                        self.viewModel.subscribeUrl = url
                        self.viewModel.storeServices()
                    })
                })
                    .tag("TextFiled")
                    .foregroundColor(Color.black)
                    .textFieldStyle(PlainTextFieldStyle())
                    .textContentType(UITextContentType.URL)
            }
            Section {
                Button(action: { self.viewModel.requestServices(withUrl: self.viewModel.subscribeUrl, completion: nil) }) {
                    HStack {
                        Spacer()
                        Text("更新订阅地址")
                        Spacer()
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .padding(.top, 44)
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarItems(leading: Button(action: { self.pushed = false }) {
            Image(systemName: "chevron.left")
        })
    }
}

// MARK:-
@available(iOS 13.0, *)
struct ServiceInfoRow: View {
    let info: VmessEndpoint
    let isActive: Bool
    
    @EnvironmentObject private var viewModel: SUHomeContentViewModel
    @State private var pushed = false
    
    var body: some View {
        Button(action: {
            self.viewModel.activingEndpoint = self.info
            self.viewModel.updateConfig()
            self.viewModel.storeServices()
        }) {
            VStack {
                HStack {
                    Image(systemName: isActive ? "star.fill" : "star").renderingMode(.original)
                    Text(info.info[VmessEndpoint.InfoKey.ps.stringValue] as! String)
                        .foregroundColor(Color.black)
                    Spacer()
                    Button(action: { self.pushed = true }) {
                        Image(systemName: "ellipsis").renderingMode(.original)
                        NavigationLink(destination: ServiceInfoRowDetail(info: info, pushed: $pushed), isActive: $pushed) {
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
    let info: VmessEndpoint
    @Binding var pushed: Bool
    
    var body: some View {
        List {
            Section(header: Text((info.info[VmessEndpoint.InfoKey.ps.stringValue] as! String) + "详情")) {
                Text("服务地址: " + (info.info[VmessEndpoint.InfoKey.address.stringValue] as! String))
                Text("端口: " + (info.info[VmessEndpoint.InfoKey.port.stringValue] as! String))
                Text("id: " + (info.info[VmessEndpoint.InfoKey.uuid.stringValue] as! String))
                Text("aid: " + (info.info[VmessEndpoint.InfoKey.aid.stringValue] as! String))
            }
        }
        .listStyle(GroupedListStyle())
        .padding(.top, 44)
        .edgesIgnoringSafeArea([.top, .bottom])
        .navigationBarItems(leading: Button(action: { self.pushed = false }) {
            Image(systemName: "chevron.left")
        })
    }
}

// MARK:-
@available(iOS 13.0, *)
struct SUHomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SUHomeContentView().environmentObject(SUHomeContentViewModel())
            SubscribeRowDetail(pushed: .constant(false), address: .constant("")).environmentObject(SUHomeContentViewModel())
            ServiceInfoRowDetail(info: VmessEndpoint(nil), pushed: .constant(false)).environmentObject(SUHomeContentViewModel())
        }
    }
}
