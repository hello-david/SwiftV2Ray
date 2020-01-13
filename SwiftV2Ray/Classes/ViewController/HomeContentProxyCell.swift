//
//  HomeContentCell1.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2020/1/10.
//  Copyright © 2020 david. All rights reserved.
//

import UIKit

class HomeContentProxyCell: UITableViewCell {
    @IBOutlet weak var modeControl: UISegmentedControl!
    var modeChangeClosure: ((_ selectedSegmentIndex: Int) -> Void)? = nil
    
    @IBAction func modeControlChange(_ sender: UISegmentedControl) {
        modeChangeClosure?(sender.selectedSegmentIndex)
    }
}
