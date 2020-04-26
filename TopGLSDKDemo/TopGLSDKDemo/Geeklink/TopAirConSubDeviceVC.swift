//
//  TopAirConSubDeviceVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/3.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
class TopAirConSubDeviceCell: UICollectionViewCell {
    @IBOutlet weak var iconiew: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var selectImgView: UIImageView!
    
    
    var _deviceAckInfo: TopDeviceAckInfo!
    var deviceAckInfo: TopDeviceAckInfo{
        set{
            _deviceAckInfo = newValue
            self.iconiew.image = GlobarMethod.getDeviceImageSmall(_deviceAckInfo.deviceInfo)
            self.nameLabel.text = _deviceAckInfo.deviceName+" ("+_deviceAckInfo.place+")"
            let subType: GLAirConSubType = (GLAirConSubType.init(rawValue: Int(_deviceAckInfo.deviceInfo.subType)))!
            let stateInfo: GLAirConState = (GlobalVars.share()?.airConHandle.getState(TopDataManager.shared.homeId, deviceIdSub: _deviceAckInfo.deviceId))!
          
            let onStr = stateInfo.power ? NSLocalizedString("ON", tableName: "MacroPage") : NSLocalizedString("OFF", tableName: "MacroPage")
            stateLabel.text = NSLocalizedString("State",tableName: "MacroPage")+":"+onStr
            if stateInfo.power {
                switch  subType {
                case .ac:
                    var modeStr: String = "Cool"
                  
                    switch stateInfo.airConMode {
                    case .airSupply:
                        modeStr = "Fan"
                    case .heating:
                        modeStr = "Heat"
                    case .drying:
                        modeStr = "Dry"
                    default:
                        modeStr = "Auto"
                        break
                    }
                    modeStr = NSLocalizedString(modeStr, tableName: "MacroPage")
                    
                    var speed: String = "Highest"
                 

                    switch stateInfo.airConSpeed {
                    case .high:
                        speed = "Highest"
                    case .mediumHigh:
                        speed = "Medium hight"
                    case .mediumLow:
                        speed = "Medium low"
                    case .medium:
                         speed = "Medium"
                    case .low:
                        speed = "Lowest"
                    default:
                        speed = "Lowest"
                        break
                    }
                    speed = NSLocalizedString(speed, tableName: "MacroPage")
                    let tempStr: String = String.init(format: "%d", stateInfo.airConTemperature)+"℃"
                    let homeTempStr: String = String.init(format: "%d", stateInfo.roomTemperature)+"℃"

                   stateLabel.text = (stateLabel.text)!+"  "+NSLocalizedString("Mode", tableName: "MacroPage")+":"+modeStr+"  "+NSLocalizedString("Speed", tableName: "MacroPage")+":"+speed+"  "+NSLocalizedString("TEMP",tableName: "MacroPage")+":"+tempStr+"  "+NSLocalizedString("Room TEMP", tableName: "MacroPage")+":"+homeTempStr
                    break
                case .freshAir:
                    var modeStr = "Auto"
              
                    switch stateInfo.freshMode {
                    case .exchange:
                        modeStr = "Ventilation"
                    case .exhaust:
                        modeStr = "Exhaust"
                    case .saving:
                        modeStr = "Saving"
                    case .smart:
                        modeStr = "Smart"
                    case .strong:
                        modeStr = "Strong"
                    default:
                        modeStr = "Auto"
                        break
                    }
                    modeStr = NSLocalizedString(modeStr, tableName: "MacroPage")
                    
                    var speed = "Highest"
                    
                    
                    switch stateInfo.freshSpeed {
                    case .high:
                        speed = "Highest"
                    case .mediumHigh:
                        speed = "Medium hight"
                    case .mediumLow:
                        speed = "Medium low"
                    case .medium:
                        speed = "Medium"
                    case .low:
                        speed = "Lowest"
                    default:
                        speed = "Lowest"
                        break
                    }
                    speed = NSLocalizedString(speed, tableName: "MacroPage")
                    let pmStr = String.init(format: "%d", stateInfo.freshPM25)
                    let vocStr = String.init(format: "%d", stateInfo.freshPM25)
                    let homeTempStr: String = String.init(format: "%d", stateInfo.roomTemperature)+"℃"
                    stateLabel.text = (stateLabel.text)!+"  "+NSLocalizedString("Mode", tableName: "MacroPage")+":"+modeStr+"  "+NSLocalizedString("Speed", tableName: "MacroPage")+":"+speed+"  "+NSLocalizedString("PM2.5", tableName: "MacroPage")+":"+pmStr+"  "+NSLocalizedString("VOC", tableName: "MacroPage")+":"+vocStr+"  "+NSLocalizedString("Room TEMP", tableName: "MacroPage")+":"+homeTempStr
                    break
                case .underfloorHeating:
                    let hfOnStr = stateInfo.heatingFrostProtection ? NSLocalizedString("ON", tableName: "MacroPage") : NSLocalizedString("OFF", tableName: "MacroPage")
                    let semsorTempstr = String.init(format: "%d", stateInfo.heatingTemperature)+"℃"
                    let setTempstr = String.init(format: "%d", stateInfo.heatingDetectTemperature)+"℃"
                    let homeTempStr: String = String.init(format: "%d", stateInfo.roomTemperature)+"℃"
                    stateLabel.text = (stateLabel.text)!+"  "+NSLocalizedString("Frost protection", tableName: "MacroPage")+":"+hfOnStr+"  "+NSLocalizedString("Sensor TEMP", tableName: "MacroPage")+":"+semsorTempstr+"  "+NSLocalizedString("Set TEMP", tableName: "MacroPage")+":"+setTempstr+"  "+NSLocalizedString("Room TEMP", tableName: "MacroPage")+":"+homeTempStr
                    break
                    
                default:
                    break
                }
            }
        
            self.selectImgView.isHidden = !_deviceAckInfo.isSelected
        }
        get{
            return _deviceAckInfo
        }
    }
    
}

