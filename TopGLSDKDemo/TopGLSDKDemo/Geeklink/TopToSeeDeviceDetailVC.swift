//
//  TopToSeeDeviceDetailVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/8/31.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopToSeeDeviceDetailVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource, TopLCBindVCDelegate, UITextFieldDelegate {
    
    // MARK: - 变量
    
    var delegate: TopDeviceDetailVCDelegate?
    
    var roomList = Array<GLRoomInfo>.init()
    var timer: Timer?
    //    var rcMode: Bool?
    var homeInfo = GLHomeInfo.init()
    var roomInfo = GLRoomInfo.init()
    var deviceInfo = GLDeviceInfo.init()
    var newHomeInfo: GLHomeInfo?//删除主控时用于更新家庭
    var tempName = ""//临时名字
    var secformatter: DateFormatter!
    var refreshDataTimer: Timer?
    weak var  alertController: UIAlertController?
    
    // MARK: - 控件连接
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var headerImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        secformatter = DateFormatter.init()
        secformatter.dateFormat = "ss"
        
        title = NSLocalizedString("View Device", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
        
        tempName = deviceInfo.name
        
        setHeaderViewImge()
        
        roomList = GlobalVars.share().roomHandle.getRoomList(homeInfo.homeId) as! Array<GLRoomInfo>
        
        tableView.register(UINib(nibName: "TopSecurityDeviceCell", bundle: nil), forCellReuseIdentifier: "TopSecurityDeviceCell")
        
        setupRefresh(tableView);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if deviceInfo.mainType == .camera &&
            deviceInfo.subType == 1 {
            TopEZCamTools.share().cleanCamList()
            TopEZCamTools.share().checkDevList()
        }
        
        //增加监听事件
        NotificationCenter.default.addObserver(self, selector: #selector(onEZCamToolsDevListChange), name:NSNotification.Name(rawValue: "onEZCamToolsDevListChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onLCCamToolsDevListChange), name:NSNotification.Name(rawValue: "onLCCamToolsDevListChange"), object: nil)
        
        
        getRefreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //移除监听事件
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "onLCCamToolsDevListChange"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "onEZCamToolsDevListChange"), object: nil)
    }
    
    @objc func onLCCamToolsDevListChange(_ notifi: Notification) -> Void {
        self.tableView.reloadData()
    }
    
    @objc func onEZCamToolsDevListChange(_ notifi: Notification) -> Void {
        self.tableView.reloadData()
    }
    
    func checkTimeChange() -> Void {
        if secformatter.string(from: Date.init()) == "00" {
            self.tableView.reloadData()
        }
    }
    
    override func alertMessage(_ message: String) -> Void {
        let alert = UIAlertController.init(title: nil, message:  message, preferredStyle: .alert)
        let confirmAction = UIAlertAction.init(title: NSLocalizedString("Confirm", comment: ""), style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        self.alertController = alert
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - 头部视图
    
    func setHeaderViewImge() {
        
        
        headerImg.image = UIImage.init(named: "dev_detail_img_camera")
    }
    
    
    override func getRefreshData() -> Void {
        
        
    }
    
    // MARK: - 设备设置单元
    
    func getTimeData() -> Void {
        let info = GLTimezoneActionInfo.init(homeId: GlobalVars.share().curHomeInfo.homeId, deviceId: deviceInfo.deviceId, action: .timezoneActionGet, timezone: 0, language: 0)
        GlobalVars.share().deviceHandle.devTimezoneAction(info)
        
    }
    
    func setCameraStateCell(cell: UITableViewCell, indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("Device Type", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
            
            switch deviceInfo.subType {
            case 0:
                cell.detailTextLabel?.text = NSLocalizedString("TUTK Camera", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
            case 1:
                cell.detailTextLabel?.text = NSLocalizedString("Ys camera", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
            case 2:
                cell.detailTextLabel?.text = NSLocalizedString("LeChange Camera", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
            default:
                break
            }
        case 1:
            cell.textLabel?.text = NSLocalizedString("S/N", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
            cell.detailTextLabel?.text = deviceInfo.camUid
        default:
            break
        }
    }
    
    
    // MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0://主要信息
            return 2
        case 1://设备状态
            return 2
        case 2://设备设置
            if deviceInfo.subType == 1 {
                return 2
            }else if deviceInfo.subType == 2{
                return 3
            }
            
            return 1
            
        case 3://删除设备
            return GlobalVars.share().api.getCurUsername() == homeInfo.admin ? 1:0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return headerView
        }
        return UIView.init()
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 8
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 3 {//删除设备
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellDel")!
            for view1 in cell.subviews {
                for view2 in view1.subviews {
                    if view2.isKind(of: UILabel.classForCoder()) {
                        let lable: UILabel = view2 as! UILabel
                        lable.text = NSLocalizedString("Delete this device", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
                        break
                    }
                }
            }
            return cell
        }
        
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "")
        cell.accessoryType = .none
        
        if indexPath.section == 0 {
            if GlobalVars.share().api.getCurUsername() == homeInfo.admin {//管理员
                cell.accessoryType = .disclosureIndicator//显示箭头
            }
            
            switch indexPath.row {//主要信息
            case 0:
                cell.textLabel?.text = NSLocalizedString("Device Name", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
                cell.detailTextLabel?.text = tempName
                break
            case 1:
                cell.textLabel?.text = NSLocalizedString("Device Room", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
                cell.detailTextLabel?.text = roomInfo.name
                break
            default:
                break
            }
            
        } else if indexPath.section == 1 {//设备状态
            setCameraStateCell(cell: cell, indexPath: indexPath)
            return cell
        } else if indexPath.section == 2 {//设备设置
            cell.accessoryType = .disclosureIndicator//显示箭头
            
            if indexPath.row == 0 {
                cell.textLabel?.text = NSLocalizedString("Setting", comment: "")
                return cell
            }else {
                if indexPath.row == 1 {
                    
                    if deviceInfo.subType == 1 {
                        
                        cell.textLabel?.text = NSLocalizedString("Message", comment: "")
                        return cell
                    }else
                    {
                        cell.textLabel?.text = NSLocalizedString("Local video", comment: "")
                        return cell
                    }
                }else {
                    cell.textLabel?.text = NSLocalizedString("Cloud video", comment: "")
                    return cell
                }
                
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if GlobalVars.share().api.getCurUsername() != homeInfo.admin {//不是管理员
            return
        }
        
        //
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0://修改名字
                onChangeDeviceName()
            case 1://修改房间
                onChangeRoom(indexPath: indexPath)
            default:
                break
            }
            
        } else if indexPath.section == 1 {
            
            
        } else if indexPath.section == 2 {//点击设置
            onClickCameraSetting(indexPath)
            
            return
        } else {//删除
            
            //检查是否远程
            alertDeleteDevice(indexPath: indexPath)
            
        }
    }
    
    func alertUnbindMessage (_ subType: Int32) {
        var message = NSLocalizedString("Unbound Le Cheng account number.", comment: "")
        if subType == 1{
            message = NSLocalizedString("Unbound EZ account number.", comment: "")
        }
        let alertController = UIAlertController.init(title: nil, message: message , preferredStyle: .alert)
        weak var weakSelf = self
        let confirmAction = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        _ = UIAlertAction.init(title: NSLocalizedString("Bind", comment: ""), style: .default) { (action) in
            if subType == 1{
                EZOpenSDK.openLoginPage { (accessToken) in
                    GlobalKit.share().accessToken = accessToken?.accessToken
                    EZOpenSDK.setAccessToken(accessToken?.accessToken)
                    TopEZCamTools.share().checkDevList()
                    
                    UserDefaults.standard.set(GlobalVars.share().curHomeInfo.admin, forKey: "currentAdimi")
                    GlobalKit.share().accessToken = accessToken?.accessToken
                    GlobalKit.share().accessTokenExpire = (accessToken?.expire)!
                    let sb = UIStoryboard(name: "Camera", bundle: nil)
                    let addNewCameraVC: TopAddNewCameraVC = sb.instantiateViewController(withIdentifier: "TopAddNewCameraVC") as! TopAddNewCameraVC
                    addNewCameraVC.type = .TopAddNewCameraVCEZVIZCamera
                    weakSelf?.show(addNewCameraVC, sender: nil)
                    // weakSlef?.gotoEZQRcodeScanVC()
                    
                }
            }else{
                let sb = UIStoryboard(name: "Camera", bundle: nil)
                let lCBindVC: TopLCBindVC = sb.instantiateViewController(withIdentifier: "TopLCBindVC") as! TopLCBindVC
                lCBindVC.delegate = weakSelf
                weakSelf?.show(lCBindVC, sender: nil)
            }
        }
        
        alertController.addAction(confirmAction)
        self.alertController = alertController
        present(alertController, animated: true, completion: nil)
    }
    
    func onClickCameraSetting(_ indexPath: IndexPath) -> Void {
        
        if deviceInfo.subType == 0{//tutk
            let vc: EditCameraDefaultController = EditCameraDefaultController.init(style: .grouped)
            
            //vc.dev =
            vc.camera = GlobalVars.share().getAndRegistSingalCamera(byCameraInfo: deviceInfo)
            vc.homeInfo = homeInfo
            vc.hidesBottomBarWhenPushed = true
            vc.deviceInfo = deviceInfo
            self.show(vc, sender: nil)
            
        }else if deviceInfo.subType == 1{//ez
            
            if  UserDefaults.standard.value(forKey: "currentAdimi") != nil{
                let admin: String = UserDefaults.standard.value(forKey: "currentAdimi") as! String
                if admin != GlobalVars.share().curHomeInfo.admin {
                    GlobalKit.share().refreshYsAccessToken()
                    EZOpenSDK.setAccessToken(GlobalKit.share().accessToken)
                }
                
            }
            if GlobalKit.share().accessToken == nil {
                self.alertUnbindMessage(1)
            }
            
            
            var currenteEzdevice: EZDeviceInfo?
            if TopEZCamTools.share().loadShareList() != nil{
                let ezCamShareList = TopEZCamTools.share().loadShareList() as! Array<EZDeviceInfo>
                if (ezCamShareList.count) > 0{
                    
                    for ezdevice in ezCamShareList{
                        if deviceInfo.camUid == ezdevice.deviceSerial{
                            currenteEzdevice = ezdevice
                        }
                    }
                }
            }
            
            if TopEZCamTools.share().loadAdminList() != nil {
                let ezCamAdminList = TopEZCamTools.share().loadAdminList() as! Array<EZDeviceInfo>
                
                if (ezCamAdminList.count) > 0{
                    
                    for ezdevice in ezCamAdminList{
                        if deviceInfo.camUid == ezdevice.deviceSerial{
                            currenteEzdevice = ezdevice
                        }
                    }
                }
            }
            if currenteEzdevice == nil{
                self.alertMessage(NSLocalizedString("Unknow device", comment: ""))
                return
            }
            if indexPath.row == 0{
                let sb = UIStoryboard(name: "EZMain", bundle: nil)
                let settingViewController: EZSettingViewController = sb.instantiateViewController(withIdentifier: "EZSettingViewController") as! EZSettingViewController
                settingViewController.deviceInfo = currenteEzdevice
                settingViewController.hidesBottomBarWhenPushed = true
                self.show(settingViewController, sender: nil)
            }else {
                let sb = UIStoryboard(name: "EZMain", bundle: nil)
                let messageListViewController: EZMessageListViewController = sb.instantiateViewController(withIdentifier: "EZMessageListViewController") as! EZMessageListViewController
                messageListViewController.deviceInfo = currenteEzdevice
                messageListViewController.hidesBottomBarWhenPushed = true
                self.show(messageListViewController, sender: nil)
            }
            
            
        }else if deviceInfo.subType == 2{
            if LCTools.share().loadUserToken() == nil{
                self.alertUnbindMessage(2)
            }
            let sb = UIStoryboard(name: "LeChange", bundle: nil)
            
            let lcCamList =  LCTools.share().loadCamlist()
            if lcCamList == nil{
                self.alertMessage(NSLocalizedString("Unknow device", comment: ""))
                return
            }
            var theCameraDeviceInfo: DeviceInfo?
            for camera in lcCamList!{
                let cameraDeviceInfo = camera as! DeviceInfo
                if (cameraDeviceInfo.value(forKey: "ID") as! String) == deviceInfo.camUid{
                    theCameraDeviceInfo = cameraDeviceInfo
                    break
                }
                
            }
            if theCameraDeviceInfo == nil {
                self.alertMessage(NSLocalizedString("Unknow device", comment: ""))
                return
            }
            
            
            
            if indexPath.row == 0{
                let settingVCmsgVC:  LCSettingVC = sb.instantiateViewController(withIdentifier: "LCSettingVC") as! LCSettingVC
                settingVCmsgVC.ishasPassword = deviceInfo.camPwd.count > 0
                
                settingVCmsgVC.m_accessToken = LCTools.share().loadUserToken()
                settingVCmsgVC.m_strDevSelected = deviceInfo.camUid
                settingVCmsgVC.m_devChnSelected = GlobarMethod.getLCCameraChannelId(theCameraDeviceInfo, andIndex: 0)
                self.show(settingVCmsgVC, sender: nil)
            }else if indexPath.row == 1{
                let sb =  UIStoryboard(name: "LeChange", bundle: nil)
                let recordVC: LCRecordVC = sb.instantiateViewController(withIdentifier: "LCRecordVC") as! LCRecordVC
                
                recordVC.m_accessToken =  LCTools.share().loadUserToken()
                recordVC.m_strDevSelected = deviceInfo.camUid
                recordVC.m_encryptKey = GlobarMethod.getLCCameraEncryptKey(theCameraDeviceInfo, andIndex: 0)
                recordVC.m_devChnSelected =  GlobarMethod.getLCCameraChannelId(theCameraDeviceInfo, andIndex: 0)
                recordVC.m_recordType = .DeviceRecord
                self.show(recordVC, sender: nil)
            }else {
                let sb =  UIStoryboard(name: "LeChange", bundle: nil)
                let recordVC: LCRecordVC = sb.instantiateViewController(withIdentifier: "LCRecordVC") as! LCRecordVC
                
                recordVC.m_accessToken =  LCTools.share().loadUserToken()
                recordVC.m_strDevSelected = deviceInfo.camUid
                recordVC.m_encryptKey = GlobarMethod.getLCCameraEncryptKey(theCameraDeviceInfo, andIndex: 0)
                recordVC.m_devChnSelected =  GlobarMethod.getLCCameraChannelId(theCameraDeviceInfo, andIndex: 0)
                recordVC.m_recordType = .CloudRecord
                self.show(recordVC, sender: nil)
            }
            
        }
    }
    
    
    
    func alertDeleteDevice(indexPath: IndexPath) {//询问删除
        
        let alert = UIAlertController.init(title: NSLocalizedString("Delete this device", tableName: "RoomDevice", bundle: .main, value: "", comment: "")+"?", message: "", preferredStyle: .actionSheet)
        let cancel = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let actionOk = UIAlertAction.init(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: {
            (action) -> Void in
            self.deleteDevice()
        })
        alert.addAction(cancel)
        alert.addAction(actionOk)
        
        if (alert.popoverPresentationController != nil) {
            let cell = tableView.cellForRow(at: indexPath)
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = (cell?.bounds)!
        }
        present(alert, animated: true, completion: nil)
    }
    
    func deleteDevice() {//判断类型删除
        GlobalVars.share().roomHandle.roomDeviceSet(homeInfo.homeId, action: .delete, deviceInfo: deviceInfo)
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    // MARK: - 修改属性
    
    func onChangeDeviceName() {
        
        //修改名字
        let alert = UIAlertController.init(title: NSLocalizedString("Input a new name", comment: ""), message: nil, preferredStyle: .alert)
        //设置输入框
        alert.addTextField(configurationHandler: { (textField) in
            textField.textAlignment = .center
            textField.text = self.tempName
            textField.delegate = self
            textField.placeholder = NSLocalizedString("Device Name", tableName: "RoomDevice", bundle: .main, value: "", comment: "")
        })
        
        //设置动作
        let cancel = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        let ok = UIAlertAction.init(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
            (UIAlertAction) -> Void in
            let name = alert.textFields?.first?.text
            if name?.count != 0 {
                
                self.tempName = name!
                
                let newDeviceInfo = GLDeviceInfo.init(deviceId: self.deviceInfo.deviceId, name: self.tempName, mainType: self.deviceInfo.mainType, md5: self.deviceInfo.md5, subType: self.deviceInfo.subType, subId: self.deviceInfo.subId, camUid: self.deviceInfo.camUid, camAcc: self.deviceInfo.camAcc, camPwd:self.deviceInfo.camPwd, roomId: self.roomInfo.roomId, roomOrder: self.deviceInfo.roomOrder, valid: self.deviceInfo.valid)
                GlobalVars.share().roomHandle.roomDeviceSet(self.homeInfo.homeId, action: .update, deviceInfo: newDeviceInfo)
                
                self.tableView.reloadData()
                
                self.delegate?.TopDeviceDetailVCChengeName(newName: name!)
            }else {
                GlobarMethod.notifyError(withStatus: NSLocalizedString("Device Name can not be empty", tableName: "RoomDevice", bundle: .main, value: "", comment: ""))
            }
        })
        //显示弹窗
        alert.addAction(cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func onChangeRoom(indexPath: IndexPath) {
        
        let alert = UIAlertController.init(title: NSLocalizedString("Transfer Room", tableName: "RoomPage", bundle: .main, value: "", comment: ""), message: NSLocalizedString("Transfer the device to another room", tableName: "RoomPage", bundle: .main, value: "", comment: ""), preferredStyle: .actionSheet)
        let cancel = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        if roomList.count == 0{
            self.alertMessage(NSLocalizedString("There are no other rooms. Please go to the room management to add.", tableName: "RoomPage", bundle: .main, value: "", comment: ""))
            return
        }
        
        for roomCell in roomList {
            
            let isThisRoom = roomCell.roomId == roomInfo.roomId
            
            let actionRoom = UIAlertAction.init(title: roomCell.name, style: .default, handler: {
                (UIAlertAction) -> Void in
                if isThisRoom == false {
                    self.roomInfo = roomCell
                    
                    let roomOrder = GlobalVars.share().roomHandle.getDeviceList(byRoom: self.homeInfo.homeId, roomId: roomCell.roomId).count
                    
                    let newDeviceInfo = GLDeviceInfo.init(deviceId: self.deviceInfo.deviceId, name: self.tempName, mainType: self.deviceInfo.mainType, md5: self.deviceInfo.md5, subType: self.deviceInfo.subType, subId: self.deviceInfo.subId, camUid: self.deviceInfo.camUid, camAcc: self.deviceInfo.camAcc, camPwd: self.deviceInfo.camPwd, roomId: roomCell.roomId, roomOrder: Int32(roomOrder), valid: self.deviceInfo.valid)
                    GlobalVars.share().roomHandle.roomDeviceSet(self.homeInfo.homeId, action: .update, deviceInfo: newDeviceInfo)
                    
                    self.tableView.reloadData()
                    
                    self.delegate?.TopDeviceDetailVCChengeRoom(newRoomInfo: roomCell)
                    
                    
                }
            })
            
            if isThisRoom {
                actionRoom.setValue(true, forKey: "checked")//选中
            }
            actionRoom.setValue(GlobarMethod.getThemeColor(), forKey: "titleTextColor")//字体颜色
            alert.addAction(actionRoom)
        }
        
        //显示弹窗
        if (alert.popoverPresentationController != nil) {
            let cell = tableView.cellForRow(at: indexPath)
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = (cell?.bounds)!
        }
        present(alert, animated: true, completion: nil)
    }
    func lcBindVCBindSuccess() {
        LCTools.share().getCameraList()
    }
}
