//
//  TopSecurityDevListVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/4/2.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopDeviceSecuritySelectedVC: TopSuperVC  ,UITableViewDelegate, UITableViewDataSource{
    private var securityList = Array<TopSecurity>()
    private var sefe: TopSafe?
    private var isChanged: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TopDataManager.shared.refreshHostDeviceInfo()
        
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action:#selector(saveItemDidclicked))
        self.navigationItem.rightBarButtonItems=[saveItem]
        self.title = NSLocalizedString("Add alarm device", comment: "")
        tableView.register(UINib(nibName: "TopDeivceSecurityCell", bundle: nil), forCellReuseIdentifier: "TopDeivceSecurityCell")
        
        let cancelItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .done, target: self, action: #selector(cancelItemDidclicked))
        cancelItem.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = cancelItem
        getRefreshData()
        
    }
    
    @objc func cancelItemDidclicked(_ view: UIView) -> Void {
        if !isChanged{
            navigationController?.popViewController(animated: true)
            return
        }
        let alertController = UIAlertController(title: NSLocalizedString("Cancel editors", comment: "")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = view.bounds
        }
        
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
            (action) -> Void in
            weakSelf?.navigationController?.popViewController(animated: true)
            
        })
        alertController.addAction(actionOk)
        alertController.addAction(actionCancel)
        present(alertController, animated: true, completion: nil)
    }
   
    @objc func saveItemDidclicked(_ sender: Any) {
        var selectSecurityList = Array<TopSecurity>()
        for security in securityList {
            if security.isSelected == true{
                selectSecurityList.append(security)
            }
            
        }
        sefe?.securityList = selectSecurityList
        
        if   SGlobalVars.securityHandle.securityModeInfoSetReq(TopDataManager.shared.homeId, securityModeInfo: sefe?.securityModeInfo!) == 0{
            
            processTimerStart(3.0)
        }else{
            GlobarMethod.notifyFailed()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        NotificationCenter.default.addObserver(self, selector: #selector(securityModeInfoResp), name: NSNotification.Name("securityModeInfoResp"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("securityModeInfoResp"), object: nil)
    }
    
    @objc func securityModeInfoResp(notificatin: Notification) {
        //家庭设置回复
        processTimerStop()
        GlobarMethod.notifyDismiss()
        let info: TopSecurityAckInfo = notificatin.object as! TopSecurityAckInfo
        if info.state == .ok {
            sefe?.securityAckInfo = info
            self.navigationController?.popViewController(animated: true)
            GlobarMethod.notifySuccess()
        } else {
            GlobarMethod.notifyFailed()
        }
    }

    
    override func getRefreshData() -> Void {
        securityList.removeAll()
        sefe = TopDataManager.shared.safe
        let deviceAckList = TopDataManager.shared.resetDeviceInfo()
        
        let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
        for deviceAckInfo in deviceAckList {
            
            
            if hostSubType == .thinkerMini {
                if deviceAckInfo.md5 != TopDataManager.shared.hostDeviceInfo?.md5 {
                    continue
                }
            }
            
            if deviceAckInfo.mainType == .rf315m {
                var security: TopSecurity = TopSecurity()
                security.deviceAckInfo = deviceAckInfo
                for theSecurity in (sefe?.securityList)!{
                    if (theSecurity.securityDevInfo?.md5 == deviceAckInfo.md5) && (theSecurity.securityDevInfo?.subId == deviceAckInfo.subId){
                        security = theSecurity
                        break
                    }
                }
                securityList.append(security)
            }
            
            if deviceAckInfo.mainType == .slave {
                if (deviceAckInfo.slaveType == .doorSensor) || (deviceAckInfo.slaveType == .motionSensor) || (deviceAckInfo.slaveType == .doorlock) || (deviceAckInfo.slaveType == .smokeSensor) || (deviceAckInfo.slaveType == .waterLeakSensor) || (deviceAckInfo.slaveType == .shakeSensor) {
                    
                    var security = TopSecurity()
                    
                    security.deviceAckInfo = deviceAckInfo
                    for theSecurity in (sefe?.securityList)! {
                        if (theSecurity.securityDevInfo?.md5 == deviceAckInfo.md5) &&
                            (theSecurity.securityDevInfo?.subId == deviceAckInfo.subId) {
                            security = theSecurity
                            break
                        }
                    }
                    securityList.append(security)
                }
            }
           
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return securityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TopDeivceSecurityCell") as! TopDeivceSecurityCell
        let security:TopSecurity = securityList[indexPath.row]
        cell.selectionStyle = .none
        cell.security = security
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: TopDeivceSecurityCell = (tableView.cellForRow(at: indexPath) as! TopDeivceSecurityCell?)!
       
        if cell._security?.isSelected == false {
            if cell.security?.deviceAckInfo?.md5 != SGlobalVars.curHomeInfo.ctrlCenter {
                let deviceAckInfoList = TopDataManager.shared.resetDeviceInfo()
                var glDeviceInfo: TopDeviceAckInfo?
                for deviceAckInfo in deviceAckInfoList {
                    if deviceAckInfo.mainType == .geeklink {
                        if deviceAckInfo.md5 ==  cell.security?.deviceAckInfo?.md5 {
                            glDeviceInfo = deviceAckInfo
                            break
                        }
                    }
                }
                
                if glDeviceInfo != nil {
               
                    let alert = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Please make sure that the  %@'s host (%@) is in the same Wi-Fi LAN as the home host(%@).", tableName:"HomePage"), (cell.security?.deviceAckInfo?.deviceName)! ,(glDeviceInfo?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                    
                    //设置动作
                    
                    let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
                        (UIAlertAction) -> Void in
                        cell._security?.isSelected = !(cell._security?.isSelected)!
                        self.isChanged = true
                        self.tableView.reloadData()
                    })
                    //显示弹窗
                     let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                     alert.addAction(cancel)
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                   
                    return
                }
             
            }
        }
        cell._security?.isSelected = !(cell._security?.isSelected)!
        isChanged = true
        self.tableView.reloadData()
       
    }
    
    

}
