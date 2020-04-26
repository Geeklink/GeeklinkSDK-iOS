//
//  TopStartCondition.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/12.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

enum TopStartUpConditionType: Int{
    //门磁感应
    case TopStartUpConditionTypeDMI
    //人体感应
    case TopStartUpConditionTypeHI
    //反馈开关
    case TopStartUpConditionTypeFW
    //智能遥控器
    case TopStartUpConditionTypeSRC
    //情景面板
    case TopStartUpConditionTypeSP
    //第三方设备
    case TopStartUpConditionTypTPD
    //时间
    case TopStartUpConditionTypT
    
    //有效时间
    case TopStartUpConditionTypeUT
    
    //温度湿度
    case TopStartUpConditionTypeTemPAndHum
    //定位
    case TopStartUpConditionTypeLoc
    
    //不清楚
    case TopStartUpConditionTypeUnknow
    

}

class TopCondition: NSObject {
    
    
  
    
    var order: Int32?//
    var ID: Int32? 
    var type: String?
    var md5: String?
    
    var value: String?
    var subId: Int32?
    var time: Int32?
    var week: Int32?
    
    var begin: Int32?
    var end: Int32?//
    
    var icon: UIImage = UIImage.init()
    var name: String = ""
    
    var conditionType: String = "trigger"
    
    //用于显示条件总页面的title
    var attName: NSMutableAttributedString = NSMutableAttributedString.init()
    var timerModel : TopTimerModel = TopTimerModel.init()
    var usefulTime : TopUsefulTime = TopUsefulTime.init()
    //启动条件的类型名称 设备所在位置+设备名称
    
    var switchCtrlInfo : GLSwitchCtrlInfo = GLSwitchCtrlInfo.init()
    var switchCount : Int32 = 1
    //启动条件的类型名称 设备所在位置+设备名称
    //启动条件的类型名称 设备所在位置+设备名称
    var nameAndPlaceAtt : NSMutableAttributedString = NSMutableAttributedString.init()
    
 
    var isHiddenEdit: Bool = true
    
    var isBigger: Bool = true
    var temOrHumValue: Int8 = 0
    
   
    
    var _device: TopDeviceAckInfo?
    var block: (UIViewController) -> Void = {
        (vc: UIViewController) in
    }
    
    var _conditionInfo: GLConditionInfo?
    var conditionInfo: GLConditionInfo?{
        set{
            _conditionInfo = newValue
            ID = _conditionInfo?.id
            order = _conditionInfo?.order
            type = _conditionInfo?.type
            value = _conditionInfo?.value
             //type device设备/timer定时器/valid_time有效时间段/temperature温度/humidity湿度/location定位
            if type == "timer" {
                 startUpConditionType = .TopStartUpConditionTypT
                nameAndPlaceAtt = NSMutableAttributedString.init(string: NSLocalizedString("Timer", comment: ""))
            }else  if type == "valid_time"{
                 startUpConditionType = .TopStartUpConditionTypeUT
                 nameAndPlaceAtt = NSMutableAttributedString.init(string: NSLocalizedString("Valid Time", comment: ""))
            }
            else  if type == "humidity"{
                
                 startUpConditionType = .TopStartUpConditionTypeTemPAndHum
                 isBigger =  GlobalVars.share().macroHandle.getTempHumBigger(value)
                 temOrHumValue =  GlobalVars.share().macroHandle.getTempHumValue(value)
                
                setUpTemOrHumAttName()
                
              
              
                
            }
            else  if type == "temperature"{
                startUpConditionType = .TopStartUpConditionTypeTemPAndHum
                isBigger =  GlobalVars.share().macroHandle.getTempHumBigger(value)
                temOrHumValue =  GlobalVars.share().macroHandle.getTempHumValue(value)
               
                setUpTemOrHumAttName()
            }
            else  if type == "location"{
                 startUpConditionType = .TopStartUpConditionTypeLoc
            }
           
            md5 = _conditionInfo?.md5.lowercased()
            
           
            subId = _conditionInfo?.subId
          
            week = _conditionInfo?.week
            time = _conditionInfo?.time
            
            begin = _conditionInfo?.begin
            end = _conditionInfo?.end
            
           
            switch startUpConditionType {
                case .TopStartUpConditionTypT?:
                   
                    timerModel.weekDayByte = week
                    timerModel.timer = time
                case .TopStartUpConditionTypeUT?:
                    usefulTime.weekDayByte =  week
                    usefulTime.beginTime = begin
                    usefulTime.endTime = end
                default:
                    break
                
            }
            
            
        }
        get{
            _conditionInfo = GLConditionInfo.init(id: ID!, order: order!, type: type!, md5: md5!, subId: subId!, value: value!, time: time!, week: week!, begin:begin!, end: end!)
            return _conditionInfo
        }
    }
    
