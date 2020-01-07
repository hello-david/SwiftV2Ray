//
//  HomeTabViewController.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2019/12/14.
//  Copyright © 2019 david. All rights reserved.
//

import UIKit
import SwiftUI
import SnapKit

class HomeTabViewController: UIViewController {
    lazy var contentManager: AnyObject = {
        if #available(iOS 13.0, *) {
            return SUHomeContentViewModel()
        }
        else {
            return HomeContentViewModel()
        }
    }()
    
    lazy var contentVC: UIViewController = {
        if #available(iOS 13.0, *) {
            let view = HomeContentView().environmentObject(self.contentManager as! SUHomeContentViewModel)
            return UIHostingController(rootView: view)
        } else {
            return HomeContentViewContoller(contentManager: self.contentManager as! HomeContentViewModel,
                                            nibName: "HomeContentViewController",
                                            bundle: Bundle.main)
        }
    }()
    
    override func awakeFromNib() {
       super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
        } else {
            self.tabBarItem.image = UIImage.init(named: "house_icon")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChild(contentVC)
        view.addSubview(contentVC.view)
        contentVC.view.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        contentVC.didMove(toParent: self)
    }
}
