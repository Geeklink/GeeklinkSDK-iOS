//
//  TopEffectiveTimePickerView.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/5/8.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopEffectiveTimePickerViewDelegate : class {
    
    func effectiveTimePickerViewSlected(_ beginTime: Int32, endTime: Int32)
    
    
}
class TopEffectiveTimePickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource{
    weak var coverView: UIView?
    weak var contentView: UIView?
    weak var delegate : TopEffectiveTimePickerViewDelegate?
    weak var topView: UIView?
    weak var cancelBtn: UIButton?
    weak var confirmBtn: UIButton?
    weak var seperatorView: UIView?
    weak var beginTimelabel: UILabel?
    weak var beginTimePicker: UIPickerView?
    weak var endTimelabel: UILabel?
    weak var endTimePicker: UIPickerView?
    
    var contentViewH: CGFloat = 405.0
  
    var _beginTime: Int32 = 0
    var beginTime: Int32!{
        set{
            _beginTime = newValue
            beginMin = _beginTime % 60
            beginHour = _beginTime / 60
            self.beginTimePicker?.selectRow(Int(beginMin + 2400), inComponent: 2, animated: true)
            self.beginTimePicker?.selectRow(Int(beginHour + 6000), inComponent: 0, animated: true)
        }get{
            
            _beginTime = beginMin  + beginHour * 60
            
            return _beginTime
            
        }
    }
    var beginHour: Int32 = 0
    var beginMin: Int32 = 0
 
