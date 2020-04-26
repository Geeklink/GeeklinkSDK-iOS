//
//  TopConditionCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/14.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopConditionCellDelegate : class {
    
    func conditionCellDidClickedEditButton(_ cell: TopConditionCell)
}
class TopConditionCell: UITableViewCell {
    weak var delegate : TopConditionCellDelegate?
    @IBOutlet weak var editBtn: UIButton!
    @IBAction func editBtnDidClicked(_ sender: Any) {
        
        delegate?.conditionCellDidClickedEditButton(self)
    }
    var _condition: TopCondition?
    var condition: TopCondition?{
        set{
            _condition = newValue as TopCondition?
          
            self.textLabel?.attributedText = condition?.attName
         
           
            editBtn.isHidden = (_condition?.isHiddenEdit)!
            if  _condition?.conditionType == .location {
                let type: Int32 = Int32(SGlobalVars.conditionHandle.getLocationType(_condition?.value))
                if type != 2 {
                    return
                }
            }
            if  _condition?.conditionType == .securityMode {
                return
            }
            if _condition?.conditionType == .thirdParty || _condition?.device == nil || _condition?.device?.slaveType == .macroKey1 || _condition?.device?.slaveType == .shakeSensor{
                editBtn.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
            }
           
        }
        get{
            return _condition
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.editBtn.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
        self.editBtn.setTitleColor(APP_ThemeColor, for: .normal)
    
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
