//
//  TopRCShortcutVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/28.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
import IntentsUI

@available(iOS 12.0, *)

class TopRCShortcutVC:  TopSuperVC, TopCodeViewDelegate,   TopSpecialActionViewDelegate,TVSTBNumberViewDelegate, INUIAddVoiceShortcutViewControllerDelegate,      TopACCodeViewDelegate {
 
   
    weak var tVSTBNumberView: TopTVSTBNumberView?
    var selectKeyType: GLKeyType = .CTLSWITCH
    var homeInfo = GLHomeInfo()//必须填
    var keyList = [GLKeyInfo]()
    private weak var viewAC: TopACCodeView?
    private weak var stbCodeView: TopSTBCodeView?
    private weak var tvCodeView: TopTVCodeView?
    private weak var iptvCodeView: TopIPTVCodeView?
    private weak var projectorCodeView: TopProjectorCodeView?
    private weak var fanCodeView: TopFANCodeView?
    private weak var voiceBoxCodeView: TopVoiceBoxCodeView?
    private weak var acFanCodeView: TopACFanCodeView?
    private weak var airCleanCodeView: TopAirCleanCodeView?
 
    private weak var customSpecialView: TopCustomSpecialView?
    private weak var specialActionView: TopSpecialActionView?
   
    private var ratio: CGFloat = 1
    
    var addVoiceShortcutVC :INUIAddVoiceShortcutViewController!
    var deviceInfo = GLDeviceInfo()//必须填
    var oldActionInfo = GLActionInfo()//修改时需要填, 添加时不需要填
    
    var tempStateInfo = GLDbAcCtrlInfo(powerState: 0,
                                       mode: 0,
                                       temperature: 24,
                                       speed: 0,
                                       direction: 0)
    
    
  
    @objc func reloadKeyList() {
        keyList = SGlobalVars.rcHandle.getKeyList(homeInfo.homeId, deviceId: deviceInfo.deviceId) as! [GLKeyInfo]
        
    }
    
    func addOrStudyKey(_ keyType: GLKeyType, view: UIView) -> Void {
        selectKeyType = keyType
        for theKey in self.keyList {
            if theKey.keyId == Int32(keyType.rawValue) + 1{
                let value = SGlobalVars.actionHandle.getRCValueString(Int8(theKey.keyId))
                addShorkcut(value: value!)
                return
            }
        }
        if SGlobalVars.homeHandle.getHomeAdminIsMe(homeInfo.homeId) == false {
            self.alertMessage(NSLocalizedString("The key is not recode code, please ask the administrator to learn the key before it can be used.", comment: ""), withTitle: NSLocalizedString("Hint", comment: ""))
            return
        }
        showStudyAlert(keyType, view: view)
    }
    
    func showStudyAlert(_ keyType: GLKeyType, view: UIView) -> Void {
        let stateInfo = SGlobalVars.slaveHandle.getSlaveState(SGlobalVars.curHomeInfo.homeId, deviceIdSub: deviceInfo.deviceId)!
        
        
        let hostStateInfo = SGlobalVars.deviceHandle.getGLDeviceStateInfo(SGlobalVars.curHomeInfo.homeId, deviceId: stateInfo.hostDeviceId)!
        
        switch hostStateInfo.state {
        case .local:
            break
        case .offline :
            
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Device isn't Connected", comment: ""))
            return
            
        default:
            //self.alertMessage(NSLocalizedString("If you want to do button learning, you need to do it under the LAN.", comment: ""), withTitle: NSLocalizedString("Unlearned key", comment: ""))
            break
        }
        
        var message = NSLocalizedString("The key is not valid, whether to record or create code immediately?", tableName: "RoomDevice")
        if hostStateInfo.type == .smartPi {
            message = NSLocalizedString("The key is not valid, whether to record code immediately?", tableName: "RoomDevice")
        }
        let alert = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: message, preferredStyle: .actionSheet)
        
        //动作取消
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        
        
