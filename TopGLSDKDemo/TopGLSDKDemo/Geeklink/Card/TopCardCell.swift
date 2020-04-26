//
//  CardCell.swift
//  Banner
//
//  Created by 王彦森 on 2017/12/12.
//  Copyright © 2017年 Dwyson. All rights reserved.
//

import UIKit

class TopCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var label:UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.shadowOpacity = 0.08
        backView.layer.shadowColor = UIColor.black.cgColor
        backView.layer.shadowOffset = CGSize(width: 10, height: 10)
        backView.backgroundColor = UIColor.clear
        backView.layer.shadowRadius = 3
        
        
        imgView.layer.cornerRadius = 10
        imgView.layer.masksToBounds = true
        
    }
    
}
