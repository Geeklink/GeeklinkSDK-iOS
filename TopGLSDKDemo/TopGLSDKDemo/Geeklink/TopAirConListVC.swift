//
//  TopAirConListVC.swift
//  Geeklink
//
//  Created by 列树童 on 2018/10/30.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit

class TopAirConListVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource {

    var homeInfo = GLHomeInfo()
    var hostList = [GLDeviceInfo]()
    
    var deviceStateCtrlResp: NSObjectProtocol!
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeInfo = (SGlobalVars.curHomeInfo)!
        for device in SGlobalVars.roomHandle.getDeviceListAll(homeInfo.homeId) as! [GLDeviceInfo] {
            if device.mainType == .geeklink {
                hostList.append(device)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //增加设备控制监听
        deviceStateCtrlResp = NotificationCenter.default.addObserver(forName: NSNotification.Name("deviceStateCtrlResp"), object: nil, queue: nil) { (notification) in
            
            let ackInfo = notification.object as! TopDeviceAckInfo
            self.processTimerStop()
            switch ackInfo.state {
            case .ok: GlobarMethod.notifySuccess()
            default: GlobarMethod.notifyFailed()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //移除设备控制监听
        NotificationCenter.default.removeObserver(deviceStateCtrlResp)
    }
    
    //MARK: - UIAlertController
    
    func showCurtainCtrl(_ deviceInfo: GLDeviceInfo) {
        
        let alert = UIAlertController(title: "窗帘控制百分比(0~100)", message: "", preferredStyle: .alert)
        //设置输入框
        alert.addTextField(configurationHandler: { (textField) in
            textField.textAlignment = .center
            textField.text = "100"
            textField.keyboardType = .numberPad
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {
            (UIAlertAction) -> Void in
            
            let action = alert.textFields?.first?.text
            if deviceInfo.mainType == .geeklink {
                if SGlobalVars.singleHandle.curtainCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, action: Int32(action!)!) == 0 {
                    self.processTimerStop()
                } else {
                    GlobarMethod.notifyNetworkError()
                }
            } else {
                
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showCurtainAlert(_ cell: UITableViewCell, deviceInfo: GLDeviceInfo) {
        
        let alert = UIAlertController(title: "窗帘控制", message: "", preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "窗帘控制", style: .default, handler: {
            (UIAlertAction) -> Void in
            self.showCurtainCtrl(deviceInfo)
        }))
        
        alert.addAction(UIAlertAction(title: "窗帘停止", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.curtainStop(self.homeInfo.homeId, deviceId: deviceInfo.deviceId) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "窗帘反转", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.curtainRollback(self.homeInfo.homeId, deviceId: deviceInfo.deviceId) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showSwitchAlert(_ cell: UITableViewCell, deviceInfo: GLDeviceInfo) {
        
        let state = SGlobalVars.singleHandle.getFeedbackSwitchState(homeInfo.homeId, deviceId: deviceInfo.deviceId)!
        let message = String(format: "A:%d B:%d C:%d D:%d", state.switchA, state.switchB, state.switchC, state.switchD)
        
        let alert = UIAlertController(title: "开关控制", message: message, preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell.bounds
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        
        alert.addAction(UIAlertAction(title: "A开", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.feedbackSwitchCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, road: 1, state: true) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: "A关", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.feedbackSwitchCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, road: 1, state: false) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: "B开", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.feedbackSwitchCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, road: 2, state: true) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: "B关", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.feedbackSwitchCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, road: 2, state: false) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: "C开", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.feedbackSwitchCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, road: 3, state: true) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: "C关", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.feedbackSwitchCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, road: 3, state: false) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: "D开", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.feedbackSwitchCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, road: 4, state: true) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        
        alert.addAction(UIAlertAction(title: "D关", style: .default, handler: {
            (UIAlertAction) -> Void in
            if SGlobalVars.singleHandle.feedbackSwitchCtrl(self.homeInfo.homeId, deviceId: deviceInfo.deviceId, road: 4, state: false) == 0 {
                self.processTimerStop()
            } else {
                GlobarMethod.notifyNetworkError()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = hostList[indexPath.row].name
        cell.detailTextLabel?.text = hostList[indexPath.row].md5
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch hostList[indexPath.row].subType {
            
        case 0x01, 0x02://思想者
            performSegue(withIdentifier: "TopSlaveListTestVC", sender: hostList[indexPath.row])
            
        case 0x0B://小派
            let sb = UIStoryboard(name: "TestSmartPi", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "TopTestSmartPiVC") as! TopTestSmartPiVC
            vc.homeInfo = homeInfo
            vc.deviceInfo = hostList[indexPath.row]
            show(vc, sender: nil)
            
        case 0x0C://Wi-Fi窗帘
            showCurtainAlert(cell, deviceInfo: hostList[indexPath.row])
            
        case 0x0D://中央空调控制
            performSegue(withIdentifier: "TopAirConSlaveListVC", sender: hostList[indexPath.row])
            
        case 0x0E://Wi-Fi灯泡
            performSegue(withIdentifier: "TopBulbTestVC", sender: hostList[indexPath.row])
            
        case 0x11, 0x12, 0x13, 0x14://Wi-Fi开关
            showSwitchAlert(cell, deviceInfo: hostList[indexPath.row])
            
        default:
            break
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination is TopAirConSlaveListVC {
            let vc = segue.destination as! TopAirConSlaveListVC
            vc.homeInfo = homeInfo
            vc.hostInfo = sender as! GLDeviceInfo
            
        } else if segue.destination is TopBulbTestVC {
            let vc = segue.destination as! TopBulbTestVC
            vc.homeInfo = homeInfo
            vc.deviceInfo = sender as! GLDeviceInfo
            
        } else if segue.destination is TopSlaveListTestVC {
            let vc = segue.destination as! TopSlaveListTestVC
            vc.homeInfo = homeInfo
            vc.hostInfo = sender as! GLDeviceInfo
        }
    }
}
