//
//  TopDeviceWifiSettingVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/7/12.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
enum TopWifiSettingType: Int {
    case name
    case password
    case confirmPassword
}
class TopDeviceWifiSettingVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource, TopTextInputCellDelegate, UITextFieldDelegate, TopSuperCellDelegate {
  
  @IBOutlet weak var tableView: UITableView!
    var wifiSwiftItem: TopItem = TopItem()
    var wifiNameItem: TopItem = TopItem()
 
    var passwordItem: TopItem = TopItem()
    var confirmPassword: TopItem = TopItem()
    var deviceInfo : GLDeviceInfo!
    var homeInfo : GLHomeInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        wifiSwiftItem.text = NSLocalizedString("Wi-Fi switch", comment: "")
        wifiSwiftItem.accessoryType = .switchBtn
        
        wifiNameItem.text = NSLocalizedString("Wi-Fi name", comment: "")
        wifiNameItem.headerTitle = NSLocalizedString("Please input Wi-Fi name", comment: "")
        wifiNameItem.tag = TopWifiSettingType.name.rawValue
    
        passwordItem.text = NSLocalizedString("Wi-Fi password", comment: "")
        passwordItem.headerTitle = NSLocalizedString("Please input wifi password", comment: "")
        passwordItem.tag = TopWifiSettingType.password.rawValue
        
        confirmPassword.text = NSLocalizedString("Repeat password", comment: "")
        confirmPassword.headerTitle = NSLocalizedString("Please input wifi password agian", comment: "")
        confirmPassword.tag = TopWifiSettingType.confirmPassword.rawValue
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         NotificationCenter.default.addObserver(self, selector: #selector(onThinkerSetRouterInfoResponse), name:NSNotification.Name("onThinkerSetRouterInfoResponse"), object: nil)
        self.getRefreshData()
    }
    override func getRefreshData() {
        let rooterInfo = "{\\\"action\\\":\\\"GetWifiSetting\\\"}"
        if  SGlobalVars.thinkerHandle.thinkerSetRouterInfo(homeInfo.homeId, deviceId: deviceInfo.deviceId, routerInfo: rooterInfo) == 0 {
           
        }else {
            GlobarMethod.notifyNetworkError()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("onThinkerSetRouterInfoResponse"), object: nil)
    }

    @objc func onThinkerSetRouterInfoResponse(notificatin: Notification) {
        processTimerStop()
        
      
        let ackInfo = notificatin.object as? TopThkAckInfo
       
        let jsonData:Data = (ackInfo?.routerInfo.data(using: .utf8)!)!
      
        
     
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSDictionary
        let action  = dict?.value(forKey: "action") as! String
        if action == "DisableWifi"
        {
            GlobarMethod.notifySuccess()
            self.wifiSwiftItem.isSelected = false
            self.wifiSwiftItem.swichIsOn = false
            self.tableView.reloadData()
            return
        }
        if action == "EnableWifi"
        {
            GlobarMethod.notifySuccess()
            self.wifiSwiftItem.isSelected = true
            self.wifiSwiftItem.swichIsOn = true
            self.tableView.reloadData()
            return
        }
        if action == "SettingWifi"{
            GlobarMethod.notifySuccess()
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let swichStr: String = dict?.value(forKey: "disabled") as! String
        let wifiName: String = dict?.value(forKey: "ssid") as! String
        let password: String = dict?.value(forKey: "key") as! String
        
        wifiSwiftItem.isSelected = swichStr == "0"
        wifiSwiftItem.swichIsOn = swichStr == "0"
        wifiNameItem.detailedText = wifiName
        passwordItem.detailedText = password
        confirmPassword.detailedText = password
        
        
        self.tableView.reloadData()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if wifiSwiftItem.isSelected == false {
            return 1
        }
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch section {
        case 2:
            return 2
        default:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var item: TopItem = TopItem()
        switch indexPath.section {
        case 0:
            item = wifiSwiftItem
            let cell = TopSuperCell(style: .default, reuseIdentifier: "")
            cell.item = item
            cell.delegate = self
            return cell
        case 1:
            item = wifiNameItem
        case 2:
            if indexPath.row == 0 {
                item = passwordItem
            }else {
                item = confirmPassword
            }
            
        default:
            break
        }
        
        
         let cell: TopTextInputCell =  TopTextInputCell(style: .default, reuseIdentifier: "TopTextInputCell")
        cell.item = item
        // let text = item.text
       
        cell.delegate = self
        if indexPath.section == 2 {
             cell.textField?.isSecureTextEntry = true
        }
        cell.textField?.tag = item.tag
        cell.textField?.textAlignment = .right
        cell.textField?.placeholder = item.headerTitle
        cell.textField?.isUserInteractionEnabled = SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId)
        cell.selectionStyle = .none
        return cell;
    }
    func textInputCellDidChangeText(_ cell: TopTextInputCell, text: String) {
        cell.item?.detailedText = text
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 16
        }
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 2 ? 60 : 16
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section < 2 {
            return UIView()
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 60))
        view.backgroundColor = UIColor.clear
        
        let topBtn: UIButton  =  UIButton()
        topBtn.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        topBtn.frame =  CGRect(x: SCREEN_WIDTH * 0.15, y: 16, width: SCREEN_WIDTH * 0.7, height: 44)
        topBtn.backgroundColor = GlobarMethod.getThemeColor()

        topBtn.setTitleColor(UIColor.darkGray, for: .normal)
        
        topBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        topBtn.addTarget(self, action: #selector(setWifi), for: .touchUpInside)
        topBtn.layer.cornerRadius = 8
        topBtn.clipsToBounds = true
        view.addSubview(topBtn)
        
        return view
    }
    
    @objc func setWifi() -> Void {
        
        if wifiNameItem.detailedText.count == 0 {
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Wi-Fi name can not be empty", comment: ""))
            return
        }
        
        if passwordItem.detailedText != confirmPassword.detailedText {
            GlobarMethod.notifyError(withStatus: NSLocalizedString("The password is not consistent.", comment: ""))
            return
        }
        
        let rooterInfo = String(format: "{\\\"action\\\":\\\"SettingWifi\\\",\\\"ssid\\\":\\\"%@\\\",\\\"key\\\":\\\"%@\\\"}", wifiNameItem.detailedText, passwordItem.detailedText)
        
        if SGlobalVars.thinkerHandle.thinkerSetRouterInfo(homeInfo.homeId, deviceId: deviceInfo.deviceId, routerInfo: rooterInfo) == 0 {
            self.processTimerStart(3)
        } else {
            GlobarMethod.notifyNetworkError()
        }
    }
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
          var rooterInfo = "{\\\"action\\\":\\\"EnableWifi\\\"}"
        if item.isSelected {
           rooterInfo = "{\\\"action\\\":\\\"DisableWifi\\\"}"
           
        }
        
        if  SGlobalVars.thinkerHandle.thinkerSetRouterInfo(homeInfo.homeId, deviceId: deviceInfo.deviceId, routerInfo: rooterInfo) == 0 {
            self.processTimerStart(3)
        }else {
            GlobarMethod.notifyNetworkError()
        }
        
        item.swichIsOn = item.isSelected
        self.tableView.reloadData()
       
    }

    

}
