//
//  TopAddNewTaskVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/9.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit


class TopDeviceVCCell: UICollectionViewCell {
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var detailLabel: UILabel?
    @IBOutlet weak var tipImgView: UIImageView?
}

enum TopDeviceListVCType: Int {
    case TopDeviceListVCTypeTaskDevcie
    case TopDeviceListVCTypeQuickDevice
    case TopDeviceListVCTypeShortcuts
}

class TopDeviceListVC: TopSuperVC, UICollectionViewDelegate, UICollectionViewDataSource, CardScrollViewDelegate, UICollectionViewDelegateFlowLayout {
  
    var type: TopDeviceListVCType = .TopDeviceListVCTypeTaskDevcie
    var roomList = [GLRoomInfo]()
    var deviceList = Array<GLDeviceInfo>()

    var backVC: UIViewController?
    var roomInfo = GLRoomInfo()
    private var page = 0
    var cardCollectionViewItemW: CGFloat = 0
    var currentWidth: CGFloat = 0
    private var pageWidth: CGFloat = 0
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    var nameLabelList = [UILabel]()
    
  
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var triangleView: UIView!
 
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefresh(collectionView)
        switch type {
        case .TopDeviceListVCTypeShortcuts:
             title = NSLocalizedString("Select Device", tableName: "MacroPage")
        default:
             title = NSLocalizedString("Execution task", tableName: "MacroPage")
        }
        tipLabel.text = NSLocalizedString("Please select device.", comment: "")
         triangleView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/4))
       
        if App_Company == .geeklinkStoreVersion {
          
            collectionView.backgroundColor = UIColor.groupTableViewBackground
            topContentView.backgroundColor = UIColor.lightGray
            triangleView.backgroundColor = UIColor.white
           
           
        }else {
           
            
            if self.backVC != nil {
                let backItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .done, target: self, action: #selector(backItemDidclicked))
                backItem.tintColor = UIColor.white
                
                navigationItem.leftBarButtonItem = backItem
            }
            
        }
        //设置宫格图样式
        collectionView?.bounces = false
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        cardCollectionView?.showsHorizontalScrollIndicator = false
        setCollectionViewLayout()
        reloadRoomList()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        setCollectionViewLayout()
       
    }
    func setCollectionViewLayout() -> Void {
       
        let layout = CollectionLayout()
        let height = topContentView.height
        cardCollectionViewItemW =  topContentView.width * 0.5
        if cardCollectionViewItemW > height * 1.5
        {
            cardCollectionViewItemW = height * 1.5
        }
        pageWidth = self.view.width - cardCollectionViewItemW
        cardCollectionView.collectionViewLayout = layout
        cardCollectionView.reloadData()
        layout.itemSize = CGSize(width: cardCollectionViewItemW , height: height)
        cardCollectionView.contentOffset = CGPoint.init(x: CGFloat(page) * (cardCollectionViewItemW + 20), y: 0)
        if currentWidth == self.view.width {
            return
        }
        currentWidth = self.view.width
        collectionView.collectionViewLayout = GlobalDeviceCollectionViewFlowLayout(self.view.width)
        collectionView.reloadData()
       
    }
    
    @objc func backItemDidclicked(_ view: UIView) -> Void {
        self.navigationController?.popToViewController((self.backVC)!, animated: true)
    }
    //MARK: - CardScrollView
   
    
    
    func pagingScrollView(_ pagingScrollView: CardScrollView!, scrolledToPage currentPage: Int) {
        reloadRoomInfoWithroomInfoIndex(currentPage)
    }
    
    //MARK: -
    
    func reloadRoomList() {
        
        roomList = [GLRoomInfo]()
        
        let devicelist = TopDataManager.shared.resetDeviceInfo()
        var defaultRoomContainDevice = false
        for device in devicelist{
            if device.roomInfo.roomId == 0 {
                defaultRoomContainDevice = true
            }
        }
        
        roomList.append(contentsOf: SGlobalVars.roomHandle.getRoomList(TopDataManager.shared.homeId) as! [GLRoomInfo])
        
        if defaultRoomContainDevice || roomList.count == 0 {
            let defaultRoom = GLRoomInfo(roomId: 0, name: String(glRoomName: 0), picId: 0, members: "", order: 0)
            roomList.append(defaultRoom!)
        }
      
        reloadRoomInfoWithroomInfoIndex(0)
        
        cardCollectionView.reloadData()
    }
    
    func reloadRoomInfoWithroomInfoIndex(_ index: Int) {
        //更新房间图片
        if (roomList.count > index) {
            roomInfo = roomList[index]
        }
        
        if type == .TopDeviceListVCTypeTaskDevcie {
            //更新设备列表
            self.deviceList.removeAll()
            let deviceList = SGlobalVars.roomHandle.getDeviceList(byRoom: TopDataManager.shared.homeId, roomId: roomInfo.roomId) as! [GLDeviceInfo]
            
            let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
            for deviceInfo in deviceList {
                
                
                if hostSubType == .thinkerMini {
                    if deviceInfo.md5 != TopDataManager.shared.hostDeviceInfo?.md5 {
                        continue
                    }
                }
                
                if (deviceInfo.mainType == .database) ||
                    (deviceInfo.mainType == .custom) {
                    self.deviceList.append(deviceInfo)
                    
                } else if deviceInfo.mainType == .slave {
                    let slaveType = SGlobalVars.roomHandle.getSlaveType(deviceInfo.subType)
                    
                    if (slaveType == .fb11) ||
                        (slaveType == .fb12) ||
                        (slaveType == .fb13) ||
                        (slaveType == .fb1Neutral1) ||
                        (slaveType == .fb1Neutral2) ||
                        (slaveType == .fb1Neutral3) ||
                        (slaveType == .ioModula)  ||
                        (slaveType == .ioModulaNeutral) ||
                        (slaveType == .airConPanel) ||  (slaveType == .dimmerSwitch) ||  (slaveType == .feedbackSwitchWithScenario1) || (slaveType == .feedbackSwitchWithScenario2) || (slaveType == .feedbackSwitchWithScenario3){
                        self.deviceList.append(deviceInfo)
                        
                    } else if (slaveType == .curtain)  {
                        self.deviceList.append(deviceInfo)
                        
                    }
                    if (slaveType == .siren) {
                        self.deviceList.append(deviceInfo)
                    }
                    
                } else if deviceInfo.mainType == .geeklink {
                    let glType = GLGlDevType(rawValue: Int(deviceInfo.subType))!
                    switch glType {
                        
                    case .plug, .plugPower, .plugFour:
                        self.deviceList.append(deviceInfo)
                    case .rgbwBulb, .wifiCurtain, .rgbwLightStrip:
                        self.deviceList.append(deviceInfo)
                    case .acManage:
                        self.deviceList.append(deviceInfo)
                        
                    case .feedbackSwitch1,   .feedbackSwitch2, .feedbackSwitch3, .feedbackSwitch4:
                          self.deviceList.append(deviceInfo)
                    case .thinkerPro:
                         self.deviceList.append(deviceInfo)
                    case .thinkerMini:
                         self.deviceList.append(deviceInfo)
                    default:
                        break
                    }
                }
                else if deviceInfo.mainType == .BGM {
                    self.deviceList.append(deviceInfo)
                }
//                } else if deviceInfo.mainType == .airCon {
//                    self.deviceList.append(deviceInfo)
//                }
            }
        } else if type == .TopDeviceListVCTypeQuickDevice {
            deviceList = SGlobalVars.roomHandle.getDeviceList(byRoom: TopDataManager.shared.homeId, roomId: roomInfo.roomId) as! [GLDeviceInfo]
        }
        collectionView.reloadData()
        
    }
    
    func addMacroButtonDidClicked() {
        performSegue(withIdentifier: "TopAddNewMacroVC", sender: nil)
    }
  
    func showFWActionSheet(_ view: UIView, device: GLDeviceInfo) -> Void {
        let alertController = UIAlertController(title: nil, message:  nil, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
        
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = view.bounds
        }
        weak var weakSelf = self
        let actionRockBack = UIAlertAction(title: NSLocalizedString("On/Off Status", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let task = TopTask()
            task.switchCtrlInfo = GLSwitchCtrlInfo(rockBack: true, aCtrl: false, bCtrl: false, cCtrl: false, dCtrl: false, aOn: false, bOn: false, cOn: false, dOn: false)
            let deviceAckInfo = TopDeviceAckInfo()
            deviceAckInfo.deviceInfo = device
            deviceAckInfo.roomInfo = weakSelf?.roomInfo
            task.device = deviceAckInfo
            
            TopDataManager.shared.task = task
            
            let feedbackSwitchSetVC = sb.instantiateViewController(withIdentifier: "TopFeedbackSwitchSetVC") as! TopFeedbackSwitchSetVC
            feedbackSwitchSetVC.type = .TopFeedbackSwitchSetVCTypeAddTask
            self.show(feedbackSwitchSetVC, sender: nil)
            
        })
        
        let actionAction = UIAlertAction(title: NSLocalizedString("Fix Status", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let task: TopTask = TopTask()
            task.switchCtrlInfo = GLSwitchCtrlInfo(rockBack: false, aCtrl: false, bCtrl: false, cCtrl: false, dCtrl: false, aOn: false, bOn: true, cOn: true, dOn: true)
            let deviceAckInfo: TopDeviceAckInfo = TopDeviceAckInfo()
            deviceAckInfo.deviceInfo = device
            deviceAckInfo.roomInfo = weakSelf?.roomInfo
            task.device = deviceAckInfo
            
            TopDataManager.shared.task = task
            let feedbackSwitchSetVC = sb.instantiateViewController(withIdentifier: "TopFeedbackSwitchSetVC") as! TopFeedbackSwitchSetVC
            feedbackSwitchSetVC.type = .TopFeedbackSwitchSetVCTypeAddTask
            self.show(feedbackSwitchSetVC, sender: nil)
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionAction)
        alertController.addAction(actionRockBack)
        present(alertController, animated: true, completion: nil)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == cardCollectionView {
            return roomList.count
        }
        return 1
    }
    //MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cardCollectionView {
            return 1
        }
        return deviceList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cardCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCardCell", for: indexPath) as! TopCardCell
            let roomInfo = roomList[indexPath.section]
            cell.imgView.image = UIImage.init(named: String.init(format: "room_img_%d", roomInfo.picId))
            cell.label.text = roomInfo.name
            return cell
        }
        
        var identifier = "TopDeviceVCCell"
        
        if App_Company == .geeklinkStoreVersion {
            identifier = "TopDeviceVCCellPro"
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TopDeviceVCCell
        let device = deviceList[indexPath.row]
        cell.nameLable.text = device.name
        if device.mainType == .BGM {
            cell.iconImg.image = UIImage.init(named:  TopDataManager.shared.getAISpeakerImage(device))
            
        }else {
            cell.iconImg.image = TopDataManager.shared.getDeviceImageStateBig((SGlobalVars.curHomeInfo)!, deviceInfo: device)
            
        }
        return cell
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.cardCollectionView {
            
            page = Int(scrollView.contentOffset.x / (cardCollectionViewItemW + 16))
            reloadRoomInfoWithroomInfoIndex(page)
          
        }
       
        
      
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cardCollectionView {
            return
        }
        
        let device = deviceList[indexPath.row]
      

        
        
        
        if device.mainType == .slave || device.mainType == .database ||  device.mainType == .custom{
            if device.md5 != SGlobalVars.curHomeInfo.ctrlCenter {
                let deviceAckInfoList = TopDataManager.shared.resetDeviceInfo()
                var glDeviceInfo: TopDeviceAckInfo?
                for deviceAckInfo in deviceAckInfoList {
                    if deviceAckInfo.mainType == .geeklink {
                        if deviceAckInfo.md5 ==  device.md5 {
                            glDeviceInfo = deviceAckInfo
                            break
                        }
                    }
                }
                
                if glDeviceInfo != nil {
                    
                    let alert = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Please make sure that the  %@'s host (%@) is in the same Wi-Fi LAN as the home host(%@).", tableName:"HomePage"), device.name ,(glDeviceInfo?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                    
                    //设置动作
                    
                    let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
                        (UIAlertAction) -> Void in
                        self.selectedDevice(device, indexPath: indexPath)
                    })
                    //显示弹窗
                    let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                    alert.addAction(cancel)
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                    
                    return
                }
                
            }
        }else if  device.mainType == .geeklink{
             if device.md5 != SGlobalVars.curHomeInfo.ctrlCenter {
                let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message:  String.init(format: NSLocalizedString("Make sure %@ and the home host (%@) is connect to same network", tableName: "MacroPage"), device.name, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    self.selectedDevice(device, indexPath: indexPath)
                    
                })
                
                
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
                return
            }
           
        }
        self.selectedDevice(device, indexPath: indexPath)
        
       
    }
    func selectedDevice(_ device: GLDeviceInfo , indexPath: IndexPath) -> Void {
        
        let sb = UIStoryboard(name: "DeviceDetail", bundle: nil)
        let cell = collectionView.cellForItem(at: indexPath)
        let task = TopTask()
        let deviceAckInfo = TopDeviceAckInfo()
        deviceAckInfo.deviceInfo = device
        deviceAckInfo.roomInfo = roomInfo
        task.value = "0"
        task.device = deviceAckInfo
        
        TopDataManager.shared.task = task
        
        
        switch device.mainType {
        case .custom:
            let customType: GLCustomType = GLCustomType(rawValue: Int(device.subType))!
            
            switch customType {
            case .AC,.TV,.STB,.soundbox,.fan, .rcLight, .IPTV, .acFan, .projector, .airPurifier, .oneKey:
                let adVc = sb.instantiateViewController(withIdentifier: "TopActionDatabaseVC") as! TopActionLiveDeviceVC
                adVc.deviceInfo = device
                
                adVc.homeInfo = SGlobalVars.curHomeInfo
                self.show(adVc, sender: nil)
            default:
                let acVc = sb.instantiateViewController(withIdentifier: "TopActionCustomVC") as! TopActionCustomVC
                acVc.deviceInfo = device
                
                acVc.homeInfo = SGlobalVars.curHomeInfo
                show(acVc, sender: nil)
            }
            
        case.airCon:
            let sb = UIStoryboard(name: "ACManager", bundle: nil)
            let vc: TopAirConSubDeviceActionVC = sb.instantiateViewController(withIdentifier: "TopAirConSubDeviceActionVC") as! TopAirConSubDeviceActionVC
            vc.deviceInfo = deviceAckInfo.deviceInfo
            self.show(vc, sender: nil)
            return
            
        case .database:
            let adVc = sb.instantiateViewController(withIdentifier: "TopActionDatabaseVC") as! TopActionLiveDeviceVC
            adVc.deviceInfo = device
            
            adVc.homeInfo = SGlobalVars.curHomeInfo
            self.show(adVc, sender: nil)
            
        case .slave:
            let slaveType: GLSlaveType =  SGlobalVars.roomHandle.getSlaveType(device.subType)
            
            if (slaveType == .fb1Neutral1) ||
                (slaveType == .fb1Neutral2) ||
                (slaveType == .fb1Neutral3) ||
                (slaveType == .fb11) ||
                (slaveType == .fb12) ||
                (slaveType == .fb13) ||
                (slaveType == .ioModula) ||
                (slaveType == .ioModulaNeutral || slaveType == .feedbackSwitchWithScenario1 || slaveType == .feedbackSwitchWithScenario2 || slaveType == .feedbackSwitchWithScenario3){
                let item = collectionView.cellForItem(at: indexPath)
                showFWActionSheet(item!, device: device)
            }
            if slaveType == .curtain || slaveType == .dimmerSwitch {
                let curtainVc = sb.instantiateViewController(withIdentifier: "TopCurtainVC") as! TopSliderAndBtnVC
                self.show(curtainVc, sender: nil)
            }
            if slaveType == .siren {
                let sb = UIStoryboard(name: "Macro", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "TopSirenTimePickerVC") as! TopSirenTimePickerVC
                self.show(vc, sender: nil)
                return
                
            }
            else if slaveType == .airConPanel {
                let slaveActionVC = sb.instantiateViewController(withIdentifier: "TopSlaveActionVC") as! TopSlaveActionVC
                slaveActionVC.deviceInfo = device
                slaveActionVC.roomInfo = roomInfo
                slaveActionVC.homeInfo = SGlobalVars.curHomeInfo
                show(slaveActionVC, sender: nil)
            }
            return
        case .geeklink:
            let glType: GLGlDevType = GLGlDevType(rawValue: Int(device.subType))!
            switch glType {
                
            case .plug, .plugPower, .plugFour:
                
                
                let adVc = sb.instantiateViewController(withIdentifier: "TopActionDatabaseVC") as! TopActionLiveDeviceVC
                adVc.deviceInfo = device
                adVc.homeInfo = SGlobalVars.curHomeInfo
                self.show(adVc, sender: nil)
            case .rgbwBulb ,.rgbwLightStrip :
                let sb = UIStoryboard(name: "Room", bundle: nil)
                let adVc = sb.instantiateViewController(withIdentifier: "TopRGBWLightActionVC") as! TopRGBWLightActionVC
                adVc.deviceInfo = device
                self.show(adVc, sender: nil)
         
                
            case .wifiCurtain:
                let curtainVc = sb.instantiateViewController(withIdentifier: "TopCurtainVC") as! TopSliderAndBtnVC
                self.show(curtainVc, sender: nil)
               
            case .acManage:
                  self.showAirConAlert(cell!, deviceInfo: deviceAckInfo.deviceInfo)
            case .feedbackSwitch1, .feedbackSwitch2, .feedbackSwitch3, .feedbackSwitch4:
               self.showFWActionSheet(cell!, device: deviceAckInfo.deviceInfo)
            case .thinkerPro:
                let sb = UIStoryboard(name: "Macro", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "TopSirenTimePickerVC") as! TopSirenTimePickerVC
                self.show(vc, sender: nil)
                return
            case .thinkerMini:
                let sb = UIStoryboard(name: "Macro", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "TopSirenTimePickerVC") as! TopSirenTimePickerVC
                self.show(vc, sender: nil)
                return
            default:
                break
            }
            
            
        case .BGM:
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let adVc = sb.instantiateViewController(withIdentifier: "TopAISpeakerActionVC") as! TopAISpeakerActionVC
            self.show(adVc, sender: nil)
            break
        default:
            break
        }
    }
    
    func showAirConAlert(_ sourceView: UIView, deviceInfo: GLDeviceInfo) -> Void {
        //设置弹窗
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        //设置动作
        alert.addAction(UIAlertAction(title: NSLocalizedString("Air Conditioner Action", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            //进入遥控添加
            let sb = UIStoryboard(name: "ACManager", bundle: nil)
            let vc: TopACManagerActionVC = sb.instantiateViewController(withIdentifier: "TopACManagerActionVC") as! TopACManagerActionVC
        
            vc.type = GLAirConSubType.ac
            self.show(vc, sender: nil)
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Fresh Air Action", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            //进入遥控添加
            let sb = UIStoryboard(name: "ACManager", bundle: nil)
            let vc: TopACManagerActionVC = sb.instantiateViewController(withIdentifier: "TopACManagerActionVC") as! TopACManagerActionVC
            vc.type = GLAirConSubType.freshAir
           
            self.show(vc, sender: nil)
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Underfloor Heating Action", tableName: "RoomPage"), style: .default, handler: {
            (UIAlertAction) -> Void in
            //进入遥控添加
            let sb = UIStoryboard(name: "ACManager", bundle: nil)
            let vc: TopACManagerActionVC = sb.instantiateViewController(withIdentifier: "TopACManagerActionVC") as! TopACManagerActionVC
            vc.type = GLAirConSubType.underfloorHeating
           
            self.show(vc, sender: nil)
            
        }))
       
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        //显示弹窗
        present(alert, animated: true, completion: nil)
    }
    // MARK: - UICollectionView Highlight
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if collectionView == cardCollectionView {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .lightGray
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.contentView.backgroundColor = .clear
    }
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.cardCollectionView {
            switch section {
            case 0:
                return UIEdgeInsets(top: 0, left: (self.view.width - cardCollectionViewItemW) * 0.5, bottom: 0, right: 20)
            case roomList.count - 1:
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (self.view.width - cardCollectionViewItemW) * 0.5)
            default:
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
            }
            
        }
         return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
      
    }
    
}

    

