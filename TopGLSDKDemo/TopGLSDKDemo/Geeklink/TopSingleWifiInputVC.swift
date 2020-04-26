//
//  TopSingleWifiInputVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/10/11.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
import SystemConfiguration

class TopSingleWifiInputVC: TopSuperVC, UITextFieldDelegate {
    
    // MARK: - var
    var type : TopGuideMainWifiType = .thinker
    var homeInfo = GLHomeInfo()
    var roomInfo: GLRoomInfo!
    var devType: Int!
    var isConfiging = false
    
    var tempMd5: String!
    
    var currentWifiName: String?
    var settingFlag = false
    var leaveFlag = false
    var tipStr = ""
    var viewOrginalY: CGFloat = 0.0
    
    var waitTime: Int32 = 0
    var progress :Int32 = 0
    
    
    var timer: Timer?
    var progressTimer: Timer?
    
    var textFieldBottomY: CGFloat = 0.0//输入框底部的屏幕高度
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var wifiBtn: UIButton!
    @IBOutlet weak var wifiTipLabel1: UILabel!
    @IBOutlet weak var wifiTipLabel2: UILabel!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var passWordTextField: UITextField!
    @IBOutlet weak var ssidLabel: UILabel!
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Set up work Wi-Fi",tableName: "GuideDevice")
        
        
        ssidLabel.text = NSLocalizedString("Unknown", comment: "")
        
        wifiTipLabel1.text = NSLocalizedString("Note: Device not supporting connection 5G Wi-Fi", tableName: "GuideDevice")
        wifiTipLabel2.text = NSLocalizedString("If the phone is currently connected to the 5G Wi-Fi, please switch to other 2.4G Wi-Fi", comment: "")
        
        sureBtn.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        sureBtn.backgroundColor = APP_ThemeColor
        wifiBtn.setTitle(NSLocalizedString("Change to other Wi-Fi", tableName: "GuideDevice"), for: .normal)
        wifiBtn.setTitleColor(APP_ThemeColor, for: .normal)
        
        passWordTextField.placeholder = NSLocalizedString("Input password", tableName: "GuideDevice")
        passWordTextField.addTarget(self, action: #selector(textFieldDidChangeText), for: .editingChanged)
        
        //隐藏键盘
        addHideKeyboard(view)
        
        //获取输入框底部的屏幕高度
        let tfRect = passWordTextField.convert(passWordTextField.bounds, to: view)
        textFieldBottomY += UIApplication.shared.statusBarFrame.size.height
        textFieldBottomY += (navigationController?.navigationBar.frame.size.height)!
        textFieldBottomY += tfRect.origin.y
        textFieldBottomY += tfRect.size.height
        
        
        //监听键盘边距变化
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSsidLblText()
        addTimer()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        leaveFlag = true
        self.removeProgressTimer()
        SGlobalVars.guideHandle.stopDiscoverDevice()
        removeTimer()
    }
    
    //MARK: - Notification
    
    //键盘边距变化
    @objc func keyboardWillChangeFrame(_ notification : Notification) {
        //获取键盘高度和动画时长
        let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        //计算键盘顶部比输入框底部高度差
        let offsetY = frame.origin.y - textFieldBottomY
        //执行界面移动动画
        UIView.animate(withDuration: duration) {
            if offsetY < 0 {//如果键盘顶部比输入框底部高，提高界面高度
                self.view.transform = CGAffineTransform(translationX: 0, y: offsetY)
            } else {//否则还原界面高度
                self.view.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
    }
    
    //MARK: -
    
    func addTimer() -> Void {
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSsidLblText), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        }
    }
    
    func removeTimer() -> Void {
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
    }
    
