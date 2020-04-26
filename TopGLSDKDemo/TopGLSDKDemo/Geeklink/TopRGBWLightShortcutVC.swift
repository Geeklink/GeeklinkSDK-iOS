//
//  TopRGBWLightShortcutVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/29.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit
import IntentsUI

@available(iOS 12.0, *)

class TopRGBWLightShortcutVC: TopSuperVC, AMColorPickerWheelViewDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    var deviceStateCtrlResp: NSObjectProtocol!
    var deviceStateChangeResp: NSObjectProtocol!
    var task: TopTask!
    var deviceInfo: GLDeviceInfo!
    var addVoiceShortcutVC :INUIAddVoiceShortcutViewController!
    @IBOutlet weak var colorPickerView: AMColorPickerWheelView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.task = TopDataManager.shared.task
        self.title = self.task.device?.deviceName
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem.init(title: NSLocalizedString("Next", comment:""), style: UIBarButtonItem.Style.done, target: self, action: #selector(rightBarButtonItemDidClicked))
        colorPickerView.delegate = self
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func resetColorPickView() -> Void {
        let stateInfo: GLColorBulbState = (SGlobalVars.actionHandle.getColorBulbActionInfo(task.value))!
        let lightMode = TopLightMode()
        lightMode.isOn = stateInfo.onOff
        lightMode.mode = stateInfo.mode
        lightMode.white = stateInfo.white
        lightMode.brightness = stateInfo.brightness
        lightMode.color = UIColor.init(r: CGFloat(stateInfo.red), g: CGFloat(stateInfo.green), b: CGFloat(stateInfo.blue), alpha: 1)
        lightMode.mode = stateInfo.mode
        self.colorPickerView.resetSubViewsStateWithMode(mode: lightMode)
    }
    
    @objc func rightBarButtonItemDidClicked() -> Void {
        let colormode: TopLightMode = colorPickerView.currentMode
        let rbg = colormode.color.getRGB()
        let state = GLColorBulbState(onOff: colormode.isOn,
                                     mode: colormode.mode,
                                     white: colormode.white,
                                     red: Int32(rbg.0),
                                     green: Int32(rbg.1),
                                     blue: Int32(rbg.2),
                                     brightness: colormode.brightness)
        
        task.value = SGlobalVars.actionHandle.getColorBulbActionValue(state)
       
//        if #available(iOS 12.0, *) {
        
            let intent  = TopIntent()
            //intent.homeId = Globa
            
            intent.homeID = TopDataManager.shared.homeId
            intent.iD = String.init(format: "%d", (task.device?.deviceId)!)
            intent.action = task.value
            let remarks = task.operationName.string
            intent.oem = String.init(format: "%d", Int(App_Company.rawValue))
            intent.remarks = remarks.replacingOccurrences(of: ":●", with: "")
            intent.type = "device"
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
           
        }
        self.resetColorPickView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //移除设备控制监听
        NotificationCenter.default.removeObserver(deviceStateCtrlResp as Any)
        //移除设备状态变化监听
        NotificationCenter.default.removeObserver(deviceStateChangeResp as Any)
    }
    
    func colorPickerWheelView(colorPickerWheelView: AMColorPickerWheelView, didSelect colormode: TopLightMode) {
        
        let rbg = colormode.color.getRGB()
        let state = GLColorBulbState(onOff: colormode.isOn,
                                     mode: colormode.mode,
                                     white: colormode.white,
                                     red: Int32(rbg.0),
                                     green: Int32(rbg.1),
                                     blue: Int32(rbg.2),
                                     brightness: colormode.brightness);
        
        if SGlobalVars.singleHandle.colorBulbCtrl(SGlobalVars.curHomeInfo.homeId, deviceId: self.deviceInfo.deviceId, state: state) == 0 {
            self.processTimerStop()
        } else {
            GlobarMethod.notifyNetworkError()
        }
         colorPickerWheelView.resetSubViewsStateWithMode(mode: colormode)
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
