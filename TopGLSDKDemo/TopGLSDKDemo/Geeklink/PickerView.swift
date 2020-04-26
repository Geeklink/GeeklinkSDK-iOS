//
//  THAgePickerView.swift
//  HealthCloud
//
//  Created by 李宝龙 on 16/9/6.
//  Copyright © 2016年 thealth. All rights reserved.
//

import UIKit

// 屏幕的宽
let SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.size.width
// 屏幕的高
let SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.size.height
let FONTSYS14 = UIFont.systemFont(ofSize: 14)       //H9：28px

enum PickerViewType: Int {
    case time
    case minute
    case only30Mini
}

class PickerView: UIView {
    /// 回调闭包
    weak var titleLabel: UILabel!
    fileprivate var btnCallBackBlock: ((_ time: Int32) -> ())?
    var time: Int32 = 0
    var type: PickerViewType = .time
    var second: Int?
    var min: Int?
    var hour: Int?
    /// 遮幕
    fileprivate lazy var coverView: UIView = {
        let coverview = UIView()
        coverview.backgroundColor = UIColor.darkGray
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(cancelBtnDidClick))
        coverview.addGestureRecognizer(tapGes)
        return coverview
    }()
    
    /// 主体view的高度
    fileprivate var contenViewHeight: CGFloat = 0
    
    /// 主体view
    fileprivate lazy var contenView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    weak var cancleBtn: UIButton!
    weak var confirmBtn: UIButton!

    
    fileprivate lazy var oneView: UIView = {
        let oneView = UIView()
        return oneView
    }()
    
    
    /// 时间pickerView
    fileprivate lazy var pickerView: UIPickerView = {
        let pickerview = UIPickerView()
        pickerview.delegate = self
        pickerview.dataSource = self
        return pickerview
    }()
    
    
   // 初始化
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - minDate: 最小时间
    ///   - maxDate: 最大时间
    ///   - showOnlyValidDates: 是否显示有效时间
    override func layoutSubviews() {
        super.layoutSubviews()
        contenViewHeight = self.width/3 + 40
        if contenViewHeight > 300 {
            contenViewHeight = 300
        }
        coverView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        contenView.frame = CGRect(x: 0, y: self.height, width: self.width, height: contenViewHeight)
        oneView.frame = CGRect(x: 0, y: 0, width: self.width, height: 40)
        
        
        let cancelBtnSize = TopDataManager.shared.textSize(text: (cancleBtn.title(for: .normal))!, font: (cancleBtn.titleLabel?.font)!, maxSize: CGSize.init(width: 300, height: oneView.frame.height))
        self.cancleBtn.frame = CGRect(x: 10, y: 0, width: cancelBtnSize.width, height: oneView.frame.height)
        self.titleLabel.frame = CGRect(x: (self.width - 180) * 0.5, y: 0, width: 180, height: oneView.frame.height)
            
        let confirmBtnSize = TopDataManager.shared.textSize(text: (confirmBtn.title(for: .normal))!, font: (confirmBtn.titleLabel?.font)!, maxSize: CGSize.init(width: 300, height: oneView.frame.height))
        self.confirmBtn.frame =   CGRect(x: self.width - confirmBtnSize.width - 10, y: 0, width: confirmBtnSize.width, height: oneView.frame.height)
        
        
        
        self.lineView.frame = CGRect(x: 0, y: self.oneView.frame.maxY, width: self.width, height: 1)
        
        pickerView.frame = CGRect(x: 0, y: lineView.frame.maxY, width: self.width, height: contenViewHeight - oneView.frame.size.height - 1)
        
        UIView.animate(withDuration: 0.35) {
            self.contenView.frame = CGRect(x: 0, y: self.height - self.contenViewHeight, width: self.width, height: self.contenViewHeight)
            self.coverView.alpha = 0.6
            
            
        }
    }
    init(frame: CGRect,
         time: Int32,
         showOnlyValidDates: Bool = true,
         type: PickerViewType)
    {
        super.init(frame: frame)
        
        
        //设置当前应该选中的时间
        initDate(time: time)
        self.type = type
        //添加遮罩
        coverView.alpha = 0.2
        
        addSubview(coverView)
        
        //设置主体view的frame
       
       
        //添加主体view
        addSubview(contenView)
        
        //添加上半部分的[取消、确定]按钮
       
        setOneView(oneView: oneView)
        contenView.addSubview(oneView)
        coverView.addSubview(lineView)
        //添加时间选择器
       
        contenView.addSubview(pickerView)
        
        //显示页面
        showDateOnPicker(time: self.time)
       
    }
    
    /// 显示pakerView
    func showInWindow(btnCallBackBlock: @escaping ((_ time: Int32) -> ())){
        let keyWindow = UIApplication.shared.keyWindow
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        self.frame = CGRect(x: 0, y: 0, width: (keyWindow?.width)!, height: (keyWindow?.height)!)
        self.btnCallBackBlock = btnCallBackBlock
    }
    
    /// 移除view
    func removePickerView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.contenView.frame = CGRect(x: 0, y: self.height, width: self.width, height: self.contenViewHeight)
            self.coverView.alpha = 0.2
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 初始化返回日期
extension PickerView
{
    /// 初始化时间
    fileprivate func initDate(time: Int32?) {
        
        if self.type == .time{
            self.time = time!
            second = Int(self.time%60)
            let totalMin: Int32 = self.time/60
            min = Int(totalMin%60)
            hour = Int(totalMin / 60)
        }else if self.type == .minute{
            self.time = time!
            second = 0
            min = Int(self.time) % 60
            hour =   (Int(self.time) / 60) % 24
        }else {
           
            min = Int(self.time) % 60
            if min! > 30 {
                min = 30
            }
        }
      
    }
}

