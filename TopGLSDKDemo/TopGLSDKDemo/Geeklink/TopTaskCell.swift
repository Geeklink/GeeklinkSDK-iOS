//
//  TopTaskCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/8.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

protocol TopTaskCellDelegate : class {
    func taskCellDidClickedRightTopButton(_ cell: TopTaskCell)
    func taskCellDidClickedRightBottomButton(_ cell: TopTaskCell)
    func taskCellDidClickedDeleteButton(_ cell: TopTaskCell)
}

class TopTaskCell: UITableViewCell {

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
    
    weak var delegate : TopTaskCellDelegate?
    var isSetRounded: Bool = false
    weak var _task: TopTask?
    weak var task: TopTask?{
        get{
            //返回成员变量
            return _task;
        }
        set{
            //使用 _成员变量 记录值
            _task = newValue
         
            //任务名称
            nameLabel.attributedText = _task?.taskAttButName
            nameLabel.numberOfLines = 0
            //任务执行时间
            let timeAttText: NSMutableAttributedString = NSMutableAttributedString(string: (_task?.timeStr)!)
            timeAttText.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13)], range: NSMakeRange(0, ( _task?.timeStr.utf16.count)!))
            rightTopLabel.attributedText = timeAttText
        
            //任务操作名称
            rightBottomLabel.attributedText = _task?.operationName

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
        delegate?.taskCellDidClickedDeleteButton(self)
    }
    
    @IBAction func rightTopBtnDidClicked(_ sender: Any) {
        delegate?.taskCellDidClickedRightTopButton(self)
    }
    
    @IBAction func rightBottomDidClicked(_ sender: Any) {
        delegate?.taskCellDidClickedRightBottomButton(self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
