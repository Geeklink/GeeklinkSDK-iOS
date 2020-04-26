//
//  TopConditionTitleCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/19.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopConditionTitleCellDelegate : class {
    
    
    func conditionTitleCellDelegateDidClickedAccessoryView(_ item: TopItem,cell: TopConditionTitleCell)
    
}
class TopConditionTitleCell: UITableViewCell {
    weak var delegate : TopConditionTitleCellDelegate?
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBAction func rightBtnDidClicked(_ sender: Any) {
        
        
        delegate?.conditionTitleCellDelegateDidClickedAccessoryView(item!, cell: self)
        
    }
    @IBOutlet weak var seperator: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        detailTextLabel?.font = UIFont.systemFont(ofSize: 11)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
       
    }
    var _item: TopItem?
    var item: TopItem?{
        get{
            //返回成员变量
            return _item;
        }
        set{
            //使用 _成员变量 记录值
            _item = newValue;
            switch _item?.accessoryType {
            case .none?:
                self.accessoryType = .none
                self.rightBtn.isHidden = true
            case .disclosureIndicator?:
                self.accessoryType = .disclosureIndicator
                 self.rightBtn.isHidden = true
            case .detailDisclosureButton?:
                self.accessoryType = .detailDisclosureButton
                self.rightBtn.isHidden = true
            case .checkmark?:
                self.accessoryType = .checkmark
                 self.rightBtn.isHidden = true
                
            case .edit?:
                self.rightBtn.isHidden = false
                self.rightBtn.setTitle(NSLocalizedString("Edit", comment: ""), for:.normal)
                self.rightBtn.setImage(UIImage(), for: .normal)
                self.rightBtn.setTitleColor(APP_ThemeColor, for: .normal)
               
                
            case .add?:
              self.rightBtn.isHidden = false
              self.rightBtn.setTitle(NSLocalizedString("", comment: ""), for:.normal)
              self.rightBtn.setImage(UIImage(named: "more_icon_add"), for: .normal)
              self.rightBtn.tintColor = APP_ThemeColor
          
            default:
                break
                
            }
            
            
            
            
            if item?.icon != nil  && item?.icon != ""{
                self.imageView?.image =  UIImage(named: (_item?.icon)!)!
            }
            let attStr = NSMutableAttributedString(string: (_item?.text)!)
            attStr.addAttributes([NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (_item?.text.utf16.count)!))
            self.textLabel?.attributedText = attStr
            self.subTitleLabel?.text = item?.detailedText
            contentView.backgroundColor = UIColor.white
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel?.frame = CGRect(x: 16, y: 0 , width: self.frame.size.width, height:44)
       
    }
    
}
