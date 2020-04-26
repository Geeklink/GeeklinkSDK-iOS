
//
//  TopSetUsefulTimeCell.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/14.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopSetUsefulTimeCell: UITableViewCell {

    @IBOutlet weak var endTimeValueLabel: UILabel!
    @IBOutlet weak var beginTimeValueLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var beginTimeLabel: UILabel!
    @IBOutlet weak var beginTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    
    var _beginTime: Int32 = 0
    var beginTime: Int32{
        set{
            _beginTime = newValue
            
            self.beginTimePicker.setDate( (GlobarMethod.time(toDate: _beginTime) as NSDate) as Date, animated: true)
            self.beginTimeValueLabel.text = String(glTime: Int16(_beginTime))
            
        }
        get{
            return _beginTime
        }
        
    }
    var _endTime: Int32 = 1439
    
    var endTime: Int32{
        set{
            _endTime = (newValue as Int32?)!
            self.endTimePicker.setDate( GlobarMethod.time(toDate: _endTime) as Date, animated: true)
            
            var timeStr: String = String(glTime: Int16(_endTime))
            
            if _endTime < _beginTime{
                timeStr = timeStr+" ("+NSLocalizedString("Next day", tableName: "MacroPage")+" )"
            }
           self.endTimeValueLabel.text = timeStr
            
            
        }
        get{
            return _endTime
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.beginTimeLabel.font = self.textLabel?.font
        self.beginTimeLabel.text = NSLocalizedString("Begin time", tableName: "MacroPage")
        
        self.endTimeLabel.font = self.textLabel?.font
        self.endTimeLabel.text = NSLocalizedString("End time", tableName: "MacroPage")
        self.endTimeValueLabel.textColor = UIColor.gray
        self.endTimeValueLabel.font = self.detailTextLabel?.font
        self.beginTimeValueLabel.textColor = UIColor.gray
    
        self.beginTimeValueLabel.font = self.detailTextLabel?.font
        self.beginTimePicker .addTarget(self, action: #selector(beginTimePickerValueDidChange), for: .valueChanged)
        self.endTimePicker .addTarget(self, action: #selector(endTimePickerValueDidChange), for: .valueChanged)
    
    }
    
    @objc func beginTimePickerValueDidChange(_ beginTimePicker :UIDatePicker) {
        
        _beginTime = Int32(beginTimePicker.countDownDuration / 60)
        
        self.beginTimeValueLabel.text = String(glTime: Int16(_beginTime))
        
        
        var timeStr: String = String(glTime: Int16(_endTime))
        
        if _endTime < _beginTime{
            timeStr = timeStr+" ("+NSLocalizedString("Next day", tableName: "MacroPage")+" )"
        }
        self.endTimeValueLabel.text = timeStr
    }
    
    @objc func endTimePickerValueDidChange(_ endTimePicker :UIDatePicker) {
        _endTime = Int32(endTimePicker.countDownDuration / 60)
        
        
        var timeStr: String = String(glTime: Int16(_endTime))
        
        if _endTime < _beginTime{
            timeStr = timeStr+" ("+NSLocalizedString("Next day", tableName: "MacroPage")+" )"
        }
        self.endTimeValueLabel.text = timeStr
    }
}
