//
//  TopMacroCollectionViewCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/7.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopMacroCollectionViewCellDelegate: class {
    func macroCollectionViewCellDidClickedIcon(_ cell: TopMacroCollectionViewCell);
}
class TopMacroCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var macroNameLabel: UILabel!
    @IBOutlet weak var selectImgView: UIImageView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    var indexPath: IndexPath!
    weak var delegate: TopMacroCollectionViewCellDelegate?
    var _isEditing: Bool!
    var isEditing: Bool{
        set {
            _isEditing = newValue
            self.iconBtn.isUserInteractionEnabled = !_isEditing
        }
        get {
            return _isEditing
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        macroNameLabel.adjustsFontSizeToFitWidth = true
        self.iconTipLabel.text = NSLocalizedString("Execute", tableName: "MacroPage")
        self.iconTipLabel.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func iconDidClicked(_ sender: UIButton) {
        self.delegate?.macroCollectionViewCellDidClickedIcon(self)
    }
    @IBOutlet weak var iconTipLabel: UILabel!
    var _macro: TopMacro?
    var macro: TopMacro?{
        get{
            //返回成员变量
            return _macro;
        }
        set{
            //使用 _成员变量 记录值
            _macro = newValue;
            macroNameLabel?.text = _macro?.name
            stateLabel.text =  _macro?.state
            selectImgView.image = (_macro?.isSelected)! ? UIImage.init(named: "sence_yuanquan_sel") : UIImage.init(named: "sence_yuanquan_normal")
           
          //  stateLabel.text = _macro?.state
        
            iconBtn.setImage(UIImage(named:GlobarMethod.getMacroIconName((macro?.icon)!)), for: .normal)
            
          
        }
    }

    
    
}
