//
//  TopLocationAdditionVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/9/28.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopLocationAdditionVC:  TopSuperVC, UITableViewDelegate, UITableViewDataSource , TopSuperCellDelegate{
   
    weak var deleteCell: UITableViewCell?
    @IBOutlet weak var tableView: UITableView!
    var delayTime: Int32 = 0
    var selectIndexPach: IndexPath!
    weak var showPickerView: PickerView?
    var condition: TopCondition?
    var specialItem = Array<TopItem>.init()
    var isEnter: Bool = false
    var deviceAckInfoList = Array<TopDeviceAckInfo>.init()
    var tempMD5: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        selectIndexPach = IndexPath.init(row: 0, section: 0)
        if  condition != nil{
           
            let type: Int32 = Int32(SGlobalVars.conditionHandle.getLocationType(condition?.value))
            let event: Bool = SGlobalVars.conditionHandle.getLocationEvent(condition?.value)
            delayTime = (condition?.duration)!
            if type == 0 {
                selectIndexPach = event == true ? IndexPath.init(row: 0, section: 0) : IndexPath.init(row: 1, section: 0)
            }
            if type == 3 {
                selectIndexPach = event == true ? IndexPath.init(row: 2, section: 0) : IndexPath.init(row: 3, section: 0)
            }
            if type == 1 {
                selectIndexPach = IndexPath.init(row: 4, section: 0)
            }else {
                tempMD5 = condition?.md5
                isEnter = event
            }
        }
        self.title = NSLocalizedString("Location",  tableName: "MacroPage")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(doneDidClicked))
        self.getRefreshData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if showPickerView != nil {
            showPickerView?.frame = (UIApplication.shared.keyWindow?.bounds)!
        }
    }
    @objc func doneDidClicked() -> Void {
        
        
        var type: Int8 = 0
        var event: Bool = false
        var selectDevice: TopDeviceAckInfo!
        if selectIndexPach.section == 0 {
            /**获取定位条件String(用于条件)(type:0全部配件/1任意配件/2指定配件/3配件每次(3限触发事件))(event: true进入/false离开) */
            switch selectIndexPach.row {
            case 0:
                type = 0
                event = true
            case 1:
                type = 0
                event = false
            case 2:
                type = 3
                event = true
            case 3:
                type = 3
                event = false
            case 4:
                type = 1
                event = true
            default:
                break
            }  
        }
        
        if selectIndexPach.section == 1 {
            type = 2
            event = self.isEnter
            selectDevice = self.deviceAckInfoList[selectIndexPach.row]
            
        }
        
        var currentCondition = TopCondition.init()
        if condition != nil {
            currentCondition = condition!
        }
        currentCondition.conditionName = "additional"
        currentCondition.type = .location
        currentCondition.duration = self.delayTime
        currentCondition.value =  SGlobalVars.conditionHandle.getLocationValueString(type, event: event)
        if selectIndexPach.section == 1{
            currentCondition.device = selectDevice
        }else {
            let deviceInfo = GLDeviceInfo.init(deviceId: -1, name: "", mainType: GLDeviceMainType.geeklink, md5: "", subType: Int32(GLGlDevType.accessory.rawValue), subId: 0, camUid: "", camAcc: "", camPwd: "", roomId: 0, roomOrder: 0, valid: false)
            let deviceAckInfo = TopDeviceAckInfo.init()
            deviceAckInfo.deviceInfo = deviceInfo
            currentCondition.device = deviceAckInfo
        }
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAditionVC.classForCoder()) {
                let theVC: TopAditionVC  = vc as! TopAditionVC
                if condition == nil {
                    let _ = theVC.addCondition(currentCondition)
                }
                navigationController?.popToViewController(theVC, animated: true)
                return
                
            }
        }
    }
    override func getRefreshData() {
        
        self.deviceAckInfoList.removeAll()
        self.specialItem.removeAll()
        var titleList = [String].init()
        titleList.append("All parts inside")
        titleList.append("All parts outside")
        
        for title in titleList {
            let item = TopItem.init()
            item.text =  NSLocalizedString(title, tableName: "MacroPage")
            item.accessoryType = .selectedBtn
            specialItem.append(item)
        }
        
        var index: Int = 0
        let locationPartsList = SGlobalVars.roomHandle.getLocationPartList((SGlobalVars.curHomeInfo.homeId)!) as! [GLDeviceInfo]
        for deviceInfo in locationPartsList{
          
            let deviceAckInfo = TopDeviceAckInfo.init()
            deviceAckInfo.deviceInfo = deviceInfo
            self.deviceAckInfoList.append(deviceAckInfo)
            if tempMD5 != nil {
                if self.tempMD5 == deviceAckInfo.md5 {
                    selectIndexPach = IndexPath.init(row: index, section: 1)
                }
            }
            index += 1

        }
        self.resetSelected(selectIndexPach)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return condition == nil ? 2 : 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch  section{
      
        case 0:
            return specialItem.count
        case 1:
            return deviceAckInfoList.count
        default :
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
      
        case 0:
            let item = self.specialItem[indexPath.row]
            let cell = TopSuperCell.init(style: .value1, reuseIdentifier: "")
            cell.item = item
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
            
        case 1:
            let deviceInfo = self.deviceAckInfoList[indexPath.row]
            let cell :UITableViewCell = UITableViewCell.init(style: .value1, reuseIdentifier: "")
            cell.imageView?.image = deviceInfo.icon
            cell.textLabel?.text = deviceInfo.deviceName
            cell.accessoryType = .disclosureIndicator
            if deviceInfo.isSelected {
                cell.detailTextLabel?.text = isEnter ? NSLocalizedString("Inside", tableName: "MacroPage") : NSLocalizedString("Outside", tableName: "MacroPage")
            }
            
            
            return cell
        default :
            break
            
        }
        
        let cell: UITableViewCell = UITableViewCell()
        cell.textLabel?.text = NSLocalizedString("Delete", comment: "")
        cell.textLabel?.textColor = APP_ThemeColor
        cell.textLabel?.frame = cell.contentView.frame
        cell.textLabel?.textAlignment = .center
        self.deleteCell = cell
        return cell;
    }
    
  
    
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
            
        case 0:
            return NSLocalizedString("Additional conditions for any parts", tableName: "MacroPage")
        case 1:
            return NSLocalizedString("Additional conditions for specify parts", tableName: "MacroPage")
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
       
        case 0:
            self.resetSelected(indexPath)
        case 1:
            self.showPartsAdditionAlert(indexPath)
        default:
            self.deleteCondition()
            break
        }
        
    }
    
    func deleteCondition(){
        
        let alertController = UIAlertController(title: NSLocalizedString("Delete", comment: "")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: {
            (action) -> Void in
            let currentCondition: TopCondition  = TopDataManager.shared.condition!
            
            
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopTriggerVC.classForCoder()) {
                    let theVC: TopAditionVC = vc as! TopAditionVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            
            
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
        
    }
    func showPartsAdditionAlert(_ indexPath: IndexPath) -> Void {
        let cell = self.tableView.cellForRow(at: indexPath)
        let deviceAckInfo = self.deviceAckInfoList[indexPath.row]
        let alertController = UIAlertController(title: deviceAckInfo.deviceName, message:  nil, preferredStyle: .actionSheet)
        
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = (cell)!
            alertController.popoverPresentationController?.sourceRect = (cell?.bounds)!
        }
        
        let actionInside = UIAlertAction(title: NSLocalizedString("Inside", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            self.isEnter = true
            self.resetSelected(indexPath)
        })
        
        let actionOutside = UIAlertAction(title: NSLocalizedString("Outside", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            self.isEnter = false
            self.resetSelected(indexPath)
        })
        
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionInside)
        alertController.addAction(actionOutside)
        present(alertController, animated: true, completion: nil)
        
    }
    func resetSelected(_ indexPath: IndexPath) -> Void {
        
        switch selectIndexPach.section {
        case 0:
            let item = self.specialItem[selectIndexPach.row]
            item.isSelected = false
        case 1:
            let deviceInfo = self.deviceAckInfoList[selectIndexPach.row]
            deviceInfo.isSelected = false
        default:
            break
            
        }
        
        switch indexPath.section {
        case 0:
            let item = self.specialItem[indexPath.row]
            item.isSelected = true
        case 1:
            let deviceInfo = self.deviceAckInfoList[indexPath.row]
            deviceInfo.isSelected = true
        default:
            break
            
        }
        self.selectIndexPach = indexPath
        self.tableView.reloadData()
    }
    func showDulationPickedView() -> Void {
       
        let showPickerView : PickerView = PickerView(frame: (UIApplication.shared.keyWindow?.bounds)!,time: (delayTime), showOnlyValidDates: true, type: .only30Mini)
        self.showPickerView = showPickerView
        
        showPickerView.showInWindow { [unowned self] (time) in
            self.delayTime = time
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
    }
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
        self.resetSelected(cell.indexPath!)
    }
    
    
}
