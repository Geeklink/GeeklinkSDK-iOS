//
//  TopTimingConditionCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/14.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopTimingConditionCellDelegate : class {
    
    func timingConditionCellDidClickedEditButton(condition: TopCondition)
}
class TopTimingConditionCell: UITableViewCell {
    weak var delegate : TopTimingConditionCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!

    @IBAction func eidtBtnDidClicked(_ sender: Any) {
        delegate?.timingConditionCellDidClickedEditButton(condition: condition!)
    }
    
    var _condition: TopCondition?
    var condition: TopCondition?{
        set{
            _condition = newValue as TopCondition?
            titleLabel?.attributedText = _condition?.attName
            let weekattText: NSMutableAttributedString = NSMutableAttributedString(string: (_condition?.timerModel.weekDayStr)!)
            weekattText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 11)], range: NSMakeRange(0, ( _condition?.timerModel.weekDayStr.utf16.count)!))
            weekLabel.attributedText = weekattText
            let timeAttText: NSMutableAttributedString = NSMutableAttributedString(string: (_condition?.timerModel.timerStr)!)
            timeAttText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 11)], range: NSMakeRange(0, ( _condition?.timerModel.timerStr.utf16.count)!))
            timeLabel.attributedText = timeAttText
           
            editBtn.isHidden = (_condition?.isHiddenEdit)!
          
        }
        get{
            return _condition
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        //self.titleLabel.text = NSLocalizedString("Timing", comment: "")
        self.editBtn.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
        self.editBtn.setTitleColor(APP_ThemeColor, for: .normal)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
