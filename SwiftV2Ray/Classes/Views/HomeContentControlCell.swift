//
//  HomeContentCell0.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2020/1/10.
//  Copyright © 2020 david. All rights reserved.
//

import UIKit

class HomeContentControlCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    var switchClosure: ((_ switchOn: Bool) -> Void)? = nil
    
    @IBAction func switchChange(_ sender: UISwitch) {
        label.text = sender.isOn ? "已连接" : "未连接"
        switchClosure?(sender.isOn)
    }
}