    var _endTime: Int32 = 0
    var endTime: Int32!{
        set{
            _endTime = newValue
            endHour = _endTime / 60
            endMin =  _endTime % 60
            self.endTimePicker?.selectRow(Int(endMin), inComponent: 2, animated: true)
            self.endTimePicker?.selectRow(Int(endHour), inComponent: 0, animated: true)
        }get{
            
            _endTime =  endMin + endHour * 60
            return _endTime
        }
    }
    
    
    var endHour: Int32 = 0
    var endMin: Int32 = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSbuViews()
   
    }
    func initSbuViews() -> Void {
        
        let coverView = UIView()
        coverView.backgroundColor = UIColor.black
        self.coverView = coverView
        coverView.alpha = 0.2
        let tapg =  UITapGestureRecognizer(target: self, action: #selector(coverViewDidTaped))
        coverView.addGestureRecognizer(tapg)
        self.addSubview(coverView)
    
        let contentView = UIView()
        self.contentView = contentView
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
        self.addSubview(contentView)
      
        let topView = UIView()
        self.topView = topView
        self.contentView?.addSubview(topView)
        
        let seperatorView = UIView()
        self.seperatorView = seperatorView
        seperatorView.backgroundColor = UIColor.gray
        self.contentView?.addSubview(seperatorView)
        
        let cancelBtn: UIButton = UIButton()
        self.cancelBtn = cancelBtn
        cancelBtn.setTitle("  "+NSLocalizedString("Cancel", comment: "")+"  ", for: .normal)
        cancelBtn.setTitleColor(UIColor.black, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelBtn.addTarget(self, action: #selector(cancelBtnDidClicked), for: .touchUpInside)
        self.topView?.addSubview(cancelBtn)
        
        let confirmBtn: UIButton = UIButton()
        self.confirmBtn = confirmBtn
        confirmBtn.setTitle("  "+NSLocalizedString("Confirm", comment: "")+"  ", for: .normal)
        confirmBtn.setTitleColor(APP_ThemeColor, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        confirmBtn.addTarget(self, action: #selector(confirmBtnDidClicked), for: .touchUpInside)
        self.topView?.addSubview(confirmBtn)
        
       
        
        let beginTimelabel: UILabel = UILabel()
        self.beginTimelabel = beginTimelabel
        beginTimelabel.textColor = UIColor.gray
        beginTimelabel.text = NSLocalizedString("Begin time", comment: "")
        beginTimelabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView?.addSubview(beginTimelabel)
        
        let beginTimePicker: UIPickerView = UIPickerView()
        beginTimePicker.delegate = self
        self.beginTimePicker = beginTimePicker
        beginTimePicker.dataSource = self
        self.contentView?.addSubview(beginTimePicker)
        
        let endTimelabel: UILabel = UILabel()
        self.endTimelabel = endTimelabel
        endTimelabel.textColor = UIColor.gray
        endTimelabel.text = NSLocalizedString("End time", comment: "")
        endTimelabel.font = UIFont.systemFont(ofSize: 15)
        self.contentView?.addSubview(endTimelabel)
        
       
        
        let endTimePicker: UIPickerView = UIPickerView()
        endTimePicker.delegate = self
        self.endTimePicker = endTimePicker
        endTimePicker.dataSource = self
        self.contentView?.addSubview(endTimePicker)
        
       
        
        
        
    }
    @objc func coverViewDidTaped(_ tapGestureRecognizer: UITapGestureRecognizer) -> Void {
        self.cancelBtnDidClicked()
    }
    
    @objc func cancelBtnDidClicked() -> Void  {
        self.dismiss()
    }
    @objc func confirmBtnDidClicked() -> Void  {
        self.delegate?.effectiveTimePickerViewSlected(beginTime, endTime: endTime)
        self.dismiss()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
   
        return 4
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0:
            return 240000
        case 1:
            return 1
        case 2:
            return 600000
        case 3:
            return 1
      
    
        default:
            return 0
        }
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return self.width/8
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 45
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        // 定义一个label用于展示时间
        let dateLabel = UILabel()
        for singleLine in pickerView.subviews
        {
            if (singleLine.frame.size.height < 1)
            {
                singleLine.backgroundColor = UIColor.gray
            }
        }
            
        // 字体大小
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textAlignment = .left
        
        if (component == 0) {// 天数
            // 根据当前的行数转换为时间戳,记录当前行数所表示的日期
            dateLabel.font = UIFont.systemFont(ofSize: 15)
            dateLabel.textAlignment = .center
            dateLabel.text = String(format: "%d", row%24)
        }
        if (component == 2) {// 天数
            // 根据当前的行数转换为时间戳,记录当前行数所表示的日期
            dateLabel.font = UIFont.systemFont(ofSize: 15)
            dateLabel.textAlignment = .center
            dateLabel.text = String(format: "%d", row%60)
        }else if(component == 1) {
            
            dateLabel.text = NSLocalizedString("H", comment: "")
        }
        else if(component == 3) {
            
            dateLabel.text = NSLocalizedString("Min", comment: "")
        }
       
 
        return dateLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
     
       
        if pickerView == self.beginTimePicker{
            switch component {
            case 0:
                beginHour = Int32(row % 24)
            case 2:
                beginMin = Int32(row % 60)
            
            default:
                break
            }
            _beginTime = beginHour * 60 + beginMin
        } else{
            switch component {
            case 0:
                endHour = Int32(row % 24)
            case 2:
                endMin = Int32(row % 60)
                
            default:
                break
            }
            _endTime = endHour * 60 + endMin
        }
         
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverView?.frame = self.frame
        topView?.frame = CGRect(x: 0, y: 0, width: self.width, height: 44)
        let cancelBtnSize = TopDataManager.shared.textSizeWithFont((cancelBtn?.titleLabel?.text)!, font:(cancelBtn?.titleLabel?.font)! , constrainedToSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        cancelBtn?.frame = CGRect(x: 0, y: 0, width: cancelBtnSize.width, height: 44)
    
        let confirmBtnSize = TopDataManager.shared.textSizeWithFont((confirmBtn?.titleLabel?.text)!, font:(confirmBtn?.titleLabel?.font)! , constrainedToSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        confirmBtn?.frame = CGRect(x: self.width - confirmBtnSize.width, y: 0, width: confirmBtnSize.width, height: 44)
        
        seperatorView?.frame = CGRect(x: 0, y: (topView?.frame.maxY)!, width: self.width, height: 1)
        
        beginTimelabel?.frame =  CGRect(x: 20, y: (seperatorView?.frame.maxY)!, width: self.width - 40, height: 30)
        
        beginTimePicker?.frame = CGRect(x: 0, y: (beginTimelabel?.frame.maxY)!, width: self.width, height: 150)
        
        endTimelabel?.frame =  CGRect(x: 20, y: (beginTimePicker?.frame.maxY)!, width: self.width - 40, height: 30)
        
        endTimePicker?.frame = CGRect(x: 0, y: (endTimelabel?.frame.maxY)!, width: self.width, height: 150)
       // self.contentView?.frame = CGRect(x: 0, y: self.height , width: self.width, height: self.contentViewH)
    }
    
    func show() -> Void {
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow!.addSubview(self)
       // keyWindow!.bringSubview(toFront: self)
        
        print("self.width", self.width)
        print("self.height", self.height)
        
        self.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        self.contentView?.frame = CGRect(x: 0, y: self.height, width: self.width, height: self.contentViewH)
        UIView.animate(withDuration: 0.35) {
            self.contentView?.frame = CGRect(x: 0, y: self.height - self.contentViewH, width: self.width, height: self.contentViewH)
            self.coverView?.alpha = 0.6
        }
    }
    
    func dismiss() -> Void {
        UIView.animate(withDuration: 0.5, animations: {
            self.contentView?.frame = CGRect(x: 0, y: self.height, width: self.width, height: self.contentViewH)
            self.coverView?.alpha = 0.2
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
    
    
}
