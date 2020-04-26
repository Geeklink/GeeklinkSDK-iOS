//
//  TopSensorSelectTriggerVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/5/8.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopSensorSelectTriggerVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource, TopEffectiveTimePickerViewDelegate {
   
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gotoRoomBtn: UIButton!
    @IBOutlet weak var tipLabel: UILabel!
    var nextItem: UIBarButtonItem?
    weak var showPickerView: PickerView?
    var delayTime: Int32 = 0
    var macro: TopMacro = TopDataManager.shared.macro!
    var timeCondition: TopCondition = TopCondition()
    
    var deviceSensorList = [TopDeviceAckInfo]()
    var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TopDeviceSelectedCell", bundle: nil), forCellReuseIdentifier: "TopDeviceSelectedCell")
       
        title = macro.name
        initSubviews()
        initDeviceSensorList()
 
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if showPickerView != nil {
            showPickerView?.frame = (UIApplication.shared.keyWindow?.bounds)!
        }
    }
    func initSubviews() -> Void {
        if macro.type == .turnOnAc || macro.type == .openDoorLightOn{
            tipLabel.text = NSLocalizedString("No door sensor, please go to the \"Room\" page to add.", tableName: "MacroPage")
        }else{
            tipLabel.text = NSLocalizedString("No Infra-red sensor, please go to the \"Room\" page to add.", tableName: "MacroPage")
        }
        
        self.gotoRoomBtn.layer.cornerRadius = 22
        self.gotoRoomBtn.clipsToBounds = true
        self.gotoRoomBtn.backgroundColor = APP_ThemeColor
        self.gotoRoomBtn.setTitle("Go to Room", for: .normal)
        self.gotoRoomBtn.addTarget(self, action: #selector(gotoRoomBtnDidClicked), for: .touchUpInside)
    }
    @objc func gotoRoomBtnDidClicked() -> Void {
        
        self.tabBarController?.selectedIndex = 1
        
        self.tabBarController?.selectedIndex = 1
        let time: TimeInterval = 0.1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            //code
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let macroSet = NSNotification.Name("macroSetResp")
        NotificationCenter.default.addObserver(self, selector: #selector(macroSetResp), name:macroSet, object: nil)
        if deviceSensorList.count > 0{
            nextItem = UIBarButtonItem(title: NSLocalizedString("Next", tableName: "MacroPage"), style: .done, target: self, action: #selector(nextItemDidClicked))
            nextItem?.tintColor = APP_ThemeColor
            self.navigationItem.rightBarButtonItem = nextItem
        }else{
            self.navigationItem.rightBarButtonItem = nil
        }
       
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let macroSetResp = NSNotification.Name("macroSetResp")
        NotificationCenter.default.removeObserver(self, name: macroSetResp, object: nil)
    }
    @objc func nextItemDidClicked() -> Void {
        var triggerConditions = Array<TopCondition>()
        let macro = TopDataManager.shared.macro
        for deviceAckInfo in deviceSensorList{
            if deviceAckInfo.isSelected == true{
                let condition = TopCondition()
                condition.duration = self.delayTime
                condition.device = deviceAckInfo
                if (macro?.type == .openDoorLightOn) ||
                    (macro?.type == .turnOnAc) ||
                    (macro?.type == .comeLightOn) {
                    condition.value = SGlobalVars.conditionHandle.getDoorMotionValueString(true)
                   
                } else {
                    condition.value = SGlobalVars.conditionHandle.getDoorMotionValueString(false)
                    
                }
                triggerConditions.append(condition)
                
            }
        }
        if triggerConditions.count == 0 {
            self.alertMessage(NSLocalizedString("At least one device is selected.", tableName: "MacroPage"))
        }
        macro?.triggerConditions = triggerConditions
        
        if (macro?.type == .openDoorLightOn) ||  (macro?.type == .comeLightOn)  {
            var addtionConditionList = Array<TopCondition>()
            addtionConditionList.append(timeCondition)
            macro?.additionalConditions = addtionConditionList
        }
        let sb = UIStoryboard(name: "Macro", bundle: nil)
        let fWTaskSelectVC: TopDeviceTaskSelectVC = sb.instantiateViewController(withIdentifier: "TopDeviceTaskSelectVC") as! TopDeviceTaskSelectVC
        fWTaskSelectVC.delayTime = 0
        self.show(fWTaskSelectVC, sender: nil)
        
    }
    @objc func macroSetResp(notificatin: Notification) {//请求条件列表回复
        processTimerStop()
        
        let info = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            navigationController?.popToRootViewController(animated: true)
            
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    func initDeviceSensorList() -> Void {
        let deviceInfoList = TopDataManager.shared.resetDeviceInfo()
        let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
    
        for deviceAckInfo in deviceInfoList{
            if hostSubType == .thinkerMini {
                if deviceAckInfo.deviceInfo.md5 != TopDataManager.shared.hostDeviceInfo?.md5 {
                    continue
                }
            }
             if  deviceAckInfo.deviceInfo.mainType == .slave{
                if macro.type == .turnOnAc || macro.type == .openDoorLightOn{
                    if (deviceAckInfo.slaveType == .doorSensor) {
                        deviceSensorList.append(deviceAckInfo)
                        if deviceSensorList.count == 1{
                            deviceAckInfo.isSelected = true
                        }
                    }
                } else {
                    if (deviceAckInfo.slaveType == .motionSensor) {
                        deviceSensorList.append(deviceAckInfo)
                        if deviceSensorList.count == 1{
                            deviceAckInfo.isSelected = true
                        }
                    }
                }
            }
        }
        if deviceSensorList.count == 0{
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.isHidden = true
            self.tipLabel.isHidden = false
            self.gotoRoomBtn.isHidden = false
        }else{
           
            self.tableView.isHidden = false
            self.tipLabel.isHidden = true
            self.gotoRoomBtn.isHidden = true
        }
        

        timeCondition.conditionType = .effectiveTime
        timeCondition.usefulTime.weekDayType = .everyDay
        timeCondition.usefulTime.beginTime = 0
        timeCondition.usefulTime.endTime = 1439
       
        
    }
    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return  deviceSensorList.count
        }
        return 1
        
    }
    
    
   
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if section == 0 {
           
            if macro.type == .openDoorLightOn || macro.type == .turnOnAc{
                return NSLocalizedString("Select door sencor, please", tableName: "MacroPage")
            }
            if macro.type == .comeLightOn || macro.type == .leaveLightOff{
                return NSLocalizedString("Select Infra-red sencor, please", tableName: "MacroPage")
            }
            
          
        }
    
        
        if macro.type == .openDoorLightOn{
            return  NSLocalizedString("Select effective time, please", tableName: "MacroPage")
        }
        return NSLocalizedString("Select delay time, please", tableName: "MacroPage")
        
    }

    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
        
    }
    

    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell:TopDeviceSelectedCell  = tableView.dequeueReusableCell(withIdentifier: "TopDeviceSelectedCell") as! TopDeviceSelectedCell
            let deviceAckInfo = deviceSensorList[indexPath.row]
            
            let placeName = " ("+deviceAckInfo.place+") "
            let attName = NSMutableAttributedString(string: deviceAckInfo.deviceName+placeName)
            attName.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, (deviceAckInfo.deviceName.utf16.count)))
            
            attName.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 11)], range: NSMakeRange(deviceAckInfo.deviceName.utf16.count, placeName.utf16.count))
            
            cell.textLabel?.attributedText = attName
            cell.setSelectBtn(deviceAckInfo.isSelected)
            cell.imageView?.image = deviceAckInfo.icon
            cell.selectionStyle = .none
            return cell
            
        }
        
        let cell:UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "")
        var str: String = NSLocalizedString("Duration", tableName: "MacroPage")
        if macro.type == .openDoorLightOn || macro.type == .comeLightOn{
            str = NSLocalizedString("Valid Time", tableName: "MacroPage")
        }
        let attText = NSMutableAttributedString(string: str)
         attText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, str.utf16.count))
        cell.textLabel?.attributedText = attText
        cell.imageView?.image = UIImage(named: "scene_time")
        
        
        var detailStr: String = "00:00 - 23:59"
        if (macro.type == .openDoorLightOn) || (macro.type == .comeLightOn) {
            detailStr = (timeCondition.usefulTime.beginTimeStr)!+" - "+(timeCondition.usefulTime.endTimeStr)!
        }else{
            detailStr = GlobarMethod.getTimeStr(withMin: Int(delayTime))
        }
        
        let detailText = NSMutableAttributedString(string: detailStr)
        detailText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 13)], range: NSMakeRange(0, detailStr.utf16.count))
        cell.detailTextLabel?.attributedText = detailText
        
        cell.accessoryType = .disclosureIndicator
        
        
        return cell
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if selectedIndexPath == indexPath {
                return
            }
            let device = deviceSensorList[indexPath.row]
            
            if device.isSelected == true {
                selectedDevice(device, indexPath: indexPath)
                return
            }
            
            if device.mainType == .slave {
                if device.md5 != SGlobalVars.curHomeInfo.ctrlCenter {
                    let deviceAckInfoList = TopDataManager.shared.resetDeviceInfo()
                    var glDeviceInfo: TopDeviceAckInfo?
                    for deviceAckInfo in deviceAckInfoList {
                        if deviceAckInfo.mainType == .geeklink {
                            if deviceAckInfo.md5 ==  device.md5 {
                                glDeviceInfo = deviceAckInfo
                                break
                            }
                        }
                    }
                    
                    if glDeviceInfo != nil {
                        
                        let alert = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Please make sure that the  %@'s host (%@) is in the same Wi-Fi LAN as the home host(%@).", tableName:"HomePage"), device.deviceName ,(glDeviceInfo?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                        
                        //设置动作
                        
                        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
                            (UIAlertAction) -> Void in
                            self.selectedDevice(device, indexPath: indexPath)
                        })
                        //显示弹窗
                        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                        alert.addAction(cancel)
                        alert.addAction(ok)
                        present(alert, animated: true, completion: nil)
                        
                        return
                    }
                    
                }
            } else if  device.mainType == .geeklink {
                
                let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message:  String.init(format: NSLocalizedString("Make sure %@ and the home host (%@) is connect to same network", tableName: "MacroPage"), device.deviceName, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    self.selectedDevice(device, indexPath: indexPath)
                    
                })
                
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
                return
            }
            self.selectedDevice(device, indexPath: indexPath)
        }
        
        if (macro.type == .openDoorLightOn) ||
            (macro.type == .comeLightOn) {
            let effectiveTimePickerView = TopEffectiveTimePickerView(frame: (UIApplication.shared.keyWindow?.bounds)!)
            effectiveTimePickerView.beginTime = timeCondition.usefulTime.beginTime
            effectiveTimePickerView.endTime = timeCondition.usefulTime.endTime
            effectiveTimePickerView.delegate = self
            effectiveTimePickerView.show()
            
        } else {
           
            let showPickerView = PickerView(frame: (UIApplication.shared.keyWindow?.bounds)!, time: (delayTime), showOnlyValidDates: true, type: .only30Mini)
            self.showPickerView = showPickerView
            
            showPickerView.showInWindow { [unowned self] (time) in
                self.delayTime = time
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
            }
        }
    }
    
    func selectedDevice (_ device: TopDeviceAckInfo, indexPath: IndexPath) -> Void {
        device.isSelected = !device.isSelected
        //            let predevice = deviceSensorList[selectedIndexPath.row]
        //            predevice.isSelected = false
        self.tableView.reloadRows(at: [indexPath, selectedIndexPath], with: .none)
        selectedIndexPath = indexPath
        return
    }
    
    func effectiveTimePickerViewSlected(_ beginTime: Int32, endTime: Int32) {
        timeCondition.usefulTime.beginTime = (beginTime)
        timeCondition.usefulTime.endTime = endTime
        
         self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
    }
    
}
