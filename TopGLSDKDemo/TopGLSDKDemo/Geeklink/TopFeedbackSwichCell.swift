//
//  TopFeedbackSwichCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/27.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopFeedbackSwichCellDelegate : class {
    
    func feedbackSwichCellClickBtn(_ item: TopItem)
 
}
class TopFeedbackSwichCell: UITableViewCell {
    
    var _isLast: Bool = false
    var isLast: Bool?{
        set{
            _isLast = (newValue as Bool?)!
            self.buttomSperator.isHidden = !_isLast
        }
        get{
           
            return _isLast
           
        }
    }
    weak var delegate : TopFeedbackSwichCellDelegate?
    
    @IBOutlet weak var topSperator: UIView!
    @IBOutlet weak var buttomSperator: UIView!

    @IBAction func turnOffBtnDidClicked(_ sender: Any) {
        self.turnOffBtn.isSelected = true
        self.turnOnBtn.isSelected = false
        self.item?.swichIsCol = true
        self.item?.swichIsOn = false
        delegate?.feedbackSwichCellClickBtn(item!)
        
    }
    @IBAction func turnOnBtnDidClicked(_ sender: Any) {
        self.turnOnBtn.isSelected = true
        self.turnOffBtn.isSelected = false
        self.item?.swichIsCol = true
        self.item?.swichIsOn = true
        delegate?.feedbackSwichCellClickBtn(item!)
    }
    
    
    @IBOutlet weak var turnOffBtn: UIButton!
    @IBOutlet weak var turnOnBtn: UIButton!
    
    var _item: TopItem?
    var item: TopItem?{
        get{
            //返回成员变量
            return _item;
        }
        set{
            _item = newValue as TopItem?
            if _item?.swichIsCol == false
            {
                _item?.swichIsOn = false
            }
            if item?.icon != nil  && item?.icon != ""{
                self.imageView?.image =  UIImage(named: (_item?.icon)!)!
            }
            self.textLabel?.text = _item?.text
            //使用 _成员变量 记录值
            if item?.swichOnState  == 1{
                self.turnOnBtn.isEnabled = false
                self.turnOnBtn.setTitle(NSLocalizedString("Trigger", tableName: "MacroPage"), for: .normal)
                self.turnOnBtn.setTitleColor(UIColor.gray, for: .normal)
                
            }else if item?.swichOnState  == 2{
                self.turnOnBtn.isEnabled = false
                self.turnOnBtn.setTitle(NSLocalizedString("Addition", tableName: "MacroPage"), for: .normal)
                self.turnOnBtn.setTitleColor(UIColor.gray, for: .normal)
                
            }
            else if item?.swichOnState  == 3{
                self.turnOnBtn.isEnabled = false
                self.turnOnBtn.setTitle(NSLocalizedString("Ban", tableName: "MacroPage"), for: .normal)
                self.turnOnBtn.setTitleColor(UIColor.gray, for: .normal)
                
            }else{
                self.turnOnBtn.setTitle(NSLocalizedString("On", tableName: "MacroPage"), for: .normal)
                self.turnOnBtn.isEnabled = true
                self.turnOnBtn.setTitleColor(UIColor.black, for: .normal)
            }
            if item?.swichOffState == 1 {
                self.turnOffBtn.isEnabled = false
                self.turnOffBtn.setTitle(NSLocalizedString("Trigger", tableName: "MacroPage"), for: .normal)
                self.turnOffBtn.setTitleColor(UIColor.gray, for: .normal)
            }else if item?.swichOffState == 2 {
                self.turnOffBtn.isEnabled = false
                self.turnOffBtn.setTitle(NSLocalizedString("Addition", tableName: "MacroPage"), for: .normal)
                self.turnOffBtn.setTitleColor(UIColor.gray, for: .normal)
            }else if item?.swichOffState == 3 {
                self.turnOffBtn.isEnabled = false
                self.turnOffBtn.setTitle(NSLocalizedString("Ban", tableName: "MacroPage"), for: .normal)
                self.turnOffBtn.setTitleColor(UIColor.gray, for: .normal)
            }
            else{
                self.turnOffBtn.setTitle(NSLocalizedString("Off", tableName: "MacroPage"), for: .normal)
                self.turnOffBtn.isEnabled = true
                self.turnOffBtn.setTitleColor(UIColor.black, for: .normal)
            }
            if (item?.swichIsCol)! {
                self.turnOffBtn.isSelected = !(item?.swichIsOn)!
                self.turnOnBtn.isSelected = (item?.swichIsOn)!
            }else{
                self.turnOffBtn.isSelected = false
                self.turnOnBtn.isSelected = false
            }
        }
    }
    var colCount = 4
    var colLines = Array<UIView>()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.turnOnBtn.setTitle(NSLocalizedString("On", tableName: "MacroPage"), for: .normal)
        self.turnOnBtn.setTitleColor(APP_ThemeColor, for: .selected)
        self.turnOnBtn.setTitleColor(UIColor.black, for: .normal)
        self.buttomSperator.isHidden = !self.isLast!
        self.turnOffBtn.setTitle(NSLocalizedString("Off", tableName: "MacroPage"), for: .normal)
        self.turnOffBtn.setTitleColor(APP_ThemeColor, for: .selected)
        self.turnOffBtn.setTitleColor(UIColor.black, for: .normal)
        
        self.textLabel?.font = UIFont.systemFont(ofSize: 15)
        self.textLabel?.textAlignment = .center
        for _ in 0...colCount {
            let view = UIView()
            view.backgroundColor = UIColor.lightGray
            colLines.append(view)
            self.contentView.addSubview(view)
        }
        textLabel?.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let viewW: CGFloat = 1.0
        let viewMaginX = (self.contentView.frame.size.width - viewW * CGFloat(colCount + 1)) / CGFloat(colCount)
        let viewH = self.contentView.frame.size.height
        var viewX: CGFloat = 0.0
        
        for view in colLines{
            view.frame = CGRect(x: viewX, y: 0, width: viewW, height: viewH)
            viewX += viewW + viewMaginX
        }
        
        let imageW = self.imageView?.image?.size.width
        let imageH = self.imageView?.image?.size.height
        let imageY: CGFloat = (self.contentView.frame.size.height - imageH!) * 0.5
        let imageX: CGFloat = (self.contentView.frame.size.width * 0.25 - imageW!) * 0.5
        self.imageView?.frame = CGRect(x: imageX, y: imageY, width: imageW!, height: imageH!)
       
        let labelW = self.contentView.frame.size.width * 0.25
        let labelH =  self.contentView.frame.size.height
        let labelY: CGFloat = 0.0
        let labelX: CGFloat = self.contentView.frame.size.width * 0.25
        self.textLabel?.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
        
        
    }
    
}