// MARK: - 设置顶部view：[确定、取消]按钮
extension PickerView
{
    /// 设置pakerview第一栏样式
    ///
    /// - Parameter oneView: [确定、取消]按钮
    

   
    fileprivate func setOneView(oneView: UIView){
        oneView.backgroundColor = UIColor.white
        //取消按钮
        let cancleBtn = UIButton()
        self.cancleBtn = cancleBtn
        cancleBtn.setTitleColor(UIColor.gray, for: .normal)
        cancleBtn.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancleBtn.titleLabel?.font = FONTSYS14
        cancleBtn.addTarget(self, action: #selector(cancelBtnDidClick), for: .touchUpInside)
        oneView.addSubview(cancleBtn)
        
        //选择时间
        let titleLb = UILabel()
        titleLb.text = NSLocalizedString("Selection time", comment: "")
        self.titleLabel = titleLb
        titleLb.textAlignment = .center
        titleLabel = titleLb
        oneView.addSubview(titleLb)
        
        //确定按钮
        let yesBtn = UIButton()
        yesBtn.frame = CGRect(x: titleLb.frame.maxX, y: cancleBtn.frame.origin.y, width: cancleBtn.frame.size.width, height: cancleBtn.frame.size.height)
        yesBtn.setTitle(NSLocalizedString("Confirm", comment: ""), for: .normal)
        yesBtn.setTitleColor(UIColor.gray, for: .normal)
        self.confirmBtn = yesBtn
        yesBtn.titleLabel?.font = FONTSYS14
        yesBtn.addTarget(self, action: #selector(yesBtnDidClick), for: .touchUpInside)
        oneView.addSubview(yesBtn)
        
        //横线
        let lineView = UIView(frame: CGRect(x: 0, y: oneView.frame.size.height-0.5, width: oneView.frame.size.width, height: 0.5))
        lineView.backgroundColor = UIColor.gray
        lineView.alpha = 0.3
        oneView.addSubview(lineView)
    }
    
    //点击 [确认 | 取消] 按钮
    @objc func cancelBtnDidClick() -> Void {
         removePickerView()
    }
    
    @objc fileprivate func yesBtnDidClick() {
//        print("确定")
        //        let format = DateFormatter()
        //        format.dateFormat = "yyyy-MM-dd"
        //        // 获取系统当前时区
        //        let zone = NSTimeZone.system
        //        // 计算与GMT时区的差
        //        let interval = zone.secondsFromGMT(for: date! as Date)
        //        // 加上差的时时间戳
        //        let localeDate = date?.addingTimeInterval(Double(interval))
        // 回调闭包
        self.btnCallBackBlock?(time)
        // 移除view
        removePickerView()
    }
}

// MARK: - 根据日期滑动到对于的row
extension PickerView
{
    /// 根据日期滑动到对于的row
    ///
    /// - Parameter date: 滑动日期
    func showDateOnPicker(time: Int32) {
        if type == .time{
            second = Int(time%60)
            let totalMin: Int32 = time/60
            min = Int(totalMin%60)
            hour =   (Int(totalMin) / 60) % 24
            pickerView.selectRow(hour! + 2400, inComponent: 0, animated: true)
            pickerView.selectRow(min! + 6000, inComponent: 2, animated: true)
            pickerView.selectRow(second! + 6000, inComponent: 4, animated: true)
        }else if type == .minute{
            second = 0
            let totalMin: Int32 = time
            min = Int(totalMin) % 60
            hour =   (Int(totalMin) / 60) % 24
            pickerView.selectRow(min! + 6000, inComponent: 2, animated: true)
            pickerView.selectRow(hour! + 2400, inComponent: 0, animated: true)
        }else {
           
            let totalMin: Int32 = time
            min = Int(totalMin) % 60
            if (min)! > 31 {
                min = 31
            }
            
            pickerView.selectRow(min! + 3100, inComponent: 0, animated: true)
        }
       
    }
}

// MARK: - UIPickerView的代理
extension PickerView: UIPickerViewDelegate,UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if self.type == .time{
             return 6
        }else if type == .minute{
            return 4
        }else {
            return 2
        }
       
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.type == .time{
            switch component {
            case 0:
                return 24000
            case 1:
                return 1
            case 2:
                return 60000
            case 3:
                return 1
            case 4:
                return 60000
            case 5:
                return 1
                
            default:
                return 0
            }
           
        }else{
            switch component {
            case 0:
                return 60000
            case 1:
                return 1
            case 2:
                return 60000
            case 3:
                return 1
            default:
                return 0
            }
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
        
        // 字体大小
        dateLabel.font = UIFont.systemFont(ofSize: 13)
        dateLabel.textAlignment = .left
        if self.type == .time{
            if (component == 0){// 天数
                // 根据当前的行数转换为时间戳,记录当前行数所表示的日期
                dateLabel.font = UIFont.systemFont(ofSize: 15)
                dateLabel.textAlignment = .center
                dateLabel.text = String(format: "%d", row%24)
            }else if (component == 2)||(component == 4) {
                dateLabel.text = String(format: "%d", row%60)
                dateLabel.textAlignment = .center
            }
            else if(component == 1) {
                
                dateLabel.text = NSLocalizedString("H", comment: "")
            }
            else if(component == 3) {
                
                dateLabel.text = NSLocalizedString("Min", comment: "")
            }
            else if(component == 5) {
                
                dateLabel.text = NSLocalizedString("S", comment: "")
            }
            
        }else if self.type == .minute {
            if (component == 0){// 天数
                // 根据当前的行数转换为时间戳,记录当前行数所表示的日期
                dateLabel.font = UIFont.systemFont(ofSize: 15)
                dateLabel.textAlignment = .center
                dateLabel.text = String(format: "%d", row%24)
            }else if (component == 2){
                dateLabel.text = String(format: "%d", row%60)
                dateLabel.textAlignment = .center
            }
            else if(component == 1) {
                
                dateLabel.text = NSLocalizedString("H", comment: "")
            }
            else if(component == 3) {
                
                dateLabel.text = NSLocalizedString("Min", comment: "")
            }
        }else {
            if (component == 0){// 天数
                // 根据当前的行数转换为时间戳,记录当前行数所表示的日期
                dateLabel.font = UIFont.systemFont(ofSize: 15)
                dateLabel.textAlignment = .center
                dateLabel.text = String(format: "%d", row%31)
            }
            else if(component == 1) {
                
                dateLabel.text = NSLocalizedString("Min", comment: "")
            }
           
        }
        
        return dateLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.type == .time{
            switch component {
            case 0:
                hour = row % 24
            case 2:
                min = row % 60
            case 4:
                second = row % 60
            default:
                break
            }
            time = Int32(hour! * 3600 + min! * 60 + second!)
        }else if type == .minute{
            if component == 0{
                hour = (row % 24)
            }else if component == 2{
                min = (row % 60)
            }
            time = Int32(hour! * 60 + min!)
        }else {
            if component == 0{
                min = (row % 31)
            }
            time = Int32(min!)
        }
       
       
    }
    
}

