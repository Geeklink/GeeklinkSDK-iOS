//
//  TopWeekPickerCell.swift
//  Geeklink
//
//  Created by YanFeiFei on 2019/1/21.
//  Copyright © 2019 Geeklink. All rights reserved.
//

import UIKit

protocol TopWeekPickerCellDelegate : class {
    func miniPiTimeWeekCellUpdateWeek(_ week: Int8)
}

class TopWeekPickerCell: UITableViewCell {
    
    @IBOutlet weak var monBtn: UIButton!
    @IBOutlet weak var tueBtn: UIButton!
    @IBOutlet weak var wedBtn: UIButton!
    
    @IBOutlet weak var thuBtn: UIButton!
    @IBOutlet weak var friBtn: UIButton!
    @IBOutlet weak var satBtn: UIButton!
    
    @IBOutlet weak var sunBtn: UIButton!
    @IBOutlet weak var onceBtn: UIButton!
    @IBOutlet weak var weekdayBtn: UIButton!
    
    @IBOutlet weak var weekendBtn: UIButton!
    @IBOutlet weak var everydayBtn: UIButton!
    
    var weekBtnList = Array<UIButton>.init()
    
    
    var typeBtnList = Array<UIButton>.init()
    
    
    weak var delegate: TopWeekPickerCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.monBtn.setTitle(NSLocalizedString("Button_Mon", tableName: "WiFiPlug"), for: .normal)
        self.tueBtn.setTitle(NSLocalizedString("Button_Tue", tableName: "WiFiPlug"), for: .normal)
        self.wedBtn.setTitle(NSLocalizedString("Button_Wed", tableName: "WiFiPlug"), for: .normal)
        self.thuBtn.setTitle(NSLocalizedString("Button_Thu", tableName: "WiFiPlug"), for: .normal)
        self.friBtn.setTitle(NSLocalizedString("Button_Fir", tableName: "WiFiPlug"), for: .normal)
        self.satBtn.setTitle(NSLocalizedString("Button_Sat", tableName: "WiFiPlug"), for: .normal)
        
        self.sunBtn.setTitle(NSLocalizedString("Button_Sun", tableName: "WiFiPlug"), for: .normal)
        self.onceBtn.setTitle(NSLocalizedString("Once", tableName: "WiFiPlug"), for: .normal)
        self.weekdayBtn.setTitle(NSLocalizedString("Weekday", tableName: "WiFiPlug"), for: .normal)
        self.weekendBtn.setTitle(NSLocalizedString("Weekend", tableName: "WiFiPlug"), for: .normal)
        self.everydayBtn.setTitle(NSLocalizedString("Everyday", tableName: "WiFiPlug"), for: .normal)
        
        weekBtnList.append(monBtn)
        weekBtnList.append(tueBtn)
        weekBtnList.append(wedBtn)
        weekBtnList.append(thuBtn)
        weekBtnList.append(friBtn)
        weekBtnList.append(satBtn)
        weekBtnList.append(sunBtn)
        
        for btn in weekBtnList {
            btn.setBackgroundImage(UIImage.init(named: "socket_manage103"), for: UIControl.State.normal)
            btn.setBackgroundImage(UIImage.init(named: "socket_manage92"), for: UIControl.State.selected)
        }
        
        typeBtnList.append(onceBtn)
        typeBtnList.append(weekendBtn)
        typeBtnList.append(weekdayBtn)
        typeBtnList.append(everydayBtn)
        
        
        for btn in typeBtnList {
            btn.setBackgroundImage(UIImage.init(named: "socket_manage104"), for: UIControl.State.normal)
            btn.setBackgroundImage(UIImage.init(named: "socket_manage93"), for: UIControl.State.selected)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    @IBAction func clickWeekBtn(_ sender: Any){
        let btn = sender as! UIButton
        btn.isSelected = !btn.isSelected
        let week = self.getWeek()
        
        self.delegate?.miniPiTimeWeekCellUpdateWeek(week)
    }
    
    @IBAction func clickOnceBtn(_ sender: Any){
        
        self.delegate?.miniPiTimeWeekCellUpdateWeek(0)
    }
    
    
    
    @IBAction func clickWeekdayBtn(_ sender: Any){
        
        self.delegate?.miniPiTimeWeekCellUpdateWeek(31)
    }
    
    @IBAction func clickWeekendBtn(_ sender: Any){
        
        self.delegate?.miniPiTimeWeekCellUpdateWeek(96)
    }
    
    @IBAction func clickEveryDayBtn(_ sender: Any){
        
        self.delegate?.miniPiTimeWeekCellUpdateWeek(127)
    }
    
    func updateWeek(_ week: Int8) -> Void {
        self.monBtn.isSelected = ((week>>0) & 0x01) == 1
        self.tueBtn.isSelected = ((week>>1) & 0x01) == 1
        self.wedBtn.isSelected = ((week>>2) & 0x01) == 1
        self.thuBtn.isSelected = ((week>>3) & 0x01) == 1
        self.friBtn.isSelected = ((week>>4) & 0x01) == 1
        self.satBtn.isSelected = ((week>>5) & 0x01) == 1
        self.sunBtn.isSelected = ((week>>6) & 0x01) == 1
        self.onceBtn.isSelected = (week == 0)
        self.weekdayBtn.isSelected = (week == 31)
        self.weekendBtn.isSelected = (week == 96)
        self.everydayBtn.isSelected = (week == 127)
    }
    
    func getWeek() -> Int8 {
        var alarm: Int8 = 0
        
        if (self.monBtn.isSelected) {
            alarm |= 1<<0
        }
        
        
        if (self.tueBtn.isSelected) {
            alarm |= 1<<1;
        }
        
        
        if (self.wedBtn.isSelected) {
            alarm |= 1<<2
        }
        
        
        if (self.thuBtn.isSelected) {
            alarm |= 1<<3;
        }
        
        
        if (self.friBtn.isSelected) {
            alarm |= 1<<4;
        }
        
        
        if (self.satBtn.isSelected) {
            alarm |= 1<<5;
        }
        
        
        if (self.sunBtn.isSelected) {
            alarm |= 1<<6;
        }
        
        
        return alarm;
    }
}
