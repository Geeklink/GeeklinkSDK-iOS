//
//  TopAKeyTaskSelectVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/5/7.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopDeviceTaskSelectVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gotoRoomBtn: UIButton!
    @IBOutlet weak var tipLabel: UILabel!
    var macro = TopDataManager.shared.macro
    var delayTime: Int32 = 0
    var deviceAndBtnList = Array<TopDeviceAndBtn>()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "TopDeviceSelectedCell", bundle: nil), forCellReuseIdentifier: "TopDeviceSelectedCell")
        
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItemDidClicked))
        saveItem.tintColor = APP_ThemeColor
        self.navigationItem.rightBarButtonItem = saveItem
        title = macro?.name
        
        
        initSubviews()
        
    }
    func initSubviews() -> Void {
        tipLabel.text = NSLocalizedString("No feedback switch, please go to the \"Room\" page to add.", tableName: "MacroPage")
        
        if macro?.type == .turnOnAc{
             tipLabel.text = NSLocalizedString("No AC, please go to the \"Room\" page to add.", tableName: "MacroPage")
        }
        
        self.gotoRoomBtn.layer.cornerRadius = 22
        self.gotoRoomBtn.clipsToBounds = true
        self.gotoRoomBtn.backgroundColor = APP_ThemeColor
        self.gotoRoomBtn.setTitle("Go to Room", for: .normal)
        self.gotoRoomBtn.addTarget(self, action: #selector(gotoRoomBtnDidClicked), for: .touchUpInside)
    }
    @objc func gotoRoomBtnDidClicked() -> Void {
        //
        self.tabBarController?.selectedIndex = 1
//        let time: TimeInterval = 0.1
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
//            //code
//           self.navigationController?.popToRootViewController(animated: true)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let macroSet = NSNotification.Name("macroSetResp")
        NotificationCenter.default.addObserver(self, selector: #selector(macroSetResp), name:macroSet, object: nil)
        if macro?.type == .turnOnAc{
            initAcDeviceAndBtnList()
        }else{
            initSwitchDeviceAndBtnList()
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let macroSetResp = NSNotification.Name("macroSetResp")
        NotificationCenter.default.removeObserver(self, name: macroSetResp, object: nil)
    }
    func getACTask() -> Array<TopTask> {
        var taskList = Array<TopTask>()
        let tempStateInfo = GLDbAcCtrlInfo(powerState: 1,
                                                    mode: 0,
                                                    temperature: 24,
                                                    speed: 0,
                                                    direction: 0)
        for deviceAndBtn in deviceAndBtnList{
            if deviceAndBtn.selected == true{
                let task = TopTask()
                task.device = deviceAndBtn.deviceAckInfo
                
                task.value = SGlobalVars.actionHandle.getDBACValueString(tempStateInfo)
                taskList.append(task)
                
            }
        }
        return taskList
    }
    func getSwitchTask() -> Array<TopTask> {
        var taskList = Array<TopTask>()
        for deviceAndBtn in deviceAndBtnList{
            if deviceAndBtn.selected == true{
                
                var task = TopTask()
                var contain: Bool = false
                var theSwitchCtrlInfo: GLSwitchCtrlInfo = GLSwitchCtrlInfo(rockBack: false, aCtrl: false, bCtrl: false, cCtrl: false, dCtrl: false, aOn: false, bOn: false, cOn: false, dOn: false)
                if taskList.count > 0 {
                    for containTask in taskList{
                        if containTask.device?.deviceId == deviceAndBtn.deviceAckInfo.deviceId {
                            task = containTask
                            theSwitchCtrlInfo = task.switchCtrlInfo
                            contain = true
                            break
                        }
                        
                    }
                }
                task.device = deviceAndBtn.deviceAckInfo
                var crtlList = [Bool]()
                crtlList.append(theSwitchCtrlInfo.aCtrl)
                crtlList.append(theSwitchCtrlInfo.bCtrl)
                crtlList.append(theSwitchCtrlInfo.cCtrl)
                crtlList.append(theSwitchCtrlInfo.dCtrl)
                
                var onList = [Bool]()
                onList.append(theSwitchCtrlInfo.aOn)
                onList.append(theSwitchCtrlInfo.bOn)
                onList.append(theSwitchCtrlInfo.cOn)
                onList.append(theSwitchCtrlInfo.dOn)
                
                crtlList[deviceAndBtn.btnIndex-1] = true
                if (macro?.type == .allOn) || (macro?.type == .openDoorLightOn) || (macro?.type == .comeLightOn) {
                    onList[deviceAndBtn.btnIndex-1] = true
                }else{
                    onList[deviceAndBtn.btnIndex-1] = false
                }
                
                let switchCtrlInfo: GLSwitchCtrlInfo = GLSwitchCtrlInfo(rockBack: false, aCtrl: crtlList[0], bCtrl: crtlList[1], cCtrl: crtlList[2], dCtrl: crtlList[3], aOn: onList[0], bOn: onList[1], cOn: onList[2], dOn: onList[3])
                task.delay = delayTime
                task.value = SGlobalVars.actionHandle.getFeedbackSwicthActionValue(switchCtrlInfo)
                if contain == false{
                     taskList.append(task)
                }
               
                
            }
        }
        return taskList
    }
    @objc func saveItemDidClicked() -> Void {
       
        let macro = TopDataManager.shared.macro
        if macro?.type == .turnOnAc{
            macro?.tasks = getACTask()
        }else{
            macro?.tasks = getSwitchTask()
        }
        if macro?.tasks.count == 0 {
            self.alertMessage(NSLocalizedString("Select at least one button.", tableName: "MacroPage"))
            return
        }
                                                                                                                 let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
        
        switch hostSubType {
        case .thinkerMini:
            if  (macro?.tasks.count)! > 16 {
                if macro?.type == .turnOnAc{
                    self.alertMessage(NSLocalizedString("Choose up to 16 air conditioners.", tableName: "MacroPage"), withTitle: NSLocalizedString("Hint", comment: ""))
                }else{
                    self.alertMessage(NSLocalizedString("Choose up to 16 Feedback Switches.", tableName: "MacroPage"), withTitle: NSLocalizedString("Hint", comment: ""))
                    macro?.tasks = getSwitchTask()
                }
                return
            }
        default:
            if  (macro?.tasks.count)! > 50 {
                if macro?.type == .turnOnAc{
                    self.alertMessage(NSLocalizedString("Choose up to 50 air conditioners.", tableName: "MacroPage"), withTitle: NSLocalizedString("Hint", comment: ""))
                }else{
                    self.alertMessage(NSLocalizedString("Choose up to 50 Feedback Switches.", tableName: "MacroPage"), withTitle: NSLocalizedString("Hint", comment: ""))
                    macro?.tasks = getSwitchTask()
                }
                return
            }
        }
       
        
        if SGlobalVars.macroHandle.macroSetReq(TopDataManager.shared.homeId, action:(TopDataManager.shared.macro?.action)!, macroFullInfo: TopDataManager.shared.macro?.macroFullInfo) == 0{
            processTimerStart(3.0)
        } else {
            GlobarMethod.notifyFailed()
        }
        
        
    }
    @objc func macroSetResp(notificatin: Notification) {//请求条件列表回复
        processTimerStop()
       
        let info = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            navigationController?.popToRootViewController(animated: true)
        }else if info.state == .fullError{
            GlobarMethod.notifyFullError()
        }
        else {
            GlobarMethod.notifyFailed()
        }
    }
    
    func initAcDeviceAndBtnList() -> Void {
        let deviceInfoList = TopDataManager.shared.resetDeviceInfo()
       
        let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
        
        for deviceAckInfo in deviceInfoList{
            if hostSubType == .thinkerMini {
                if deviceAckInfo.deviceInfo.md5 != TopDataManager.shared.hostDeviceInfo?.md5 {
                    continue
                }
            }
            if  (deviceAckInfo.deviceInfo.mainType == .database) || (deviceAckInfo.deviceInfo.mainType == .custom) {
                
                let databaseType = GLDatabaseType(rawValue: Int(deviceAckInfo.deviceInfo.subType))!
                
                if databaseType == .AC{
                    let deviceAndBtn = TopDeviceAndBtn()
                    deviceAndBtn.deviceAckInfo = deviceAckInfo
                    deviceAndBtnList.append(deviceAndBtn)
                }
                
            }
        }
        // deviceAndBtnList.removeAll()
        if deviceAndBtnList.count == 0{
            self.tableView.isHidden = true
            self.tipLabel.isHidden = false
            self.gotoRoomBtn.isHidden = false
            
        }else{
            self.tableView.isHidden = false
            self.tipLabel.isHidden = true
            self.gotoRoomBtn.isHidden = true
            
            
        }
        
    }
    func initSwitchDeviceAndBtnList() -> Void {
        let deviceInfoList = TopDataManager.shared.resetDeviceInfo()
        let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
        
        for deviceAckInfo in deviceInfoList{
            if hostSubType == .thinkerMini {
                if deviceAckInfo.deviceInfo.md5 != TopDataManager.shared.hostDeviceInfo?.md5 {
                    continue
                }
            }
            var switchCount: Int32 = 0
            if  deviceAckInfo.deviceInfo.mainType == .slave{
                
                if (deviceAckInfo.slaveType == .fb1Neutral1) ||
                    (deviceAckInfo.slaveType == .fb11) || (deviceAckInfo.slaveType == .feedbackSwitchWithScenario1) {
                    switchCount = 1
                } else if(deviceAckInfo.slaveType == .fb1Neutral2) ||
                    (deviceAckInfo.slaveType == .fb12) || (deviceAckInfo.slaveType == .feedbackSwitchWithScenario2){
                    switchCount = 2
                } else if(deviceAckInfo.slaveType == .fb1Neutral3) ||
                    (deviceAckInfo.slaveType == .fb13) || (deviceAckInfo.slaveType == .feedbackSwitchWithScenario3) {
                    switchCount = 3
                } else if (deviceAckInfo.slaveType == .ioModula) ||
                    (deviceAckInfo.slaveType == .ioModulaNeutral) {
                    switchCount = 4
                    
                }
                
               
                if switchCount > 0{
                    var index: Int = 1
                    while index <= switchCount{
                        let deviceAndBtn: TopDeviceAndBtn = TopDeviceAndBtn()
                        
                        deviceAndBtn.btnIndex = index
                        deviceAndBtn.deviceAckInfo = deviceAckInfo
                        deviceAndBtnList.append(deviceAndBtn)
                        index += 1
                        
                    }
                }
          }
            if deviceAckInfo.deviceInfo.mainType == .geeklink {
                var switchCount: Int32 = 0
                let glType = (GLGlDevType.init(rawValue: Int(deviceAckInfo.deviceInfo.subType)))!
                switch glType {
                case .feedbackSwitch1:
                    switchCount = 1
                case .feedbackSwitch2:
                    switchCount = 2
                case .feedbackSwitch3:
                    switchCount = 3
                case .feedbackSwitch4:
                    switchCount = 4
                default:
                    break
                }
                if switchCount > 0{
                    var index: Int = 1
                    while index <= switchCount{
                        let deviceAndBtn: TopDeviceAndBtn = TopDeviceAndBtn()
                        
                        deviceAndBtn.btnIndex = index
                        deviceAndBtn.deviceAckInfo = deviceAckInfo
                        deviceAndBtnList.append(deviceAndBtn)
                        index += 1
                        
                    }
                }
            }
          
            
       }
       // deviceAndBtnList.removeAll()
        if deviceAndBtnList.count == 0{
            self.tableView.isHidden = true
            self.tipLabel.isHidden = false
            self.gotoRoomBtn.isHidden = false
           
        }else{
            self.tableView.isHidden = false
            self.tipLabel.isHidden = true
            self.gotoRoomBtn.isHidden = true
            
            
        }

    }
    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
  
   
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return  deviceAndBtnList.count
    }
    
    
   
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
         let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
        switch hostSubType {
        case .thinkerMini:
            if macro?.type == .turnOnAc{
                return NSLocalizedString("Choose up to 16 air conditioners.", tableName: "MacroPage")
            }else{
                return NSLocalizedString("Choose up to 16 Feedback Switches.", tableName: "MacroPage")+"("+NSLocalizedString("A Feedback Switch may have A、B、C、D sub-switches.", tableName: "MacroPage")+")"
            }
        default:
            if macro?.type == .turnOnAc{
                return NSLocalizedString("Choose up to 50 air conditioners.", tableName: "MacroPage")
            }else{
                return NSLocalizedString("Choose up to 50 Feedback Switches.", tableName: "MacroPage")+"("+NSLocalizedString("A Feedback Switch may have A、B、C、D sub-switches.",tableName: "MacroPage")+")"
            }
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
        
    }
    
 
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TopDeviceSelectedCell  = tableView.dequeueReusableCell(withIdentifier: "TopDeviceSelectedCell") as! TopDeviceSelectedCell
        let deviceAndBtn = deviceAndBtnList[indexPath.row]
        
        if macro?.type == .turnOnAc{
            cell.textLabel?.attributedText = deviceAndBtn.attName
        }else{
            cell.textLabel?.attributedText = deviceAndBtn.attNameAndBtn
        }
        
        cell.setSelectBtn(deviceAndBtn.selected)
        cell.imageView?.image = deviceAndBtn.deviceAckInfo.icon
        cell.selectionStyle = .none
        return cell
        
        
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
       let deviceAndBtn = deviceAndBtnList[indexPath.row]
        if deviceAndBtn.deviceAckInfo.mainType == .geeklink {
            var isSelected = false
            for theDeviceAndBtn in deviceAndBtnList{
                if theDeviceAndBtn.selected == true && theDeviceAndBtn.deviceAckInfo.deviceId == deviceAndBtn.deviceAckInfo.deviceId{
                    isSelected = true
                }
            }
            if isSelected == false {
                let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message:  String.init(format: NSLocalizedString("Make sure the Central Wifi Feedback Switch(%@) and host is connect to same network", tableName: "MacroPage"), deviceAndBtn.deviceAckInfo.deviceName), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    deviceAndBtn.selected = !deviceAndBtn.selected
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
            }else {
                deviceAndBtn.selected = !deviceAndBtn.selected
                self.tableView.reloadRows(at: [indexPath], with: .none)
            }
         
        }else {
            deviceAndBtn.selected = !deviceAndBtn.selected
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    
        
        
    }
    
}
