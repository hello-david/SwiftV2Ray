//
//  HomeContentViewContoller.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/5.
//  Copyright © 2019 david. All rights reserved.
//

import UIKit

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
        self.tableview.register(UINib.init(nibName: "HomeContentCell0", bundle: nil), forCellReuseIdentifier: "ControlCell")
        self.tableview.register(UINib.init(nibName: "HomeContentCell1", bundle: nil), forCellReuseIdentifier: "ProxyCell")
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
            return self.contentManger.serviceEndPoints.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            return tableview.dequeueReusableCell(withIdentifier: "ControlCell", for: indexPath)
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            return tableview.dequeueReusableCell(withIdentifier: "ProxyCell", for: indexPath)
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)

    }
}
