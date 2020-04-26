//
//  TopDeviceOrMacorCell.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/28.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit

class TopDeviceOrMacorCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect.init(x: 16, y: (self.height - 40) * 0.5, width: 40, height: 40)
        self.textLabel?.frame = CGRect.init(x: (self.imageView?.frame.maxX)! + 8, y: (self.textLabel?.frame.origin.y)!, width: (self.textLabel?.frame.size.width)!, height: (self.textLabel?.frame.size.height)!)
         self.detailTextLabel?.frame = CGRect.init(x: (self.imageView?.frame.maxX)! + 8, y: (self.detailTextLabel?.frame.origin.y)!, width: (self.detailTextLabel?.frame.size.width)!, height: (self.detailTextLabel?.frame.size.height)!)
    }
}
