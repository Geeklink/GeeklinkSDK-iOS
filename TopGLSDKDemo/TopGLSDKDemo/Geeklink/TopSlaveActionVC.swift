//
//  TopSlaveActionVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/7/13.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopSlaveActionVC: TopSuperVC, TopACPanelCodeViewDelegate {
    
    
    var homeInfo = GLHomeInfo()
    var roomInfo = GLRoomInfo()
    var deviceInfo = GLDeviceInfo()
    var acPanelStateInfo: GLAcPanelStateInfo?
    
   
    var ratio: CGFloat = 1
    
    weak var acPanelCodeView : TopACPanelCodeView?
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
            let acPanelCodeView = TopACPanelCodeView(frame: self.view.frame)
            self.acPanelCodeView = acPanelCodeView
            acPanelCodeView.delegate = self
            acPanelCodeView.refreshState(deviceInfo.deviceId)
            acPanelStateInfo = SGlobalVars.slaveHandle.getAcPanelState(SGlobalVars.curHomeInfo.homeId, deviceIdSub: (deviceInfo.deviceId)) as GLAcPanelStateInfo
            self.view.addSubview(acPanelCodeView)
            
        default:
            break
            
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveAction))
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.refreshSubViewFrame(self.view.frame.size)
    }
    func refreshSubViewFrame(_ size: CGSize) -> Void {
         var width = size.height * ratio
        if width > size.width {
            width = size.width
        }
        let topBarHeight = (navigationController?.navigationBar.bounds.size.height)!
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
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAddTaskVC.classForCoder()) {
                let theVC: TopAddTaskVC = vc as! TopAddTaskVC
                theVC.addTask(task: task)
                navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
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
    
//    func setNewQuickInfo(_ key: Int8) {
//        let newInfo = GLDeviceQuickInfo(quickId: quickInfo.quickId, order: quickInfo.order, key: Int32(key))
//        SGlobalVars.rcHandle.roomDeviceQuickSet(homeInfo.homeId, deviceId: deviceInfo.deviceId, action: quickInfo.key == 0 ? .insert:.update, deviceQuickInfo: newInfo)
//        navigationController?.popViewController(animated: true)
//    }
    
    
}
