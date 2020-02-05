//
//  HomeContentViewContoller.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/5.
//  Copyright © 2019 david. All rights reserved.
//

import UIKit
import NetworkExtension

class HomeContentViewContoller: UIViewController {
    var contentManger: HomeContentViewModel
    @IBOutlet weak var tableview: UITableView!
    
    init(contentManager model: HomeContentViewModel, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.contentManger = model
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableview.register(UINib.init(nibName: "HomeContentControlCell", bundle: nil), forCellReuseIdentifier: "ControlCell")
        self.tableview.register(UINib.init(nibName: "HomeContentProxyCell", bundle: nil), forCellReuseIdentifier: "ProxyCell")
        self.tableview.register(UINib.init(nibName: "HomeContentServerCell", bundle: nil), forCellReuseIdentifier: "ServerCell")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
}

extension HomeContentViewContoller: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "服务节点"
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        
        if section == 1 {
            return self.contentManger.serviceEndPoints.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 开关服务
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "ControlCell", for: indexPath) as! HomeContentControlCell
            cell.switchClosure =  { [weak self] switchOn in
                self?.contentManger.serviceOpen = switchOn
                if switchOn == false {
                    self?.contentManger.closeService()
                    return
                }
                
                self?.contentManger.openService(completion: { (error) in
                    cell.switchOn((error != nil) ? false : true)
                })
            }
            return cell
        }
        
        // 选择代理模式
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "ProxyCell", for: indexPath) as! HomeContentProxyCell
            cell.modeChangeClosure = { segmentIndex in
                
            }
            return cell
        }
        
        // 服务节点
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ServerCell", for: indexPath) as! HomeContentServerCell
            if indexPath.row == 0 {
                if self.contentManger.subscribeUrl == nil {
                    cell.showingText = ""
                    cell.mode = .editing
                    cell.isSelected = false
                    cell.editDoneClosure = { [weak self] urlStr in
                        let url = URL.init(string: urlStr)
                        self?.contentManger.requestServices(withUrl: url, completion: { (error) in
                            guard error == nil else {
                                self?.tableview.reloadData()
                                return
                            }
                            
                            self?.contentManger.subscribeUrl = url
                            self?.tableview.reloadData()
                        })
                    }
                    return cell
                }
                
                cell.mode = .editDone
                cell.showingText = self.contentManger.subscribeUrl?.host ?? ""
                cell.isSelected = false
                return cell
            }
            
            let model = self.contentManger.serviceEndPoints[indexPath.row - 1]
            cell.mode = .plain
            cell.showingText = model.info[VmessEndpoint.InfoKey.ps.stringValue] as! String
            cell.isSelected = self.contentManger.activingEndpoint == model ? true : false
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 && indexPath.row == 0 && self.contentManger.subscribeUrl != nil {
            self.contentManger.requestServices(withUrl: self.contentManger.subscribeUrl) { (error) in
                tableView.reloadData()
            }
        }
        
        if indexPath.section == 1 && indexPath.row != 0 {
            let model = self.contentManger.serviceEndPoints[indexPath.row - 1]
            self.contentManger.activingEndpoint = model
            self.contentManger.storeServices()
            tableView.reloadData()
        }
    }
}
