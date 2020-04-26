//
//  TopFeedfbackSwitchConditionVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/27.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

enum TopFeedfbackSwitchConditionVCType: Int {
    case TopFeedfbackSwitchConditionVCTypeAdd
    case TopFeedfbackSwitchConditionVCTypeEdit
}

class TopFeedfbackSwitchConditionVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopFeedbackSwichCellDelegate {
    
    func feedbackSwichCellClickBtn(_ item: TopItem) {
        
        let itemList = list[0]
        for theItem in itemList {
            if theItem != item{
                theItem.swichIsCol = false
            }
        }
        self.tableView.reloadData()
    }
    weak var showPickerView: PickerView?
    weak var deleteCell: UITableViewCell?
    var condition: TopCondition?
    
    var timeItem = TopItem()
    var delayTime: Int32 = 0
    
    var list = [[TopItem]]()
    var type: TopFeedfbackSwitchConditionVCType = .TopFeedfbackSwitchConditionVCTypeAdd
    var selectItem: TopItem?
    var triggerSwitchColState: Array = [Bool]()
    var additionSwitchColState: Array = [Bool]()
    var switchColState: Array = Array<Int32>()
    @IBOutlet weak var tableView: UITableView!
    
    var selectedRow :Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //设置文本
        
        
        condition = TopDataManager.shared.condition
        
        title = NSLocalizedString("Feedback Switch", tableName: "MacroPage")
        //title = TopDataManager.shared.condition?.device?.deviceName
        //设置
       
