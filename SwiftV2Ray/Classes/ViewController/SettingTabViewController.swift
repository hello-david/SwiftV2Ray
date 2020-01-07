//
//  SettingViewController.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/14.
//  Copyright © 2019 david. All rights reserved.
//

import UIKit

class SettingTabViewController: UIViewController {
    @IBOutlet weak var contentTableView: UITableView!
    lazy var dataSource = {
        return []
    }()
    
    override func awakeFromNib() {
       super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
        } else {
            self.tabBarItem.image = UIImage.init(named: "gear_icon")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingTableView")
    }
}

extension SettingTabViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableView", for: indexPath)
        return cell
    }
}
