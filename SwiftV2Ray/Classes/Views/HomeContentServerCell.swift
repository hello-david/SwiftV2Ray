//
//  HomeContentServerCell.swift
//  SwiftV2Ray
//
//  Created by David.Dai on 2020/1/19.
//  Copyright © 2020 Apple Inc. All rights reserved.
//

import UIKit

class HomeContentServerCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var editTextFiled: UITextField!
    @IBOutlet weak var plainTextLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    var editDoneClosure: ((_ text: String) -> Void)? = nil
    
    enum ModeType: UInt {
        case editing
        case editDone
        case plain
    }
    private var _mode: ModeType = .plain
    var mode : ModeType {
        get {
            return _mode
        }
        set {
            _mode = newValue
            switch _mode {
            case .editDone:
                self.editTextFiled.isHidden = true
                self.plainTextLabel.isHidden = false
                self.moreButton.isHidden = false
                self.iconImageView.image = UIImage.init(named: "paperplane_icon")
                break
                
            case .editing:
                self.editTextFiled.isHidden = false
                self.plainTextLabel.isHidden = true
                self.moreButton.isHidden = true
                self.iconImageView.image = UIImage.init(named: "paperplane_icon")
                break
                
            case .plain:
                self.editTextFiled.isHidden = true
                self.plainTextLabel.isHidden = false
                self.moreButton.isHidden = false
                self.iconImageView.image = self.isSelected ? UIImage.init(named: "star_fill_icon") : UIImage.init(named: "star_icon")
                break
            }
        }
    }
    
    private var _showingText: String = ""
    var showingText: String {
        get {
            return _showingText
        }
        set {
            _showingText = newValue
            self.plainTextLabel.text = _showingText
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if _mode != .plain {
            super.setSelected(selected, animated: animated)
            return
        }
        
        self.iconImageView.image = self.isSelected ? UIImage.init(named: "star_fill_icon") : UIImage.init(named: "star_icon")
        super.setSelected(selected, animated: animated)
    }
}

extension HomeContentServerCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard self.editDoneClosure != nil && textField.text != nil else {
            return true
        }
        
        self.editDoneClosure!(textField.text!)
        return true
    }
}
