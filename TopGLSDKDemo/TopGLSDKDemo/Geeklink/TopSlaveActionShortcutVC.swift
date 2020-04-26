//
//  TopSlaveActionShortcutVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/29.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
import IntentsUI
@available(iOS 12.0, *)
class TopSlaveActionShortcutVC: TopSuperVC, TopACPanelCodeViewDelegate, INUIAddVoiceShortcutViewControllerDelegate {
 
    
    
    var homeInfo = GLHomeInfo()
    var roomInfo = GLRoomInfo()
    var deviceInfo = GLDeviceInfo()
    var acPanelStateInfo: GLAcPanelStateInfo?
    var addVoiceShortcutVC :INUIAddVoiceShortcutViewController!
    weak var acPanelCodeView : TopACPanelCodeView?
    
    var currentWidth: CGFloat = 0
    var ratio: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = deviceInfo.name
        
        if view.size.width > view.size.height {
            ratio = view.size.height / view.size.width
        }else {
            ratio = view.size.width / view.size.height
        }
       
        let slaveType = SGlobalVars.roomHandle.getSlaveType(deviceInfo.subType)
        
        switch slaveType {
        case .airConPanel:
            
            
            let acPanelCodeView = TopACPanelCodeView()
            self.acPanelCodeView = acPanelCodeView
            acPanelCodeView.delegate = self
            acPanelCodeView.refreshState(deviceInfo.deviceId)
            acPanelStateInfo = SGlobalVars.slaveHandle.getAcPanelState(SGlobalVars.curHomeInfo.homeId, deviceIdSub: (deviceInfo.deviceId)) as GLAcPanelStateInfo
            self.view.addSubview(acPanelCodeView)
            
        default:
            break
            
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Next", comment:""), style: UIBarButtonItem.Style.done, target: self, action: #selector(saveAction))
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.refreshSubViewFrame(self.view.frame.size)
    }
    func refreshSubViewFrame(_ size: CGSize) -> Void {
        if currentWidth == self.view.width {
            return
        }
        currentWidth = self.view.width
        let topBarHeight = (navigationController?.navigationBar.bounds.size.height)!
         var width = size.height * ratio
        if width > size.width {
            width = size.width
        }
        let frame = CGRect.init(x: (size.width - width) * 0.5, y: topBarHeight, width: width, height: size.height - topBarHeight)
        if self.acPanelCodeView != nil {
            self.acPanelCodeView?.frame = frame
        }
    }
    
    @objc func saveAction() -> Void {
        let value = SGlobalVars.actionHandle.getAcPanelActionValue(acPanelStateInfo)
        setMacroAction(value: value!)
    }
    
    
    func setMacroAction(value: String) {
        let task: TopTask  = TopDataManager.shared.task!
        task.value = value
        
      
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
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        //增加监听
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceStateCtrlResp), name:NSNotification.Name("deviceStateCtrlResp"), object: nil)
        
    }
    
    @objc func deviceStateCtrlResp(notification: Notification) {//状态返回
        
        let ackInfo = notification.object as! TopDeviceAckInfo
        if ackInfo.deviceId == deviceInfo.deviceId &&
            ackInfo.homeId == homeInfo.homeId {
            
            processTimerStop()
            switch ackInfo.state {
            case .ok:
                GlobarMethod.notifySuccess()
            case .internetError:
                GlobarMethod.notifyDevInternetError()
            default:
                GlobarMethod.notifyFailed()
            }
        }
        if self.acPanelCodeView != nil {
            self.acPanelCodeView?.refreshState(deviceInfo.deviceId)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //移除监听
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("deviceStateCtrlResp"), object: nil)
    }
    
    
    func acPanelCodeViewDidSelect(_ keyType: GLKeyType) {
        let slaveType = SGlobalVars.roomHandle.getSlaveType(deviceInfo.subType)
        
        switch slaveType {
        case .airConPanel:
            chageACPanel(keyType)
            
        default:
            break
            
        }
        
        
    }
    
    func chageACPanel(_ keyType: GLKeyType)-> Void {
        
        if acPanelStateInfo == nil {
            acPanelStateInfo = GLAcPanelStateInfo()
        }
        var power: Bool = (acPanelStateInfo?.power)!
        var mode: Int8 = (acPanelStateInfo?.mode)!
        var speed: Int8 = (acPanelStateInfo?.speed)!
        let roomTem: Int8 = (acPanelStateInfo?.roomTemperature)!
        var tem: Int8 = (acPanelStateInfo?.temperature)!
        
        switch  keyType{
        case .CTLSWITCH:
            power = !power
        case .CTLMODE:
            mode += 1
            if mode >= 2{
                mode = 0
            }
        case .CTLWINDSPEED:
            speed += 1
            if speed >= 4{
                speed = 1
            }
        case .CTLUP:
            tem += 1
            if tem > 30{
                tem = 30
            }
        case .CTLDOWN:
            tem -= 1
            if tem < 16{
                tem = 16
            }
        default:
            break
        }
        acPanelStateInfo = GLAcPanelStateInfo(power: power, mode: mode, speed: speed, temperature: tem, roomTemperature: roomTem)
        acPanelCodeView?.refresStateWithAcPanelStateInfo(acPanelStateInfo!)
        
        
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