        let create = UIAlertAction(title: NSLocalizedString("Create new code",  tableName: "RoomDevice"), style: .default) { (action) in
            self.showCreateKeyAlert(keyType , view: view)
            
        }
        
        let recordRC = UIAlertAction(title: NSLocalizedString("Record entity RC button", tableName: "RoomDevice"), style: .default) { (action) in
            self.studyKey(keyType)
            
        }
        
        
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        
        
        alert.addAction(cancel)
        if hostStateInfo.type != .smartPi {
            alert.addAction(create)
        }
        
        alert.addAction(recordRC)
        present(alert, animated: true, completion: nil)
        
    }
    func showCreateKeyAlert(_ keyType: GLKeyType, view: UIView) -> Void {
        let keyId: Int32 =  Int32(keyType.rawValue) + 1
        let alert = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: NSLocalizedString("The key is not valid, whether to record or create code immediately?", tableName: "RoomDevice"), preferredStyle: .actionSheet)
        
        //动作取消
        let customType = (GLCustomType.init(rawValue: Int(deviceInfo.subType)))!
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let actionRf315m = UIAlertAction(title: NSLocalizedString("RF315M", tableName: "RoomDevice"), style: .default, handler: {
            (action) -> Void in
            let data = SGlobalVars.rcHandle.createCode(.rf315m);
            let info = GLKeyInfo(keyId: keyId, studyType: 1, order: 0, icon: keyType, name: GlobarMethod.getKeyTypeName(keyType, andCustomType: customType))
            
            
            if SGlobalVars.rcHandle.thinkerKeySetReq(self.homeInfo.homeId, deviceIdSub: self.deviceInfo.deviceId, action: .insert, keyInfo: info, data: data) == 0 {
                self.processTimerStart(3.0)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        })
        alert.addAction(actionRf315m)
        
        
        let actionRf433m = UIAlertAction(title: NSLocalizedString("RF433M", tableName: "RoomDevice"), style: .default, handler: {
            (action) -> Void in
            let data = SGlobalVars.rcHandle.createCode(.rf433m);
            let info = GLKeyInfo(keyId: keyId, studyType: 2, order: 0, icon: keyType, name: GlobarMethod.getKeyTypeName(keyType, andCustomType: customType))
            
            
            if SGlobalVars.rcHandle.thinkerKeySetReq(self.homeInfo.homeId, deviceIdSub: self.deviceInfo.deviceId, action: .insert, keyInfo: info, data: data) == 0 {
                self.processTimerStart(3.0)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        })
        alert.addAction(actionRf433m)
        
        
        
        let actionLivo = UIAlertAction(title: NSLocalizedString("Livo Switch", tableName: "RoomDevice"), style: .default, handler: {
            (action) -> Void in
            let data = SGlobalVars.rcHandle.createCode(.livo);
            
            let info = GLKeyInfo(keyId: keyId, studyType: 1, order: 0, icon: keyType, name: GlobarMethod.getKeyTypeName(keyType, andCustomType: customType))
            
            if SGlobalVars.rcHandle.thinkerKeySetReq(self.homeInfo.homeId, deviceIdSub: self.deviceInfo.deviceId, action: .insert, keyInfo: info, data: data) == 0 {
                self.processTimerStart(3.0)
            } else {
                GlobarMethod.notifyNetworkError()
            }
        })
        alert.addAction(actionLivo)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
  
    
    func studyKey(_ keyType: GLKeyType) -> Void {
        let customType = (GLCustomType.init(rawValue: Int(deviceInfo.subType)))!
        let keyId: Int32 =  Int32(keyType.rawValue) + 1
        let action: GLActionFullType =  .insert
        let keyInfo = GLKeyInfo(keyId:keyId, studyType: 1, order: 0, icon: keyType, name: GlobarMethod.getKeyTypeName(keyType, andCustomType: customType))
        TopStudyKeyTool.share().studyKey(deviceInfo, keyInfo: keyInfo!, action: action)
        
    }
    
    @objc func thinkerKeySetResp(_ notification: NSNotification) -> Void {
        processTimerStop()
        GlobarMethod.notifySuccess()
        let ackInfo = notification.object as! TopSlaveAckInfo
        if ackInfo.subDeviceId == self.deviceInfo.deviceId {
            keyList = SGlobalVars.rcHandle.getKeyList(homeInfo.homeId, deviceId: deviceInfo.deviceId) as! [GLKeyInfo]
            for theKey in self.keyList {
                if theKey.keyId == Int32(selectKeyType.rawValue) + 1{
                    let value = SGlobalVars.actionHandle.getRCValueString(Int8(theKey.keyId))
                    addShorkcut(value: value!)
                    break
                }
            }
        }
        
    }
    // MARK: - 代理实现
    
    func acRcCodeViewStateKey(_ dbAirKeyType: GLDbAirKeyType, with keyType: GLKeyType, with view: UIView!) {
        if deviceInfo.mainType == .custom {
            self.addOrStudyKey(keyType, view: view)
            return
        }
        
    }
   
    
    func projectorCodeViewDelegate(_ keyType: GLKeyType, databaceType: GLDbIptvKeyType, view: UIView) {
        if deviceInfo.mainType == .custom {
            self.addOrStudyKey(keyType, view: view)
            return
        }
    }
     func customSpecialViewDidClickedBtn(_ keyType: GLKeyType, view: UIView) {
        if deviceInfo.mainType == .custom {
            self.addOrStudyKey(keyType, view: view)
            return
        }
    }
    
    func acFanCodeViewDidclickedBtn(_ keyType: GLKeyType, btn: UIButton) {
         self.addOrStudyKey(keyType, view: btn)
    }
    func airCleanCodeViewDidclickedBtn(_ keyType: GLKeyType, btn: UIButton) {
         self.addOrStudyKey(keyType, view: btn)
    }
    func codeView(_ keyType: GLKeyType, key: Int8, view: UIView) {
        if key == 127 {
            self.showNumberView()
            return
        }
        
        if deviceInfo.mainType == .custom {
            self.addOrStudyKey(keyType, view: view)
            return
        }
        let value = SGlobalVars.actionHandle.getRCValueString(key)
        addShorkcut(value: value!)
    }
    
   
    
    func voiceBoxCodeViewDidClickedBtn(_ keyType: GLKeyType, view: UIView) {
        if deviceInfo.mainType == .custom {
           self.addOrStudyKey(keyType, view: view)
        }
    }
    
    func fANCodeViewDidclickedBtn(_ keyType: GLKeyType, btn: UIButton) {
        if deviceInfo.mainType == .custom {
           self.addOrStudyKey(keyType, view: btn)
        }
    }
    func oneKeyCodeViewDidClickedBtn(_ keyType: GLKeyType, btn: UIButton) {
        self.addOrStudyKey(keyType, view: btn)
    }
    
    func ACRcCodeViewStateChange(stateInfo: GLRcStateInfo, keyType: GLDbAirKeyType, view: UIView) {
        var speed = stateInfo.acSpeed
        var power = stateInfo.acPowerState
        var dir = stateInfo.acDirection
        var mode = stateInfo.acMode
        var temp = stateInfo.acTemperature
        
        switch keyType {
        case .AIRMODE:
            mode += 1
            if mode > 4 {
                mode = 0
            }
        case .AIRSWITCH:
            power += 1
            if power > 1 {
                power = 0
            }
        case .AIRWINSPEED:
            speed += 1
            if speed > 3 {
                speed = 0
            }
        case .AIRWINDIR:
            dir += 1
            if dir > 3 {
                dir = 0
            }
        case .AIRTEMPPLUS:
            temp += 1
            if temp > 30 {
                temp = 30
            }
        case .AIRTEMPMINUS:
            temp -= 1
            if temp < 16 {
                temp = 16
            }
        case .count:
            break
        @unknown default:
            break
        }
        let rcStateInfo = GLRcStateInfo.init(hostDeviceId: stateInfo.hostDeviceId, online: stateInfo.online, ctrlId: stateInfo.ctrlId, fileId: stateInfo.fileId, carrier: stateInfo.carrier, acPowerState: power, acMode: mode, acTemperature: temp, acSpeed: speed, acDirection: dir, socketMD5: stateInfo.socketMD5)
        self.tempStateInfo = GLDbAcCtrlInfo(powerState: power,
                                            mode: mode,
                                            temperature: temp,
                                            speed: speed,
                                            direction: dir)
        viewAC?.stateInfo = rcStateInfo!
    }
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置文本
        title = deviceInfo.name
        
        if view.size.width > view.size.height {
            ratio = view.size.height / view.size.width
        }else {
            ratio = view.size.width / view.size.height
        }
        initSubViews()
       
        
    }
    
    func initSubViews() -> Void {
        if deviceInfo.mainType ==  .database{
            let databaseType = GLDatabaseType(rawValue: Int(deviceInfo.subType))!
            
            switch databaseType {
            case .AC:
                
                let viewAC = TopACCodeView()
                viewAC.delegate = self
                self.viewAC = viewAC
                let stateInfo = SGlobalVars.rcHandle.getRcState(homeInfo.homeId, deviceIdSub: deviceInfo.deviceId) as GLRcStateInfo
                viewAC.stateInfo = stateInfo
                self.view.addSubview(viewAC)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Next", comment: ""), style: .done, target: self, action: #selector(onClickSaveButton))
               
            case .TV:
                
                let tvCodeView = TopTVCodeView()
                self.tvCodeView = tvCodeView
                tvCodeView.hideChannelBtn(true)
                tvCodeView.delegate = self
                self.view.addSubview(tvCodeView)
                
            case .STB:
                
                let stbCodeView = TopSTBCodeView()
                stbCodeView.delegate = self
                self.stbCodeView = stbCodeView
                stbCodeView.hideChannelBtn(true)
                self.view.addSubview(stbCodeView)
                
            case .IPTV:
                
                let iptvCodeView = TopIPTVCodeView()
                self.iptvCodeView = iptvCodeView
                iptvCodeView.delegate = self
                view.addSubview(iptvCodeView)
            default:
                break
            }
        }else if deviceInfo.mainType == .custom{
            let customType = GLCustomType(rawValue: Int(deviceInfo.subType))!
            
            switch customType {
            case .IPTV:
                
                let iptvCodeView = TopIPTVCodeView()
                iptvCodeView.delegate = self
                self.iptvCodeView = iptvCodeView
                view.addSubview(iptvCodeView)
            case .projector:
                
                let projectorCodeView = TopProjectorCodeView()
                projectorCodeView.delegate = self
                self.projectorCodeView = projectorCodeView
                self.view.addSubview(projectorCodeView)
            case .TV:
                
                let tvCodeView = TopTVCodeView()
                self.tvCodeView = tvCodeView
                tvCodeView.hideChannelBtn(true)
                tvCodeView.delegate = self
                self.view.addSubview(tvCodeView)
            case .STB:
                
                let stbCodeView = TopSTBCodeView()
                self.stbCodeView = stbCodeView
                stbCodeView.delegate = self
                stbCodeView.hideChannelBtn(true)
                self.view.addSubview(stbCodeView)
                
            case .fan:
                
                
                let fanCodeView = TopFANCodeView()
                fanCodeView.delegate = self
                self.fanCodeView = fanCodeView
                self.view.addSubview(fanCodeView)
            case .soundbox:
                
                
                
                let voiceBoxCodeView = TopVoiceBoxCodeView()
                voiceBoxCodeView.delegate = self
                self.voiceBoxCodeView = voiceBoxCodeView
                self.view.addSubview(voiceBoxCodeView)
            case .acFan:
                
                let acFanCodeView = TopACFanCodeView()
                self.acFanCodeView = acFanCodeView
                acFanCodeView.delegate = self
                self.view.addSubview(acFanCodeView)
            case .airPurifier:
                
                let airCleanCodeView = TopAirCleanCodeView()
                self.airCleanCodeView = airCleanCodeView
                airCleanCodeView.delegate = self
                self.view.addSubview(airCleanCodeView)
          
                
            case .curtain, .rcLight, .oneKey:
                
                let customSpecialView = TopCustomSpecialView()
                self.customSpecialView = customSpecialView
                customSpecialView.delegate = self
                customSpecialView.deviceInfo = deviceInfo
                self.view.addSubview(customSpecialView)
                
            default:
                break
            }
        }else if deviceInfo.mainType == .geeklink{
            let glType: GLGlDevType = GLGlDevType(rawValue: Int(deviceInfo.subType))!
            switch glType {
                
            case .plug, .plugPower, .plugFour:
                
                let specialActionView = TopSpecialActionView()
                self.specialActionView = specialActionView
                specialActionView.deviceInfo = deviceInfo
                specialActionView.delegate = self
                self.view.addSubview(specialActionView)
                
            default:
                break
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.refreshSubViewFrame(self.view.frame.size)
    }
    func refreshSubViewFrame(_ size: CGSize) -> Void {
       
        if self.tVSTBNumberView != nil {
            self.tVSTBNumberView?.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        }
         var width = size.height * ratio
        if width > size.width {
            width = size.width
        }
        let topBarHeight = (navigationController?.navigationBar.bounds.size.height)!
        let frame = CGRect.init(x: (size.width - width) * 0.5, y: 0, width: width, height: size.height - topBarHeight)
        
        if viewAC != nil {
            
            viewAC?.frame = frame
            return
        }
        if stbCodeView != nil {
            
            stbCodeView?.frame = frame
            return
        }
        if iptvCodeView != nil {
            
            iptvCodeView?.frame = frame
            return
        }
        if projectorCodeView != nil {
            
            projectorCodeView?.frame = frame
            return
        }
        if tvCodeView != nil {
            tvCodeView?.frame = frame
            return
        }
        if fanCodeView != nil {
            fanCodeView?.frame = frame
            return
        }
        if voiceBoxCodeView != nil {
            voiceBoxCodeView?.frame = frame
            return
        }
        if acFanCodeView != nil {
            acFanCodeView?.frame = frame
            return
        }
        if airCleanCodeView != nil {
            airCleanCodeView?.frame = frame
            return
        }
        
      
        if customSpecialView != nil {
            customSpecialView?.frame = frame
            return
        }
        if specialActionView != nil {
            specialActionView?.frame = frame
            return
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadKeyList), name:NSNotification.Name("thinkerKeyGetResp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(thinkerKeySetResp), name:NSNotification.Name("thinkerKeySetResp"), object: nil)
        //刷新数据
        getRefreshData()
        reloadKeyList()
        
    }
    
    func showNumberView() -> Void {
        
        let tVSTBNumberView = TopTVSTBNumberView(frame: UIScreen.main.bounds)
        self.tVSTBNumberView = tVSTBNumberView
        tVSTBNumberView.delegate = self
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.fromValue = NSValue(caTransform3D: CATransform3DMakeScale(0, 0, 1))
        scaleAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeScale(1, 1, 1))
        
        scaleAnimation.duration = 0.2;
        scaleAnimation.isCumulative = false;
        scaleAnimation.repeatCount = 1;
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        
        tVSTBNumberView.layer.add(scaleAnimation, forKey: "myScale")
        
        self.view.addSubview(tVSTBNumberView)
    }
    
    override func getRefreshData() {
        SGlobalVars.rcHandle.thinkerKeyGetReq(homeInfo.homeId, deviceIdSub: deviceInfo.deviceId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //移除监听
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("thinkerKeyGetResp"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("thinkerKeySetResp"), object: nil)
        TopStudyKeyTool.share().stopStudy()
        
    }
    
    // MARK: - Local
    
    @objc func onClickSaveButton() {
        let value = SGlobalVars.actionHandle.getDBACValueString(tempStateInfo)
        
        addShorkcut(value: value!)
    }
    
    func addShorkcut(value: String) {
        let task: TopTask  = TopDataManager.shared.task!
        task.value = value
        
        
//        if #available(iOS 12.0, *) {
        
            let intent  = TopIntent()
            //intent.homeId = Globa
            
            intent.homeID = TopDataManager.shared.homeId
            intent.iD = String.init(format: "%d", (task.device?.deviceId)!)
            intent.action = value
            intent.remarks = task.operationName.string
            intent.type = "device"
              intent.oem = String.init(format: "%d", Int(App_Company.rawValue))
            intent.md5 = task.device?.md5
            intent.subId = String.init(format: "%d", (task.device?.subId)!)
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
    
    
    func specialActionViewDidClickedBtn(_ index: Int32) {
        
        if deviceInfo.mainType == .geeklink{
            let glType: GLGlDevType = GLGlDevType(rawValue: Int(deviceInfo.subType))!
            switch glType {
                
            case .plug, .plugPower, .plugFour:
                if index == 0 {
                    self.addShorkcut(value: "11")
                }else {
                    self.addShorkcut(value: "10")
                }
                
            default:
                break
            }
        }
    }
    func iPTVCodeViewDelegate(_ keyType: GLKeyType, databaceType: GLDbIptvKeyType, view: UIView) {
        if deviceInfo.mainType == .custom {
            self.addOrStudyKey(keyType, view: view)
            return
        }
        let value = SGlobalVars.actionHandle.getRCValueString(Int8(databaceType.rawValue))
        addShorkcut(value: value!)
        
    }
    
     func numberViewDidclickedBtn(_ index: Int, btn: UIButton) {
        
        if deviceInfo.mainType == .database {
            self.addDatabaseNumberKey(index, view: btn)
        }else {
            self.addCustomNumberKey(index, view: btn)
        }
        
    }
    func addCustomNumberKey(_ index: Int, view: UIView) -> Void{
        var tvTypeList = [GLKeyType]()
        tvTypeList.append(.CTL1)
        tvTypeList.append(.CTL2)
        tvTypeList.append(.CTL3)
        tvTypeList.append(.CTL4)
        tvTypeList.append(.CTL5)
        tvTypeList.append(.CTL6)
        tvTypeList.append(.CTL7)
        tvTypeList.append(.CTL8)
        tvTypeList.append(.CTL9)
        tvTypeList.append(.CTL0)
        self.addOrStudyKey(tvTypeList[index], view: view)
    }
    
    func addDatabaseNumberKey(_ index: Int, view: UIView) -> Void {
        let databaseType = GLDatabaseType(rawValue: Int(deviceInfo.subType))!
        if databaseType == .TV {
            var tvTypeList = [GLDbTvKeyType]()
            tvTypeList.append(.TV1)
            tvTypeList.append(.TV2)
            tvTypeList.append(.TV3)
            tvTypeList.append(.TV4)
            tvTypeList.append(.TV5)
            tvTypeList.append(.TV6)
            tvTypeList.append(.TV7)
            tvTypeList.append(.TV8)
            tvTypeList.append(.TV9)
            tvTypeList.append(.TV0)
            
            let value = SGlobalVars.actionHandle.getRCValueString(Int8(tvTypeList[index].rawValue))
            addShorkcut(value: value!)
            
            
            
            
            
        } else {
            var stbTypeList = Array<GLDbStbKeyType>()
            stbTypeList.append(.STB1)
            stbTypeList.append(.STB2)
            stbTypeList.append(.STB3)
            stbTypeList.append(.STB4)
            stbTypeList.append(.STB5)
            stbTypeList.append(.STB6)
            stbTypeList.append(.STB7)
            stbTypeList.append(.STB8)
            stbTypeList.append(.STB9)
            stbTypeList.append(.STB0)
            
            let value = SGlobalVars.actionHandle.getRCValueString(Int8(stbTypeList[index].rawValue))
            addShorkcut(value: value!)
        }
    }
    
    
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
