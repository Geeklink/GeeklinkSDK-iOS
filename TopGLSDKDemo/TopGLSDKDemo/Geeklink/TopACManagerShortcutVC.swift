//
//  TopACManagerShortcutVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/29.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
import IntentsUI
@available(iOS 12.0, *)

class TopACManagerShortcutVC:TopSuperVC , UICollectionViewDelegate, UICollectionViewDataSource, INUIAddVoiceShortcutViewControllerDelegate{
    var deviceStateCtrlResp: NSObjectProtocol!
    var deviceStateChangeResp: NSObjectProtocol!
    
    @IBOutlet weak var tipLabel: UILabel!
    var addVoiceShortcutVC :INUIAddVoiceShortcutViewController!
    @IBOutlet weak var controlBtn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var type: GLAirConSubType!
    var managerDeviceInfo: GLDeviceInfo!
    var deviceAckInfoList = Array<TopDeviceAckInfo>.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.managerDeviceInfo = TopDataManager.shared.task?.device?.deviceInfo
        initSubDevices()
        
        controlBtn.backgroundColor = APP_ThemeColor
        controlBtn.setTitle(NSLocalizedString("Select Action", tableName: "MacroPage"), for: .normal)
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
        NotificationCenter.default.removeObserver(deviceStateCtrlResp as Any)
        //移除设备状态变化监听
        NotificationCenter.default.removeObserver(deviceStateChangeResp as Any)
    }
    
    @IBAction func controlBtnDidClicked(_ sender: Any) {
        
        
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
    func addTaskWithAcManageCtrlInfo(_ acManageCtrlInfo: GLAcManageCtrlInfo) -> Void {
        
        let task: TopTask  = TopDataManager.shared.task!
        var subIdStr = ""
        for deviceInfo in self.deviceAckInfoList {
            
            if deviceInfo.isSelected == true {
                if subIdStr == "" {
                    subIdStr = String.init(format: "%d", deviceInfo.subId)
                    
                }else {
                   subIdStr = subIdStr+String.init(format: "%d", deviceInfo.subId)
                }
               
            }
        }
      
        task.value = SGlobalVars.actionHandle.getAcManageActionValue(acManageCtrlInfo)
//        if  #available(iOS 12.0, *){
        
            let intent  = TopIntent()
            //intent.homeId = Globa
            
            intent.homeID = TopDataManager.shared.homeId
            intent.iD = String.init(format: "%d", (task.device?.deviceId)!)
            intent.action = task.value
            intent.remarks = task.operationName.string
            intent.type = "device"
            intent.oem = String.init(format: "%d", Int(App_Company.rawValue))
            intent.md5 = task.device?.md5
            intent.subId = subIdStr
            let interaction: INInteraction  = INInteraction.init(intent: intent, response: nil)
            interaction.identifier = String.init(format: "%d", (task.device?.deviceId)!)
            
            interaction.donate { (error) in
                
            }
            
            guard let shortcut = INShortcut.init(intent: intent) else { return }
            
            let controller = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            controller.delegate = self
            addVoiceShortcutVC = controller
            self.present(controller, animated: true) {
                
            }
//        }
        
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
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConPower, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
            
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConPower, power: false, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
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
            
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConTemperature, power: true, temperature: Int8(temNum), airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
            
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
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConMode, power: true, temperature: 0, airConMode: GLAirConModeType.cooling, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Heat", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConMode, power: true, temperature: 0, airConMode: GLAirConModeType.heating, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Fan", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConMode, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Dry", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConMode, power: true, temperature: 0, airConMode: GLAirConModeType.drying, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
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
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.high, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium hight", tableName: "MacroPage"), style: .default, handler: {
//            (UIAlertAction) -> Void in
//            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.mediumHigh, frostProtection: false))!
//            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
//        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.medium, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        
        
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium low", tableName: "MacroPage"), style: .default, handler: {
//            (UIAlertAction) -> Void in
//            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.mediumLow, frostProtection: false))!
//            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
//        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Lowest", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.airConSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
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
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshPower, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshPower, power: false, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
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
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshMode, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Ventilation", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshMode, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.exhaust, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        
        
        
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Exhaust", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshMode, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.exhaust, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Smart", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshMode, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.smart, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Strong", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshMode, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.strong, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Saving", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshMode, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.saving, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
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
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.high, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium hight", tableName: "MacroPage"), style: .default, handler: {
//            (UIAlertAction) -> Void in
//            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.mediumHigh, frostProtection: false))!
//            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
//        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.medium, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        
        
//        alert.addAction(UIAlertAction(title: NSLocalizedString("Medium low", tableName: "MacroPage"), style: .default, handler: {
//            (UIAlertAction) -> Void in
//            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.mediumLow, frostProtection: false))!
//            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
//        }))
        
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Lowest", tableName: "MacroPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.freshSpeed, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
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
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.heatingPower, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.heatingPower, power: false, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
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
            
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.heatingTemperature, power: true, temperature: Int8(temNum), airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
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
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.heatingFrostProtection, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: true))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        
        alert.addAction(UIAlertAction(title:  NSLocalizedString("Turn Off", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            let acManageCtrlInfo: GLAcManageCtrlInfo = (GLAcManageCtrlInfo.init(ctrlType: GLAcManageCtrlType.heatingFrostProtection, power: true, temperature: 0, airConMode: GLAirConModeType.airSupply, freshMode: GLFreshModeType.auto, speed: GLAirConSpeedType.low, frostProtection: false))!
            self.addTaskWithAcManageCtrlInfo(acManageCtrlInfo)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func initSubDevices() -> Void {
        self.deviceAckInfoList.removeAll()
        let deviceAckInfoList = TopDataManager.shared.resetDeviceInfo()
        let subIdList: [Int32] = (TopDataManager.shared.task?.subIdList)!
        for deviceAckInfo in deviceAckInfoList {
            let subType: GLAirConSubType = (GLAirConSubType.init(rawValue: Int(deviceAckInfo.deviceInfo.subType)))!
            if deviceAckInfo.md5 == self.managerDeviceInfo.md5 && subType == type {
                for subId in subIdList {
                    if subId == deviceAckInfo.subId {
                        deviceAckInfo.isSelected = true
                    }
                }
                self.deviceAckInfoList.append(deviceAckInfo)
                
            }
            
        }
        self.collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.deviceAckInfoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : TopACManagerActionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopACManagerActionCell", for: indexPath) as! TopACManagerActionCell
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
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        addVoiceShortcutVC.dismiss(animated: true) {
            
        }
        GlobarMethod.notifySuccess()
        for vc in (self.navigationController?.viewControllers)! {
            if vc is TopSiriShortCutsListVC {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        addVoiceShortcutVC.dismiss(animated: true) {
            
        }
    }
    
}