    func initAttButNomalName() -> Void {
      
        if _device?.deviceName == nil {
            _device?.deviceName = ""
        }
        
        var devicePlace:String = ""
       
        if _device?.place == nil {
            device?.place = ""
            
        }else{
            devicePlace = "("+(_device?.place)!+")"
        }
        
       
        attName = NSMutableAttributedString.init()
        let deviceAndPlaceAttName: NSMutableAttributedString = NSMutableAttributedString.init(string:(_device?.deviceName)!+" "+devicePlace)
        deviceAndPlaceAttName.addAttributes([NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)], range: NSMakeRange((device?.deviceName.count)! + 1, (devicePlace.count)))
        deviceAndPlaceAttName.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (_device?.deviceName.count)!))
        attName = deviceAndPlaceAttName
        nameAndPlaceAtt = NSMutableAttributedString.init(attributedString: deviceAndPlaceAttName)
    }
    
    
    var device: TopDeviceAckInfo? {
        set{
            _device = newValue
            if (_startUpConditionType == .TopStartUpConditionTypeUT) || (_startUpConditionType == .TopStartUpConditionTypT){
                return
                
            }
            
            _startUpConditionType = .TopStartUpConditionTypeUnknow
            
            md5 = _device?.deviceInfo.md5.lowercased()
            subId = _device?.deviceInfo.subId
            
            
            
            icon = (device?.icon)!
            
            initAttButNomalName()
            
            
            switch device?.deviceInfo.mainType {
            case .geeklink?:
                _startUpConditionType = .TopStartUpConditionTypeTemPAndHum
                setUpTemOrHumAttName()
                
            case .rf315m?:
                _startUpConditionType = .TopStartUpConditionTypTPD
                value = "01"
                let opStr: String = NSLocalizedString("trigger", comment: "")
                let opMutAttStr: NSMutableAttributedString = NSMutableAttributedString.init(string:opStr)
                opMutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (opStr.count)))
                attName.append(opMutAttStr)
                
            default:
                break
            }
            
            
          
            if  device?.deviceInfo.mainType == .slave{
                
              
               
                
                switch device?.slaveType {
            
                case .relay?,.relayBetter?:
                    _startUpConditionType = .TopStartUpConditionTypeTemPAndHum
                    
                    
                 
                    setUpTemOrHumAttName()
                    
                case .fb1Neutral1?,.fb1Neutral2?,.fb1Neutral3?,.fb11?,.fb12?,.fb13?,.ioModula?:
                    
                    
                    if (device?.slaveType == .fb1Neutral1) || (device?.slaveType == .fb11){
                        switchCount = 1
                    }else if(device?.slaveType == .fb1Neutral2) || (device?.slaveType == .fb12){
                        switchCount = 2
                    }else if(device?.slaveType == .fb1Neutral3) || (device?.slaveType == .fb13){
                        switchCount = 3
                    }
                    else if(device?.slaveType == .ioModula){
                        switchCount = 4
                        
                    }
                    resetButtonStr()
                    
                    _startUpConditionType = .TopStartUpConditionTypeFW
        
                case .macroKey1?,.macroKey4?://情景面板
                    _startUpConditionType = .TopStartUpConditionTypeSP
                    
                    if device?.slaveType == .macroKey4{
                        if _conditionInfo != nil
                        {
                            var buttonList = Array<String>.init()
                            buttonList.append(" A")
                            buttonList.append(" B")
                            buttonList.append(" C")
                            buttonList.append(" D")
                            
                            let valueNum:Int = Int(GlobalVars.share().macroHandle.getRCKey(value)) - 1
                            
                        
                            if (valueNum < buttonList.count) && (valueNum >= 0){
                                let appStr: String = NSLocalizedString("When", comment: "")
                                
                                let opStr: String = NSLocalizedString("(On)", comment: "") 
                                let btnStr = buttonList[valueNum]
                                
                                
                                let opMutAttStr: NSMutableAttributedString = NSMutableAttributedString.init(string:btnStr+" "+opStr + " " + appStr)
                                opMutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, btnStr.count))
                                
                                opMutAttStr.addAttributes([NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)], range: NSMakeRange(btnStr.count + 1, opStr.count))
                                opMutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(btnStr.count + opStr.count + 2, appStr.count))
                                attName.append(opMutAttStr)
                                
                            }
                            
                        }
                    }
                  
                case .securityRC?,.doorSensor?,.irSensor?://智能遥控器,门磁感应，红外感应
                    _startUpConditionType = .TopStartUpConditionTypeSRC
                    let valueNum:Int = Int(GlobalVars.share().macroHandle.getRCKey(value))
                    var opStr = GlobarMethod.getSRCName(withValue: Int32(valueNum))
                    if (device?.slaveType == .doorSensor) || (device?.slaveType == .irSensor)
                    {
                        _startUpConditionType = .TopStartUpConditionTypeHI
                        let isOn: Bool = (GlobalVars.share().macroHandle.getDoorMotionState(value))
                        let num: Int32 = isOn ? 1:0
                        opStr = GlobarMethod.getIRName(withValue: num)
                        if device?.slaveType == .doorSensor{
                              _startUpConditionType = .TopStartUpConditionTypeDMI
                              opStr = GlobarMethod.getDoorSensorName(withValue: num)
                        }
                      
                    }
                    let opMutAttStr: NSMutableAttributedString = NSMutableAttributedString.init(string:opStr!)
                    opMutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (opStr?.count)!))
                     attName.append(opMutAttStr)
                    
                
                    
                default:
                    break
                }
            }

        
        }
        get{
            return _device
        }
            
            
    }
    
    func resetButtonStr() -> Void {
        
        
        switchCtrlInfo = GlobalVars.share().macroHandle.getFBSwicthConditionInfo(value)
        
        
        if (switchCtrlInfo.rockBack == false){
            var onBtnStr:String = ""
            var offBtnStr:String = ""
            if switchCtrlInfo.aCtrl{
                if switchCtrlInfo.aOn{
                    onBtnStr.append("A")
                }else{
                    offBtnStr.append("A")
                }
            }
            if switchCtrlInfo.bCtrl{
                if switchCtrlInfo.bOn{
                    onBtnStr.append("B")
                }else{
                    offBtnStr.append("B")
                }
            }
            if switchCtrlInfo.cCtrl{
                if switchCtrlInfo.cOn{
                    onBtnStr.append("C")
                }else{
                    offBtnStr.append("C")
                }
            }
            if switchCtrlInfo.dCtrl{
                if switchCtrlInfo.dOn{
                    onBtnStr.append("D")
                }else{
                    offBtnStr.append("D")
                }
            }
            
            var mutAttStr: NSMutableAttributedString = NSMutableAttributedString.init()
            
            
            if (onBtnStr == "")&&(offBtnStr == ""){
                let str: String =  " " + NSLocalizedString("No Control", comment: "")
                mutAttStr = NSMutableAttributedString.init(string:str)
                mutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (str.count)))
            }else{
                mutAttStr = NSMutableAttributedString.init()
                if(onBtnStr != ""){
                    let btnStr = " "+onBtnStr
                    let onStr: String = " ("+NSLocalizedString("On", comment: "")+")"
                    
                    mutAttStr.append(NSAttributedString.init(string:btnStr + onStr))
                    mutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (btnStr.count)))
                    mutAttStr.addAttributes([NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)], range:NSMakeRange(btnStr.count, onStr.count))
                }
                
                if (offBtnStr != ""){
                  
                    let btnStr = " "+offBtnStr
                  
                    let offStr: String = " ("+NSLocalizedString("Off", comment: "")+")"
                    
                    var offMutAttStr: NSMutableAttributedString = NSMutableAttributedString.init(string:btnStr + offStr)
                    offMutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (btnStr.count)))
                    offMutAttStr.addAttributes([NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)], range:NSMakeRange(btnStr.count, offStr.count))
                    mutAttStr.append(offMutAttStr)
                }
                
            }
            attName.append(mutAttStr)
        }else{  //if (switchCtrlInfo.rockBack)
            
        }
       
        
        
    }
    
    func setUpTemOrHumAttName() -> Void {
        var opStr: String = NSLocalizedString("temperature", comment: "") + " "
        
        if type == "humidity"{
            opStr = NSLocalizedString("humidity", comment: "") + " "
        }
        let compareStr = isBigger ? NSLocalizedString("(Higher)", comment: "") : NSLocalizedString("(Lower)", comment: "")
        let valueStr =  String.init(format: " %d%", temOrHumValue)
        
        
        
        let mutAttStr: NSMutableAttributedString = NSMutableAttributedString.init(string:opStr + compareStr + valueStr)
        
        mutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (opStr.count)))
        
        mutAttStr.addAttributes([NSForegroundColorAttributeName: UIColor.gray, NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)], range: NSMakeRange(opStr.count, compareStr.count))
        
        mutAttStr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(opStr.count + compareStr.count, valueStr.count ))
        
        attName.append(mutAttStr)
    }
    var _startUpConditionType: TopStartUpConditionType = .TopStartUpConditionTypeDMI
    var startUpConditionType: TopStartUpConditionType?{
        
        set{
            _startUpConditionType = newValue as TopStartUpConditionType!
            switch _startUpConditionType {
                case .TopStartUpConditionTypT:
                    icon = UIImage.init(named: "scene_time")!
                    nameAndPlaceAtt = NSMutableAttributedString.init(string: NSLocalizedString("Valid Time", comment: ""))
            case .TopStartUpConditionTypeUT:
                icon = UIImage.init(named: "scene_time")!
                nameAndPlaceAtt = NSMutableAttributedString.init(string: NSLocalizedString("Valid Time", comment: ""))
                case .TopStartUpConditionTypeTemPAndHum:
                    icon = UIImage.init(named:  "room_temphum_normal_26")!
                 default:
               
                    break;
                
            }
           
           
        }
        get{
           return _startUpConditionType
        }
        
    }
}
