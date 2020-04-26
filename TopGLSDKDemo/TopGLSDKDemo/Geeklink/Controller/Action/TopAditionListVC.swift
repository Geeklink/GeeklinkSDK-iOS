//
//  TopAddRestrictiveVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/9.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopAditionListVC:   TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopSuperCellDelegate{


    var conditionList: NSMutableArray =
        NSMutableArray()
    var backVC: UIViewController?
    weak var outoMacroItem :TopItem!
    
    
    @IBOutlet weak var tableView: UITableView!
    
//    var macro: TopMacro?
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //设置文本
        title = NSLocalizedString("Restrictive condition", tableName: "MacroPage")
        initItemList()
        
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
       
        if self.backVC != nil {
            let backItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .done, target: self, action: #selector(backItemDidclicked))
            backItem.tintColor = UIColor.white
            
            navigationItem.leftBarButtonItem = backItem
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func backItemDidclicked(_ view: UIView) -> Void {
        self.navigationController?.popToViewController((self.backVC)!, animated: true)
    }
    //MARK: -
    
    func addCondition(_ condition: TopCondition){
        let currentCondition: TopCondition  = TopDataManager.shared.condition!
        let conditionInfo =  GLConditionInfo(type: .device, md5: currentCondition.md5, subId: currentCondition.subId, value: currentCondition.value, time: 0, week: 0 , begin: 0, end: 0, duration: 0, unlockPWDID: 0, securityType: .none)
        currentCondition.conditionInfo = conditionInfo
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAditionVC.classForCoder()) {
                let theVC: TopAditionVC = vc as! TopAditionVC
                let isAdded = theVC.addCondition(condition)
                if isAdded{
                    navigationController?.popToViewController(vc, animated: true)
                    
                }else{
                     self.alertMessage(NSLocalizedString("The condition have been added", tableName: "MacroPage") )
                }
                return
            }
        }
    }
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
        
    }
    
    func initItemList(){
        
        //   let  deviceList = SGlobalVars.roomHandle.getDeviceListAll(homeInfo.homeId) as! [GLDeviceInfo]
      
        let deviceList =  TopDataManager.shared.resetDeviceInfo()
        var isHasVivalTimeCondition: Bool = false
        var isHasSecurityCondition = false
        let conditions: NSMutableArray = NSMutableArray()
        let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
        
        for device in deviceList {
            
            
            if hostSubType == .thinkerMini {
                if device.md5 != TopDataManager.shared.hostDeviceInfo?.md5 {
                    continue
                }
            }
            
            let condition :TopCondition = TopCondition()
            condition.conditionName = "additional"
            condition.device = device
            
            condition.isSelected = false
            if  (condition.conditionType == .unknow) || (condition.conditionType == .thirdParty)   || (condition.conditionType == .macroPanel)  || (condition.conditionType == .smartRC) ||  (condition.conditionType == .socket) ||  (condition.conditionType == .doorLock) {
                continue
            }
            
           
            for theCondition in (TopDataManager.shared.macro?.triggerConditions)!{
                
                if theCondition.device?.deviceId == condition.device?.deviceId{
                    if (condition.conditionType == .thirdParty) ||  (condition.conditionType == .tempAndHum) {
                        condition.isSelected = true
                        break
                    }
                    
                    if (condition.conditionType == .macroPanel) {
                        if (theCondition.device?.slaveType == .macroKey1){
                            condition.isSelected = true
                            break
                        }
                    }
                }
                
            }
            
            
            
            for theCondition in (TopDataManager.shared.macro?.additionalConditions)!{
                
                if theCondition.conditionType == .effectiveTime{
                    isHasVivalTimeCondition = true
                    break
                }
                if theCondition.conditionType == .securityMode{
                    isHasSecurityCondition = true
                    break
                }
             
                if theCondition.device?.deviceId == condition.device?.deviceId{
                    if (condition.conditionType == .thirdParty) ||  (condition.conditionType == .tempAndHum) {
                        condition.isSelected = true
                        break
                    }
                    
                    if (condition.conditionType == .macroPanel) {
                        if (theCondition.device?.slaveType == .macroKey1){
                            condition.isSelected = true
                            break
                        }
                    }
                }
                
            }
            conditions.add(condition)
          
          
        }
        
        let timeCondition: TopCondition = TopCondition()
        timeCondition.conditionType = .effectiveTime
        timeCondition.usefulTime.weekDayType = .everyDay
        timeCondition.isSelected = isHasVivalTimeCondition
        timeCondition.usefulTime.endTime = 1439
        conditions.add(timeCondition)
        
        let securityCondition: TopCondition = TopCondition()
        securityCondition.conditionType = .securityMode
        securityCondition.conditionName = "additional"
        securityCondition.isSelected = isHasSecurityCondition
        conditions.add(securityCondition)
        
        
        let count: Int = TopConditionType.count.rawValue
        
        for indexT  in 0...count {
            
            let newconditionList: TopConditionList =  TopConditionList()
            newconditionList.conditionType = TopConditionType(rawValue: indexT)
            
            var indexC: Int = 0
            var contain: Bool = false
            while indexC <  conditions.count{
                let condition :TopCondition = conditions[indexC] as! TopCondition
                if condition.conditionType == newconditionList.conditionType{
                    newconditionList.conditionList.add(condition)
                    contain = true
                }
                indexC += 1
            }
            if contain {
                conditionList.add(newconditionList)
            }
        }
        // 添加时间条件
        
        var isHasLocationCondition = false
        for theCondition in (TopDataManager.shared.macro?.additionalConditions)!{
            if theCondition.conditionType == .location{
                isHasLocationCondition = true
                break;
                
            }
        }
        
        if isHasLocationCondition == false {
            for theCondition in (TopDataManager.shared.macro?.triggerConditions)!{
                if theCondition.conditionType == .location{
                    isHasLocationCondition = true
                    break;
                }
            }
        }
        let locationPartsList = SGlobalVars.roomHandle.getLocationPartList((SGlobalVars.curHomeInfo.homeId)!) as! [GLDeviceInfo]
        
        
        if locationPartsList.count > 0 {
            let newconditionList: TopConditionList =  TopConditionList()
            newconditionList.conditionType = TopConditionType.location
            
            let condition :TopCondition = TopCondition.init()
            condition.conditionName = "trigger"
            condition.conditionType = TopConditionType.location
            var name = NSLocalizedString("Location", tableName: "MacroPage")
            let mutAttStr: NSMutableAttributedString = NSMutableAttributedString(string:name)
            mutAttStr.addAttributes([NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black], range: NSMakeRange(0, (name.utf16.count)))

            condition.nameAndPlaceSlelectAtt =  mutAttStr
             condition.nameAndPlaceAtt =  mutAttStr
            condition.icon = GlobarMethod.getGLDevImg(GLGlDevType.accessory, isBig: false, isOnline: true)
            if isHasLocationCondition {
                condition.isSelected = true
            }
            newconditionList.conditionList.add(condition)
            conditionList.add(newconditionList)
        }
        
        
        
        //清除空白横线
        tableView.tableFooterView = UIView()
 
    }
    
    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return conditionList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let Condition: TopConditionList = conditionList[section] as! TopConditionList
        return Condition.title
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let Condition: TopConditionList = conditionList[section] as! TopConditionList
        return Condition.conditionList.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 44
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let Condition = conditionList[indexPath.section] as! TopConditionList
        
        let condition = Condition.conditionList[indexPath.row] as! TopCondition
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "")
//        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = condition.icon
        cell.textLabel?.attributedText = condition.nameAndPlaceSlelectAtt
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        if condition.isSelected{
            cell.accessoryType = .none
            if condition.conditionType == .location {
                cell.detailTextLabel?.text = NSLocalizedString("Ban", tableName: "MacroPage")
            } else {
                cell.detailTextLabel?.text = NSLocalizedString("Has been added", tableName: "MacroPage")
            }
        } else {
            cell.detailTextLabel?.text = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ConditionList = conditionList[indexPath.section] as! TopConditionList
        let condition = ConditionList.conditionList[indexPath.row] as! TopCondition
        if condition.isSelected {
            return
        }
        if condition.conditionType == .effectiveTime {
            selecteCondition(condition)
            return
        }
        if condition.conditionType == .securityMode {
            selecteCondition(condition)
            return
        }
        
        if condition.device?.mainType == .slave {
            if condition.device?.md5 != SGlobalVars.curHomeInfo.ctrlCenter {
                let deviceAckInfoList = TopDataManager.shared.resetDeviceInfo()
                var glDeviceInfo: TopDeviceAckInfo?
                for deviceAckInfo in deviceAckInfoList {
                    if deviceAckInfo.mainType == .geeklink {
                        if deviceAckInfo.md5 ==  condition.device?.md5 {
                            glDeviceInfo = deviceAckInfo
                            break
                        }
                    }
                }
                
                if glDeviceInfo != nil {
                    
                    let alert = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Please make sure that the  %@'s host (%@) is in the same Wi-Fi LAN as the home host(%@).", tableName:"HomePage"), (condition.device?.deviceName)! ,(glDeviceInfo?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                    
                    //设置动作
                    
                    let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
                        (UIAlertAction) -> Void in
                        self.selecteCondition(condition)
                    })
                    //显示弹窗
                    let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                    alert.addAction(cancel)
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                    
                    return
                }
                
            }
        }else {
            if condition.device?.md5 != SGlobalVars.curHomeInfo.ctrlCenter {
                
                let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message:  String.init(format: NSLocalizedString("Make sure %@ and the home host (%@) is connect to same network", tableName: "MacroPage"), (condition.device?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    self.selecteCondition(condition)
                    
                })
                
                
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
                return
            }
        
        }
        
        self.selecteCondition(condition)
        
        
    
    }
    
    func selecteCondition(_ condition: TopCondition ) -> Void {
        if condition.conditionType == .effectiveTime {
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let setUsefulTime: TopSetUsefulTimeVC = sb.instantiateViewController(withIdentifier: "TopSetUsefulTimeVC") as! TopSetUsefulTimeVC
            TopDataManager.shared.condition = condition
            setUsefulTime.type = .UsefunTimerVCTypeConditionAdd
            self.show(setUsefulTime, sender: nil)
            
        }else if condition.conditionType == .securityMode{
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopSecurityConditionVC = sb.instantiateViewController(withIdentifier: "TopSecurityConditionVC") as! TopSecurityConditionVC
            TopDataManager.shared.condition = condition
            vc.type = .add
            self.show(vc, sender: nil)
            return
        }
        else{
            condition.block(self)
        }
        
        
        if (condition.conditionType == .infraredInduction) || (condition.conditionType == .doorMagneticiInduction) || (condition.conditionType == .smokeInduction) || (condition.conditionType == .waterLeakageInduction) {
            TopDataManager.shared.condition = condition
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let selectActionVC: TopSelectAdditionOrTriggerActionVC = sb.instantiateViewController(withIdentifier: "TopSelectAdditionOrTriggerActionVC") as! TopSelectAdditionOrTriggerActionVC
            TopDataManager.shared.condition = condition
            self.show(selectActionVC, sender: nil)
        } else  if (condition.conditionType == .feedbackSwitch  || condition.conditionType == .some(.socket_macroPanel)){
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let feedbackSwitchSetVC: TopFeedfbackSwitchConditionVC = sb.instantiateViewController(withIdentifier: "TopFeedfbackSwitchConditionVC") as! TopFeedfbackSwitchConditionVC
            
            condition.switchCtrlInfo = GLSwitchCtrlInfo(rockBack: false, aCtrl: false, bCtrl: false, cCtrl: false, dCtrl: false, aOn: false, bOn: false, cOn: false, dOn: false)
            TopDataManager.shared.condition = condition
            feedbackSwitchSetVC.type = .TopFeedfbackSwitchConditionVCTypeAdd
            self.show(feedbackSwitchSetVC, sender: nil)
            
            return
            
        }else  if (condition.conditionType == .socket){
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let wifiSocketConditionSelVC: TopWiFiSocketConditionSelVC = sb.instantiateViewController(withIdentifier: "TopWiFiSocketConditionSelVC") as! TopWiFiSocketConditionSelVC
            
            condition.switchCtrlInfo = GLSwitchCtrlInfo(rockBack: false, aCtrl: false, bCtrl: false, cCtrl: false, dCtrl: false, aOn: false, bOn: false, cOn: false, dOn: false)
            TopDataManager.shared.condition = condition
            wifiSocketConditionSelVC.type = .add
            self.show(wifiSocketConditionSelVC, sender: nil)
            return
            
        }
            
        else  if condition.conditionType == .thirdParty{
            TopDataManager.shared.condition = condition
            self.addCondition(condition)
            self.navigationController?.popViewController(animated: true)
        }
            
        else  if condition.conditionType == .tempAndHum{
            condition.type = .temperature
            TopDataManager.shared.condition = condition
            
            self.performSegue(withIdentifier: "TopTemAndHumSetVC", sender: nil)
        }
        else  if condition.conditionType == .location{
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopLocationAdditionVC = sb.instantiateViewController(withIdentifier: "TopLocationAdditionVC") as! TopLocationAdditionVC
            self.show(vc, sender: nil)
        }
    }
}


