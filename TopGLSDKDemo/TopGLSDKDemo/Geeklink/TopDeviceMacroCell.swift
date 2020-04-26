//
//  TopDeviceMacroCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/12.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopDeviceMacroCell: UITableViewCell {
    var _device: TopDeviceAckInfo?
    var device: TopDeviceAckInfo?{
        set{
            _device = newValue
           // NSAttributedString * str = 
        }
        get{
           return _device
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