        initItemList()
        tableView.register(UINib(nibName: "TopFeedbackSwichCell", bundle: nil), forCellReuseIdentifier: "TopFeedbackSwichCell")
        
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(macroConditionSetResp), name: NSNotification.Name("macroConditionSetResp"), object: nil)
        
        tableView.reloadData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if showPickerView != nil {
            showPickerView?.frame = (UIApplication.shared.keyWindow?.bounds)!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("macroConditionSetResp"), object: nil)
    }
    
    
    func macroActionSetResp(notificatin: Notification) -> Void {//增删改返回
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            
            self.navigationController?.popViewController(animated: true)
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
    
    @objc func macroConditionSetResp(notificatin: Notification) {//请求条件列表回复
        processTimerStop()
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            
            GlobarMethod.notifySuccess()
            self.navigationController?.popViewController(animated: true)
            
        } else {
            GlobarMethod.notifyFailed()
        }
    }
   
    func initItemList(){
        list = .init()
        condition = TopDataManager.shared.condition
        var iconList = [String]()
        self.delayTime = (condition?.duration)!
        iconList.append("room_quick_a_selected")
        iconList.append("room_quick_b_selected")
        iconList.append("room_quick_c_selected")
        iconList.append("room_quick_d_selected")
        
        let totalCount: Int32 = (condition?.switchCount)!
        var itemList0 = [TopItem]()
        for _ in 0...7{
            switchColState.append(0)
            additionSwitchColState.append(false)
            triggerSwitchColState.append(false)
        }
        
        for theCondition in (TopDataManager.shared.macro?.triggerConditions)!{
            
            if theCondition.device?.deviceId == condition?.device?.deviceId && theCondition != condition{
                if theCondition.switchCtrlInfo.aCtrl{
                    if theCondition.switchCtrlInfo.aOn{
                        triggerSwitchColState[0] = true
                    }else{
                        triggerSwitchColState[1] = true
                    }
                }
                else if theCondition.switchCtrlInfo.bCtrl{
                    if theCondition.switchCtrlInfo.bOn{
                        triggerSwitchColState[2] = true
                    }else{
                        triggerSwitchColState[3] = true
                    }
                }
                else if theCondition.switchCtrlInfo.cCtrl{
                    if theCondition.switchCtrlInfo.cOn{
                        triggerSwitchColState[4] = true
                    }else{
                        triggerSwitchColState[5] = true
                    }
                }
                else if theCondition.switchCtrlInfo.dCtrl{
                    if theCondition.switchCtrlInfo.dOn{
                        triggerSwitchColState[6] = true
                    }else{
                        triggerSwitchColState[7] = true
                    }
                }
            }
            
        }
        
        
        for theCondition in (TopDataManager.shared.macro?.additionalConditions)!{
            
            if theCondition.device?.deviceId == condition?.device?.deviceId && theCondition != condition{
                if theCondition.switchCtrlInfo.aCtrl{
                    if theCondition.switchCtrlInfo.aOn{
                       additionSwitchColState[0] = true
                    }else{
                       additionSwitchColState[1] = true
                    }
                }
                else if theCondition.switchCtrlInfo.bCtrl{
                    if theCondition.switchCtrlInfo.bOn{
                       additionSwitchColState[2] = true
                    }else{
                       additionSwitchColState[3] = true
                    }
                }
                else if theCondition.switchCtrlInfo.cCtrl{
                    if theCondition.switchCtrlInfo.cOn{
                        additionSwitchColState[4] = true
                    }else{
                        additionSwitchColState[5] = true
                    }
                }
                else if theCondition.switchCtrlInfo.dCtrl{
                    if theCondition.switchCtrlInfo.dOn{
                        additionSwitchColState[6] = true
                    }else{
                        additionSwitchColState[7] = true
                    }
                }
            }
            
        }
        
        if condition?.conditionName == "trigger"{
            for index in 0...3{
              
                if additionSwitchColState[index * 2] == true{
                    switchColState[index * 2] = 0
                    switchColState[index * 2 + 1] = 3
                }else if additionSwitchColState[index * 2 + 1] == true{
                    switchColState[index * 2] = 3
                    switchColState[index * 2 + 1] = 0
                }
            }
            for index in 0...7{
                if switchColState[index] == 0{
                    switchColState[index] = triggerSwitchColState[index] ? 1 : 0
                }
                
            }
        }else{
            for index in 0...3{
                if triggerSwitchColState[index * 2] && triggerSwitchColState[index * 2 + 1] {
                    switchColState[index * 2] = 1
                    switchColState[index * 2 + 1]  = 1
                }else if triggerSwitchColState[index * 2] {
                    switchColState[index * 2 + 1] = 3
                    switchColState[index * 2] = 0
                }else if triggerSwitchColState[index * 2 + 1] {
                    switchColState[index * 2] = 3
                    switchColState[index * 2 + 1] = 0
                }
                
                if additionSwitchColState[index * 2] {
                    switchColState[index * 2] =  2
                    switchColState[index * 2 + 1]  = 3
                }
                if additionSwitchColState[index * 2 + 1] {
                    switchColState[index * 2] =  3
                    switchColState[index * 2 + 1]  = 2
                }
            }
        }
        
        

        var isSetControl: Bool = false
        for index in 1...totalCount{
            let iconItem = TopItem()
            var icon: String  = ""
            var title: String = ""
            if index <= iconList.count{
                icon = iconList[Int(index) - 1]
                title = SGlobalVars.roomHandle.getSwitchNoteName(TopDataManager.shared.homeId, deviceId: (condition?.device?.deviceId)!, road: index)
                if title.count == 0{
                    title = NSLocalizedString("Switch", tableName: "MacroPage")
                }
            }
            iconItem.text = title
            iconItem.icon = icon
            
            if index == 1{
                iconItem.swichIsOn = (condition?.switchCtrlInfo.aOn)!
                iconItem.swichIsCol = (condition?.switchCtrlInfo.aCtrl)!
                
            }
            else if index == 2{
                iconItem.swichIsOn = (condition?.switchCtrlInfo.bOn)!
                iconItem.swichIsCol = (condition?.switchCtrlInfo.bCtrl)!
                
            }
            else if index == 3{
                iconItem.swichIsOn = (condition?.switchCtrlInfo.cOn)!
                iconItem.swichIsCol = (condition?.switchCtrlInfo.cCtrl)!
                
            }
            else if index == 4{
                iconItem.swichIsOn = (condition?.switchCtrlInfo.dOn)!
                iconItem.swichIsCol = (condition?.switchCtrlInfo.dCtrl)!
                
            }
            iconItem.swichOnState = switchColState[Int(index)*2 - 2]
            iconItem.swichOffState = switchColState[Int(index)*2 - 1]
            if self.type == .TopFeedfbackSwitchConditionVCTypeAdd{
                if isSetControl == false{
                    if iconItem.swichOnState == 0{
                        iconItem.swichIsOn = true
                        iconItem.swichIsCol = true
                        isSetControl = true
                    }
                }
                if isSetControl == false{
                    if iconItem.swichOffState == 0{
                        iconItem.swichIsOn = false
                        iconItem.swichIsCol = true
                        isSetControl = true
                    }
                }
                
            }
            
            iconItem.accessoryType = .disclosureIndicator
            itemList0.append(iconItem)
        }
        if self.type == .TopFeedfbackSwitchConditionVCTypeAdd{
            if isSetControl == false{
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        
        list.append(itemList0)
        
        if condition?.conditionName == "trigger" {
            var itemList = [TopItem]()
            timeItem.icon = "scene_time"
            
            timeItem.text =  NSLocalizedString("Duration", tableName: "MacroPage")
            itemList.append(timeItem)
            list.append(itemList)
        }
        
        if (type == .TopFeedfbackSwitchConditionVCTypeEdit){
            var itemList1 = [TopItem]()
            let deleteItem = TopItem()//初始化
            deleteItem.text =  NSLocalizedString("Delete" , comment: "")
            weak var weakSelf = self
            deleteItem.block = { (vc: UIViewController) in
                weakSelf?.deleteCondition((weakSelf?.deleteCell)!)
            }
            itemList1.append(deleteItem)
            list.append(itemList1)
        }
    }
    
    func deleteCondition(_ view: UIView){
        
        let alert = UIAlertController(title: NSLocalizedString("Delete", comment: "")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
     
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: {
            (action) -> Void in
            let currentCondition = TopDataManager.shared.condition!
         
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopAditionVC.classForCoder()) {
                    let theVC: TopAditionVC = vc as! TopAditionVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopTriggerVC.classForCoder()) {
                    let theVC: TopTriggerVC = vc as! TopTriggerVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        })
        alert.addAction(actionCancel)
        alert.addAction(actionOk)
        present(alert, animated: true, completion: nil)
    }
    
    func processTimerStart(){
        processTimerStart(3.0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
         return ""
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Select, please", tableName: "MacroPage")
        }
        if section == 1 {
            if list[section].first!.text == NSLocalizedString("Duration", tableName: "MacroPage") {
                return NSLocalizedString("Duration: The elapsed time of the state after the device status changes.\nFor example, if MotionSensor is set to detect that nobody is turned off after 5 minutes, instead of detecting that nobody is turning off the light immediately, the problem that the light is easily turned off can be solved.", tableName: "MacroPage")
            }
        }
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemList = list[section]
        return itemList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemList = list[indexPath.section]
        let item: TopItem =  itemList[indexPath.row]
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopFeedbackSwichCell") as! TopFeedbackSwichCell
            cell.item = item
            
            if item ==  itemList.last{
                cell.isLast = true
            }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            if item == timeItem{
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "")
                cell.textLabel?.text = item.text
                cell.imageView?.image = UIImage(named: item.icon)
                cell.detailTextLabel?.text = GlobarMethod.getTimeStr(withMin: Int(delayTime))
                cell.accessoryType = .disclosureIndicator
                return cell;
            }
            
            let cell = UITableViewCell()
            cell.textLabel?.text = item.text
            cell.textLabel?.textColor = APP_ThemeColor
            cell.textLabel?.frame = cell.contentView.frame
            cell.textLabel?.textAlignment = .center
            self.deleteCell = cell
            return cell;
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itemList = list[indexPath.section]
        let item: TopItem = itemList[indexPath.row]
        
        if item == self.timeItem{
            self.showDulationPickedView()
            return
        }
       
        tableView.deselectRow(at: indexPath, animated: true)
       
        selectItem = item
        weak var weakSelf = self
        item.block(weakSelf!)
    }
    
    func changeItemValue(_ item: TopItem, view: UIView) {
        let alert = UIAlertController(title: nil, message:  nil, preferredStyle: .actionSheet)
        
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
        if (alert.popoverPresentationController != nil) {
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        }
        weak var weakSelf = self
        let actionTurnOn = UIAlertAction(title: NSLocalizedString("Turn on", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            item.swichIsCol = true
            item.swichIsOn = true
            weakSelf?.tableView.reloadData()
        })
        let actionTurnOff = UIAlertAction(title: NSLocalizedString("Turn off", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            item.swichIsCol = true
            item.swichIsOn = false
            weakSelf?.tableView.reloadData()
        })
        let actionNOControl = UIAlertAction(title: NSLocalizedString("No control", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            item.swichIsCol = false
            item.swichIsOn = false
            weakSelf?.tableView.reloadData()
        })
        alert.addAction(actionCancel)
        alert.addAction(actionTurnOn)
        alert.addAction(actionTurnOff)
        alert.addAction(actionNOControl)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveCondition() -> Void {
      
        
        let currentCondition: TopCondition  = TopDataManager.shared.condition!
        
        let itemList = list[0]
        var item0: TopItem = TopItem()
        var item1: TopItem = TopItem()
        var item2: TopItem = TopItem()
        var item3: TopItem = TopItem()
        let totalCount: Int32 = (condition?.switchCount)!
        for index in 1...totalCount{
            switch index {
            case 1:
                item0 = itemList[0]
            case 2:
                item1 = itemList[1]
            case 3:
                item2 = itemList[2]
            case 4:
                item3 = itemList[3]
            default:
                break
            }
        }
        
        
        
        let switchCtrlInfo:GLSwitchCtrlInfo = GLSwitchCtrlInfo(rockBack: (condition?.switchCtrlInfo.rockBack)!, aCtrl: item0.swichIsCol, bCtrl: item1.swichIsCol, cCtrl: item2.swichIsCol, dCtrl: item3.swichIsCol, aOn: item0.swichIsOn, bOn: item1.swichIsOn, cOn: item2.swichIsOn, dOn: item3.swichIsOn)
        
        let value = SGlobalVars.conditionHandle.getFBSwicthConditionValue(switchCtrlInfo)
        currentCondition.duration = delayTime
        currentCondition.switchCtrlInfo = switchCtrlInfo
        currentCondition.value = value
        
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAditionVC.classForCoder()) {
                let theVC: TopAditionVC = vc as! TopAditionVC
                let isAdded = theVC.addCondition(currentCondition)
                if isAdded{
                    navigationController?.popToViewController(vc, animated: true)
                    
                }else{
                     self.alertMessage(NSLocalizedString("The condition have been added", tableName: "MacroPage") )
                }
                return
            }
        }
        
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
    
    func showDulationPickedView() -> Void {
        weak var weakSelf = self
        let showPickerView : PickerView = PickerView(frame: (UIApplication.shared.keyWindow?.bounds)!,time: (delayTime), showOnlyValidDates: true, type: .only30Mini)
        
        self.showPickerView = showPickerView
        showPickerView.showInWindow { [unowned self] (time) in
            weakSelf?.delayTime = time
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .none)
        }
    }
    
    
  
    @IBAction func saveBtnDidCilcked(_ sender: Any) {
       
            saveCondition()
       
    }
}





