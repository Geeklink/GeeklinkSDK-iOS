//
//  TopUsefulTimeConditionCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/14.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopUsefulTimeConditionCellDelegate : class {
    
    func usefulTimeConditionCellDidClickedEditButton(condition: TopCondition)
}
class TopUsefulTimeConditionCell: UITableViewCell {
    
    weak var delegate : TopUsefulTimeConditionCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBAction func editBtnDidClicked(_ sender: Any) {
        delegate?.usefulTimeConditionCellDidClickedEditButton(condition: condition!)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.titleLabel.text = NSLocalizedString("Valid Time", tableName: "MacroPage")
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        self.editBtn.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
        self.editBtn.setTitleColor(APP_ThemeColor, for: .normal)
    }
    
    var _condition: TopCondition?
    var condition: TopCondition?{
        set{
            _condition = newValue as TopCondition?
            titleLabel.attributedText = _condition?.attName
            weekLabel.attributedText = _condition?.usefulTime.weekDayAttStr
            beginTimeLabel.attributedText = _condition?.usefulTime.beginTimeMutAttStr
            endTimeLabel.attributedText = _condition?.usefulTime.endTimeMutAttStr
            editBtn.isHidden = (_condition?.isHiddenEdit)!
        }
        get{
            return _condition
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