    func addProgressTimer(_ time: Int32) -> Void {
        isConfiging = true
        wifiBtn.isUserInteractionEnabled = false
        sureBtn.isUserInteractionEnabled = false
        waitTime = time
        if progressTimer == nil{
            progressTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(increaseProgress), userInfo: nil, repeats: true)
            
            progress = 0
            RunLoop.main.add(progressTimer!, forMode:RunLoop.Mode.common)
        }
    }
    
    @objc func increaseProgress() -> Void {
        
        if leaveFlag == false  {
            progress += 1
            let f: Float = Float(progress)/Float(waitTime);
            
            GlobarMethod.showProgress(CGFloat(f), status: getProgressText())
            //  print(getProgressText())
            
            if (progress > waitTime) {
                DispatchQueue.main.async {
                    self.removeProgressTimer()
                    GlobarMethod.notifyDismiss()
                    
                }
            }
        }
    }
    
    func getProgressText() -> String {
        return String(format: "%@:%dS", tipStr, waitTime-progress)
    }
    
    func removeProgressTimer() -> Void {
        isConfiging = false
        wifiBtn.isUserInteractionEnabled = true
        sureBtn.isUserInteractionEnabled = true
        if progressTimer != nil{
            
            self.processTimerStop()
            GlobarMethod.notifyDismiss()
            progressTimer?.invalidate()
            
            sureBtn.backgroundColor = APP_ThemeColor
            progressTimer = nil
        }
    }
    
    //MARK: - UITextField
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (currentWifiName?.count)! <= 0 {
          
            let alertController = UIAlertController(title:NSLocalizedString("Hint", tableName: "") , message: NSLocalizedString("Please connect to the wifi.", tableName: "GuideDevice") , preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
            
            let actionOk = UIAlertAction(title: NSLocalizedString("Go to Setting",  comment: ""), style: .destructive, handler: {
                (action) -> Void in
                
                self.wifiBtnDidClicked(self.wifiBtn as Any)
            })
            alertController.addAction(actionCancel)
            alertController.addAction(actionOk)
            present(alertController, animated: true, completion: nil)
            textField.endEditing(true)
            return
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }

    @objc func textFieldDidChangeText(_ textField: UITextField) -> Void {
        let newString = textField.text!
        
        if newString.count >= 8 || newString.count == 0{
            sureBtn.backgroundColor = APP_ThemeColor
        } else {
            sureBtn.backgroundColor = UIColor.gray
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passWordTextField.endEditing(true)
        return true
    }
    
    
    //MARK: - UITextField
    
    @objc func updateSsidLblText() -> Void {
        var ssid: String = "Not Found"
        
        let interfaces = CNCopySupportedInterfaces()
        if interfaces != nil {
            let interfacesArray = CFBridgingRetain(interfaces) as! Array<AnyObject>
            if interfacesArray.count > 0 {
                let interfaceName = interfacesArray[0] as! CFString
                let ussafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName)
                if (ussafeInterfaceData != nil) {
                    let interfaceData = ussafeInterfaceData as! Dictionary<String, Any>
                    ssid = interfaceData["SSID"]! as! String
                }
            }
        }
        
        if currentWifiName == nil || currentWifiName != ssid{
            currentWifiName = ssid
            if ssid.contains("5G") ||  ssid.contains("5g"){
                self.show5gWifiAlert()
            }
            ssidLabel.text = ssid
            if UserDefaults.standard.value(forKey: ssid) != nil {
                let string: String = UserDefaults.standard.value(forKey: ssid) as! String
                passWordTextField.text = string
                
            }
        }
    }
    
    func show5gWifiAlert() -> Void {
        let alert = UIAlertController(title:NSLocalizedString("The current Wi-Fi name contains the \"5G\" field", comment: "") , message: NSLocalizedString("Device does not support connection 5G Wi-Fi, please go to the settings page to switch the network!", comment: "") , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Go to Setting",  comment: ""), style: .default, handler: {
            (action) -> Void in
            self.wifiBtnDidClicked(self.wifiBtn as Any)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: -
    
    
    @IBAction func wifiBtnDidClicked(_ sender: Any) {
        let url = URL(string: "App-Prefs:")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { (isOpen) in }
        }
    }
    
    @IBAction func sureBtnDidClicked(_ sender: Any) {
        self.view.endEditing(true)
        if self.currentWifiName == nil || self.currentWifiName?.count == 0 {
            alertMessage(NSLocalizedString("Please connect to the wifi.", tableName: "GuideDevice"))
            return
        }
        
        if ((passWordTextField.text?.count)! > 0) && ((passWordTextField.text?.count)! < 8){
            alertMessage(NSLocalizedString("The password is at least 8 characters.", comment: ""))
            return
        }
        
        
        let sb = UIStoryboard(name: "GuideThinker", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TopConnectThinkerWifiVC") as! TopConnectThinkerWifiVC
        vc.homeInfo = homeInfo
        vc.roomInfo = roomInfo
        vc.deviceType = self.type
        vc.ssid = (self.currentWifiName)!
        vc.wifiPwd = (self.passWordTextField.text)!
        show(vc, sender: nil)
        
    }
}
