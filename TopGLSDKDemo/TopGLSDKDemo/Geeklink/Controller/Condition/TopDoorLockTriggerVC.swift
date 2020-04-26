//
//  .swift
//  Geeklink
//
//  Created by YanFeiFei on 2019/5/5.
//  Copyright © 2019 Geeklink. All rights reserved.
//

import UIKit
enum TopDoorLockTriggerVCType:Int {
    case add
    case edit
}
class TopDoorLockTriggerVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource {
    
    var deviceInfo: GLDeviceInfo!
    var roomInfo = GLRoomInfo()
    var type = TopDoorLockTriggerVCType.add
    weak var topLabel: UILabel!
    weak var headerView: UIView!
    weak var topImgView: UIImageView!
    
    private var doorLockPhysicalPasswordList = Array<GLDoorLockPhysicalPassword>.init()
    private var fingerprintUserList = Array<GLDoorLockPhysicalPassword>.init()
    private var cardPwdUserList = Array<GLDoorLockPhysicalPassword>.init()
    private var pwdUserList = Array<GLDoorLockPhysicalPassword>.init()
    private var mixUserList = Array<GLDoorLockPhysicalPassword>.init()
    
    var seletedIDList = Array<Int32>.init()
    var currentSelectedID: Int32 = -1
    
    var selectIndexPath: IndexPath!
    
    var condition: TopCondition?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        condition = TopDataManager.shared.condition
        deviceInfo = (condition?.device?.deviceInfo)!
        currentSelectedID = (TopDataManager.shared.condition?.unlockPWDID)!
        super.viewDidLoad()
        setupRefresh(self.tableView)
        self.title = NSLocalizedString("Physical User", tableName: "DoorLock")
       
        initTableHeaderView()
        self.doorLockPhysicalPasswordList = SGlobalVars.slaveDoorLock.getPhysicalPasswordList(TopDataManager.shared.homeId, deviceId: deviceInfo.deviceId) as! [GLDoorLockPhysicalPassword]
        self.refreshTableViewData()
        
        for trigger in (TopDataManager.shared.macro?.triggerConditions)! {
            if condition == trigger {
                continue
            }
            if trigger.conditionType == .doorLock {
                if trigger.device?.deviceId == self.deviceInfo.deviceId {
                    seletedIDList.append(trigger.unlockPWDID)
                }
            }
        }
        
