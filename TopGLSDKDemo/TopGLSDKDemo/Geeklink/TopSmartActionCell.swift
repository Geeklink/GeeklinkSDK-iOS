//
//  TopSmartActionCell.swift
//  TopIntentExtentionUI
//
//  Created by YanFeiFei on 2019/1/28.
//  Copyright © 2019 Geeklink. All rights reserved.
//

import UIKit

protocol TopSmartActionCellDelegate : class {
    func smartActionCellDidClickedRightTopButton(_ cell: TopSmartActionCell)
    func smartActionClickedRightBottomButton(_ cell: TopSmartActionCell)
    func smartActionDidClickedDeleteButton(_ cell: TopSmartActionCell)
}

class TopSmartActionCell: UITableViewCell {
    
    @IBOutlet weak var rightTopView: UIView!
    @IBOutlet weak var bottomArrowIcon: UIImageView!
    @IBOutlet weak var topArrowIcon: UIImageView!
    
    @IBOutlet weak var rightTopLabel: UILabel!
    
    @IBOutlet weak var rightBottomLabel: UILabel!
    @IBOutlet weak var rightBottomView: UIView!
    @IBOutlet weak var rightBottomBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rightTopBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    weak var delegate : TopSmartActionCellDelegate?
    var isSetRounded: Bool = false
    var indexPath: IndexPath!
    weak var _smartPiTimerAction: TopSmartPiTimerAction!
    weak var smartPiTimerAction: TopSmartPiTimerAction!{
        get{
            //返回成员变量
            return _smartPiTimerAction;
        }
        set{
            //使用 _成员变量 记录值
            _smartPiTimerAction = newValue
            rightTopLabel.text = smartPiTimerAction.delayStr
            if _smartPiTimerAction.deviceAckInfo != nil {
              
                nameLabel.text = (smartPiTimerAction.deviceAckInfo?.deviceName)!+" ("+(smartPiTimerAction.deviceAckInfo?.place)!+")"
                rightBottomLabel.text = smartPiTimerAction.operation
                
                
            }else {
              
                nameLabel.text = NSLocalizedString("The device has been deleted.", comment: "")
                rightBottomLabel.text = NSLocalizedString("Unknow", comment: "")
            }
           
            //任务名称
           
            nameLabel.numberOfLines = 0
            //任务执行时间
          
             
            //任务操作名称
            
            deleteBtn.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
            deleteBtn.addTarget(self, action: #selector(deleteBtnDidClicked), for: .touchUpInside)
            topArrowIcon.image = UIImage(named: "sence_jiantou_icon")
            bottomArrowIcon.image = UIImage(named: "sence_jiantou_icon")
            let rightTopTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rightTopDidTapRecognizer))
            self.rightTopView.addGestureRecognizer(rightTopTapRecognizer)
            let rightbottomTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rightBottomDidTapRecognizer))
            self.rightBottomView.addGestureRecognizer(rightbottomTapRecognizer)
        }
    }
    @objc func rightTopDidTapRecognizer(_ rightTopTapRecognizer: UITapGestureRecognizer ) -> Void {
        rightTopBtnDidClicked(self.rightTopBtn as Any)
    }
    
    @objc func rightBottomDidTapRecognizer(_ rightTopTapRecognizer: UITapGestureRecognizer ) -> Void {
        rightBottomDidClicked(self.rightBottomBtn as Any)
    }
    
    func hideArrowView(_ hidden: Bool) -> Void {
        topArrowIcon.isHidden = hidden
        bottomArrowIcon.isHidden = hidden
    }
    func hiddenDeleteBtn(_ isHide: Bool) -> Void {
        deleteBtn.isHidden = isHide
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        
    }
    
    @objc func deleteBtnDidClicked() -> Void {
        delegate?.smartActionDidClickedDeleteButton(self)
    }
    
    @IBAction func rightTopBtnDidClicked(_ sender: Any) {
         delegate?.smartActionCellDidClickedRightTopButton(self)
    }
    
    @IBAction func rightBottomDidClicked(_ sender: Any) {
       delegate?.smartActionClickedRightBottomButton(self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
