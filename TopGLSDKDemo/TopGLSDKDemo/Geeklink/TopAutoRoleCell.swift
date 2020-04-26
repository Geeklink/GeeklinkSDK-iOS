//
//  TopAutoRoleCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/29.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

protocol TopAutoRoleCellDelegate : class {
    
    
    func dutoRoleCellDidClickedDeleteBtn(_ cell: TopAutoRoleCell)
    
}

class TopAutoRoleCell: UITableViewCell {
    
    weak var deleteBtn: UIButton!
    
    @objc func deleteBtnDidClicked(_ sender: Any) {
        self.delegate?.dutoRoleCellDidClickedDeleteBtn(self)
    }
   
    var _autoRoleInfo: TopAutoRuleInfo?
    weak var delegate : TopAutoRoleCellDelegate?
    var autoRoleInfo: TopAutoRuleInfo?{
        set{
            _autoRoleInfo = newValue as TopAutoRuleInfo?
            self.imageView?.image = UIImage(named: (_autoRoleInfo?.selectIcon)!)
            self.textLabel?.text = _autoRoleInfo?.name
            self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            self.detailTextLabel?.text = (_autoRoleInfo?.timeMode.timerStr)!+"\n"+(_autoRoleInfo?.timeMode.weekDayStr)!
        }get{
            return _autoRoleInfo
        }
    }
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let deleteBtn: UIButton = UIButton()
        deleteBtn.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        self.deleteBtn = deleteBtn
        deleteBtn.setTitleColor(UIColor.darkGray, for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteBtnDidClicked), for: .touchUpInside)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        deleteBtn.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 16, right: 0)
        //deleteBtn.titleLabel?.textAlignment = .left
        self.addSubview(deleteBtn)
        
        self.detailTextLabel?.numberOfLines = 0
        self.textLabel?.numberOfLines = 0
        
        self.selectionStyle = .none
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var deleteBtnH: CGFloat  = 40
        let deleBtnSize = TopDataManager.shared.textSizeWithFont((self.deleteBtn?.title(for: .normal))!, font: (self.deleteBtn.titleLabel?.font)!, constrainedToSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        self.deleteBtn?.frame = CGRect(x: 0, y: 0, width: deleBtnSize.width + 32, height: 40)
        deleteBtnH = 20
        
        self.textLabel?.frame = CGRect(x: (self.textLabel?.frame.origin.x)!, y: deleteBtnH , width:  (self.textLabel?.frame.width)!, height:self.contentView.frame.size.height - deleteBtnH)

        let imageY: CGFloat = (self.contentView.frame.size.height - deleteBtnH - (self.imageView?.frame.size.height)!) * 0.5 + deleteBtnH
       self.imageView?.frame = CGRect(x: (self.imageView?.frame.origin.x)!, y: imageY , width:  (self.imageView?.frame.width)!, height: (self.imageView?.frame.height)!)
        
        self.detailTextLabel?.frame = CGRect(x: (self.detailTextLabel?.frame.origin.x)!, y: deleteBtnH , width:  (self.detailTextLabel?.frame.width)!, height:self.contentView.frame.size.height - deleteBtnH)
      
        
    }
    
}