/*
 *
 *VC
 */



class TopAirConSubDeviceVC: TopSuperVC , UICollectionViewDelegate, UICollectionViewDataSource{
    var deviceStateCtrlResp: NSObjectProtocol!
    var deviceStateChangeResp: NSObjectProtocol!
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var controlBtn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var type: GLAirConSubType!
    var homeInfo: GLHomeInfo!
    var roomInfo: GLRoomInfo?
    var managerDeviceInfo: GLDeviceInfo!
    var deviceAckInfoList = Array<TopDeviceAckInfo>.init()
    var chooseDeviceInfoList = [GLDeviceInfo]()
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubDevices()
        
        self.homeInfo = GlobalVars.share()?.curHomeInfo
        controlBtn.backgroundColor = GlobarMethod.getThemeColor()
        controlBtn.setTitle(NSLocalizedString("Control", tableName: "RoomPage"), for: .normal)
        controlBtn.layer.cornerRadius = 8
        controlBtn.clipsToBounds = true
       
        self.title = managerDeviceInfo.name
       
        tipLabel.text = NSLocalizedString("Click to select the device for control. If you do not select device, all devices are controlled.", tableName: "RoomPage")
        
        let layout = UICollectionViewFlowLayout()
        let screenW = UIScreen.main.bounds.size.width
        var row = 1
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            row = 2
        }
        
        let itemSizeW = (screenW - CGFloat(row + 1) * 10.0) / CGFloat(row)
        let itemSizeH: CGFloat = 120
        layout.itemSize = CGSize(width:itemSizeW, height: itemSizeH)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
        self.title = self.managerDeviceInfo.name
        if self.roomInfo != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .compose, target: self, action: #selector(rightBarButtonItemDidClicked))
        }
    }
    @objc func rightBarButtonItemDidClicked() -> Void {
        let sb = UIStoryboard(name: "DeviceDetail", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TopGeeklinkDetailVC") as! TopGeeklinkDetailVC
        vc.homeInfo = homeInfo
        vc.roomInfo = (roomInfo)!
        vc.deviceInfo = managerDeviceInfo
        show(vc, sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deviceStateCtrlResp = NotificationCenter.default.addObserver(forName: NSNotification.Name("deviceStateCtrlResp"), object: nil, queue: nil) { (notification) in
            
            let ackInfo = notification.object as! TopDeviceAckInfo
            self.processTimerStop()
            switch ackInfo.state {
            case .ok:
                GlobarMethod.notifySuccess()
            default:
                GlobarMethod.notifyFailed()
            }
        }
        
        
        //增加设备状态变化监听
        deviceStateChangeResp = NotificationCenter.default.addObserver(forName: NSNotification.Name("deviceStateChangeResp"), object: nil, queue: nil) { (notification) in
            
              self.collectionView.reloadData()

        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //移除设备控制监听
        NotificationCenter.default.removeObserver(deviceStateCtrlResp)
        //移除设备状态变化监听
        NotificationCenter.default.removeObserver(deviceStateChangeResp)
    }
    
    @IBAction func controlBtnDidClicked(_ sender: Any) {
        self.chooseDeviceInfoList.removeAll()
        for deviceInfo in self.deviceAckInfoList {
            if deviceInfo.isSelected == true {
                self.chooseDeviceInfoList.append(deviceInfo.deviceInfo)
            }
        }
      
        switch self.type {
        case GLAirConSubType.ac?:
            self.onClickAirCon(self.controlBtn)
        case GLAirConSubType.freshAir?:
            self.onClickFlesh(self.controlBtn)
        case GLAirConSubType.underfloorHeating?:
            self.onClickHeating(self.controlBtn)
        default:
            break
        }
    }
    
    
    func onClickAirCon(_ view: UIView) {
        
        let alert = UIAlertController(title: NSLocalizedString("Air Conditioner", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Power", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.airConPower(view)
        }))
        alert.addAction(UIAlertAction(title:NSLocalizedString("Temperature", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.airConTemperature(view)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Mode", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.airConMode(view)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Speed", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.airConSpeed(view)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func airConPower(_ view: UIView) {
        let alert = UIAlertController(title: NSLocalizedString("Air Conditioner Power", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn On", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConPower(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, power: true) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConPower(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, power: false) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func airConTemperature(_ view: UIView) {
        
        let alert = UIAlertController(title: NSLocalizedString("Set Air Conditioner Temperature(16℃~30℃)", tableName: "RoomPage"), message: "", preferredStyle: .alert)
        //设置输入框
        alert.addTextField(configurationHandler: { (textField) in
            textField.textAlignment = .center
            textField.text = "16"
            textField.keyboardType = .numberPad
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: {
            (UIAlertAction) -> Void in
            
            let temperature = alert.textFields?.first?.text
            let temNum = Int(temperature!)!
            if temNum < 16 {
                self.alertMessage(NSLocalizedString("Input temperature is too low", tableName: "RoomPage"))
                return
            }
            if  temNum > 30{
                self.alertMessage(NSLocalizedString("Input temperature is too high", tableName: "RoomPage"))
                return
            }
            
            if GlobalVars.share()?.airConHandle.airConTemperature(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, temperature: Int8(temperature!)!) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func airConMode(_ view: UIView) {
        let alert = UIAlertController(title: NSLocalizedString("Air Conditioner Mode", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cool", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .cooling) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Heat", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .heating) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Fan", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .airSupply) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Dry", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .drying) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func airConSpeed(_ view: UIView) {
        
        let alert = UIAlertController(title: NSLocalizedString("Air Conditioner Speed", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Highest", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.high) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium hight", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.mediumHigh) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.medium) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
       
        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium low", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.mediumLow) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Lowest", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.low) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        present(alert, animated: true, completion: nil)
    }
    
    
   
    
    //MARK: - 控制新风
    
    func onClickFlesh(_ view: UIView) {
        
        let alert = UIAlertController(title: nil, message: NSLocalizedString("Fresh Air", tableName: "RoomPage"), preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Power", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.freshPower(view)
        }))
        alert.addAction(UIAlertAction(title:NSLocalizedString("Mode", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.freshMode(view)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Speed", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.freshSpeed(view)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func freshPower(_ view: UIView) {
        
        let alert = UIAlertController(title: NSLocalizedString("Fresh Air Power", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn On", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.freshPower(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, power: true) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.freshPower(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, power: false) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func freshMode(_ view: UIView) {
        
        let alert = UIAlertController(title: "Fresh Air Mode", message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
      
       
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Auto", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.freshMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .auto) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ventilation", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.freshMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .exchange) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
     
        
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Exhaust", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.freshMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .exhaust) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Smart", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.freshMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .smart) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Strong", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.freshMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .strong) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Saving", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.freshMode(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, mode: .saving) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func freshSpeed(_ view: UIView) {
        
        let alert = UIAlertController(title: NSLocalizedString("Fresh Air Speed", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Highest", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.high) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium hight", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.mediumHigh) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.medium) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
       
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium low", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.mediumLow) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Lowest", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.airConSpeed(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, speed: GLAirConSpeedType.low) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - 控制地暖
    
    func onClickHeating(_ view: UIView) {
        
        
        let alert = UIAlertController(title: NSLocalizedString("Underfloor Heating", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Power", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.heatingPower(view)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Set Temperature", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.heatingTemperature(view)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Frost Protection", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            self.heatingFrostProtection(view)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func heatingPower(_ view: UIView) {
        
        let alert = UIAlertController(title: NSLocalizedString("Underfloor Heating Power", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn On", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.heatingPower(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, power: true) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.heatingPower(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, power: false) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func heatingTemperature(_ view: UIView) {
        let alert = UIAlertController(title: "Set Underfloor Heating Temperature(5℃~90℃)", message: "", preferredStyle: .alert)
        //设置输入框
        alert.addTextField(configurationHandler: { (textField) in
            textField.textAlignment = .center
            textField.text = "5"
            textField.keyboardType = .numberPad
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default, handler: {
            (UIAlertAction) -> Void in
            let temperature = alert.textFields?.first?.text
            let temNum = Int(temperature!)!
            if temNum < 5 {
                self.alertMessage(NSLocalizedString("Input temperature is too low", tableName: "RoomPage"))
                return
            }
            if  temNum > 90{
                self.alertMessage(NSLocalizedString("Input temperature is too high", tableName: "RoomPage"))
                return
            }
            
            if GlobalVars.share()?.airConHandle.heatingTemperature(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, temperature: Int8(temperature!)!) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func heatingFrostProtection(_ view: UIView) {
        
        let alert = UIAlertController(title: NSLocalizedString("Underfloor Heating Frost Protection", tableName: "RoomPage"), message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Turn On", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.heatingFrostProtection(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, frostProtection: true) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Turn Off", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            if GlobalVars.share()?.airConHandle.heatingFrostProtection(self.homeInfo.homeId, deviceIdHost: self.managerDeviceInfo.deviceId, deviceList: self.chooseDeviceInfoList, frostProtection: false) == 0 {
                self.processTimerStart(3)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
 
    
    
    
    func initSubDevices() -> Void {
        self.deviceAckInfoList.removeAll()
        let deviceAckInfoList = TopDataManager.shared.resetDeviceInfo()
        for deviceAckInfo in deviceAckInfoList {
            let subType: GLAirConSubType = (GLAirConSubType.init(rawValue: Int(deviceAckInfo.deviceInfo.subType)))!
            if deviceAckInfo.md5 == self.managerDeviceInfo.md5 && subType == type {
                 self.deviceAckInfoList.append(deviceAckInfo)
            }
            
        }
        self.collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.deviceAckInfoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : TopAirConSubDeviceCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopAirConSubDeviceCell", for: indexPath) as! TopAirConSubDeviceCell
        cell.deviceAckInfo = deviceAckInfoList[indexPath.row]
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deviceAckInfoList[indexPath.row].isSelected = !deviceAckInfoList[indexPath.row].isSelected
        self.collectionView.reloadData()
    }
   
    // 返回HeadView的宽高
 
  
}