        if type == .edit {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Delete", comment: ""), style: .done
                , target: self, action: #selector(deleteCondition))
        }
       
        
    }
    @objc func deleteCondition() -> Void {
        let alertController = UIAlertController(title: NSLocalizedString("Delete", tableName: "MacroPage")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
      
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", tableName: "MacroPage"), style: .destructive, handler: {
            (action) -> Void in
            
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopTriggerVC.classForCoder()) {
                    let theVC: TopTriggerVC = vc as! TopTriggerVC
                    theVC.removeCondetion((TopDataManager.shared.condition)!)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            
            
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let img = topImgView.image
        
        topImgView.frame = CGRect.init(x: (self.view.width-(img?.size.width)!) * 0.5, y:32 , width: (img?.size.width)!, height: (img?.size.height)!)
        let tipTextSize = TopDataManager.shared.textSize(text: (topLabel.text)!, font: (topLabel.font)!, maxSize: CGSize.init(width: self.view.width - 32, height: 120))
        topLabel.frame = CGRect.init(x: 16, y: topImgView.frame.maxY + 8, width: self.view.width - 32, height: tipTextSize.height)
        
        self.tableView.tableHeaderView?.frame = CGRect.init(x: 0, y: 0, width: self.view.width, height: topLabel.frame.maxY + 16)
        self.tableView.reloadData()
    }
   
    func initTableHeaderView() -> Void {
        
        let tableViewHeader: UITableViewHeaderFooterView = UITableViewHeaderFooterView.init()
        let img = UIImage.init(named: "doorLock_physicalPwd_big")
        let imgView = UIImageView.init()
        self.topImgView = imgView
        imgView.image = img
        tableViewHeader.contentView.addSubview(imgView)
        
        let tipText = NSLocalizedString("Hint", comment: "")+":"+NSLocalizedString("Select the unlocking user as the trigger scenario execution condition.", tableName: "MacroPage")
        
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = tipText
        self.topLabel = label
        label.textColor = APP_ThemeColor
        tableViewHeader.contentView.addSubview(label)
        self.headerView = tableViewHeader
        tableViewHeader.contentView.backgroundColor = UIColor.white
        self.tableView.tableHeaderView = tableViewHeader
        
        
    }
    
    
    func refreshTableViewData() -> Void {
        self.cardPwdUserList.removeAll()
        self.fingerprintUserList.removeAll()
        self.pwdUserList.removeAll()
        self.mixUserList.removeAll()
        for doorLockAppPassword in doorLockPhysicalPasswordList {
            switch doorLockAppPassword.type {
            case .card:
                self.cardPwdUserList.append(doorLockAppPassword)
            case .fingerprint:
                self.fingerprintUserList.append(doorLockAppPassword)
            case .password:
                self.pwdUserList.append(doorLockAppPassword)
            default: self.mixUserList.append(doorLockAppPassword);
            }
        }
        self.tableView.reloadData()
    }
 
    
    
  
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.cardPwdUserList.count
        case 1:
            return self.fingerprintUserList.count
        case 2:
            return self.pwdUserList.count
        default:
            return self.mixUserList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "")
        let doorLockPhysicalPasswordList: Array<GLDoorLockPhysicalPassword>!
        switch indexPath.section {
        case 0:
            doorLockPhysicalPasswordList = cardPwdUserList
        case 1:
            doorLockPhysicalPasswordList = fingerprintUserList
        case 2:
            doorLockPhysicalPasswordList = pwdUserList
        default:
            doorLockPhysicalPasswordList = mixUserList
        }
        let doorLockPhysicalPassword = doorLockPhysicalPasswordList[indexPath.row]
        if doorLockPhysicalPassword.note.count == 0 {
            cell.textLabel?.text = "(ID:"+String.init(format: "%d", doorLockPhysicalPassword.passwordId)+")"
        }else {
            cell.textLabel?.text = doorLockPhysicalPassword.note
        }
        var detailText = ""
        if currentSelectedID == doorLockPhysicalPassword.passwordId {
            cell.accessoryType = .checkmark
            cell.detailTextLabel?.text = ""
        }else {
            
            for id in seletedIDList {
                if id == doorLockPhysicalPassword.passwordId {
                    detailText = NSLocalizedString("Already Add", tableName: "GuideDevice")
                }
            }
            cell.detailTextLabel?.text = detailText
            cell.accessoryType = detailText == "" ? .disclosureIndicator : .none
        }
       
       
        cell.imageView?.image = UIImage.init(named: "doorLock_user_icon")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return cardPwdUserList.count > 0 ? NSLocalizedString("Card User", tableName: "DoorLock") : ""
        case 1:
            return fingerprintUserList.count > 0 ? NSLocalizedString("Fingerprint User", tableName: "DoorLock") : ""
        case 2:
            return pwdUserList.count > 0 ? NSLocalizedString("Password User", tableName: "DoorLock") : ""
        default:
            return mixUserList.count > 0 ? NSLocalizedString("Mix User", tableName: "DoorLock") : ""
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        
        switch section {
        case 3:
            return mixUserList.count > 0 ? NSLocalizedString("These users mix two ways to unlock.For example, use a card and password to unlock.", tableName: "DoorLock") : ""
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            doorLockPhysicalPasswordList = cardPwdUserList
        case 1:
            doorLockPhysicalPasswordList = fingerprintUserList
        case 2:
            doorLockPhysicalPasswordList = pwdUserList
        default:
            doorLockPhysicalPasswordList = mixUserList
        }
        
        
        let doorLockPhysicalPassword = doorLockPhysicalPasswordList[indexPath.row]
        if doorLockPhysicalPassword.passwordId != currentSelectedID {
            for id in seletedIDList {
                if id == doorLockPhysicalPassword.passwordId {
                    GlobarMethod.notify(withStatus: NSLocalizedString("The condition have been added", tableName: "MacroPage"))
                    return
                }
            }
        }
        
        let currentCondition = (TopDataManager.shared.condition)!
        currentCondition.unlockPWDID = doorLockPhysicalPassword.passwordId
        currentCondition.value = "0"
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopTriggerVC.classForCoder()) {
                let theVC: TopTriggerVC = vc as! TopTriggerVC
                let isAdded = theVC.addCondition(currentCondition)
                if isAdded{
                    navigationController?.popToViewController(vc, animated: true)
                    
                }else{
                    self.alertMessage(NSLocalizedString("The condition have been added", tableName: "MacroPage") )
                }
                return
            }
        }
    
        
    }
    
    
    
    
}
