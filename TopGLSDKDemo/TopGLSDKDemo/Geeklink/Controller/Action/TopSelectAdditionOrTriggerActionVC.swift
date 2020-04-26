//
//  TopSelectActionVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/21.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

enum TopSelectAdditionOrTriggerActionVCType: Int {
    case add
    case edit
}

class TopSelectAdditionOrTriggerActionVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopSuperCellDelegate {
    
    weak var deleteCell: UITableViewCell?
    weak var selectedCell: TopSuperCell?
    var triggerValues = Array<Int8>()
    var additionValues = Array<Int8>()
    var condition: TopCondition?
    var list = [[TopItem]]()
    weak var showPickerView: PickerView?
    var type: TopSelectAdditionOrTriggerActionVCType = .add
    var selectItem: TopItem?
    var selectedRow: Int32 = -1
    var timeItem = TopItem()
    var delayTime: Int32 = 0
    
    var itemList0 = [TopItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //设置文本
        title = TopDataManager.shared.condition?.device?.deviceName
        
        //设置
        initItemList()
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if showPickerView != nil {
            showPickerView?.frame = (UIApplication.shared.keyWindow?.bounds)!
        }
    }
    //MARK: -
    
    func initItemList() {
        
        list = .init()
        condition = TopDataManager.shared.condition
        delayTime = (condition?.duration)!
        
        var iconList = [String]()
        var titleList = [String]()
        
        for theCondition in (TopDataManager.shared.macro?.triggerConditions)!{
            
            if theCondition.device?.deviceId == condition?.device?.deviceId{
                if condition?.conditionName == "trigger" && theCondition.value == condition?.value{
                    continue
                }
                let value: Int8 = SGlobalVars.conditionHandle.getDoorMotionState(theCondition.value) ? 0 : 1
                triggerValues.append(value)
            }
            
        }
        
        
        for theCondition in (TopDataManager.shared.macro?.additionalConditions)!{
            
            if theCondition.device?.deviceId == condition?.device?.deviceId{
                
                if condition?.conditionName != "trigger" && theCondition.value == condition?.value{
                    continue
                }
                let value: Int8 = SGlobalVars.conditionHandle.getDoorMotionState(theCondition.value) ? 0 : 1
                additionValues.append(value)
            }
            
        }
        if condition?.device?.slaveType == .motionSensor {
            
            self.title = NSLocalizedString("Motion Sensor", tableName: "MacroPage")
            
            iconList.append("scene_youren")
            iconList.append("scene_wuren")
            
            titleList.append(GlobarMethod.getIRName(withValue: 0))
            titleList.append(GlobarMethod.getIRName(withValue: 1))
            
        }
        else if condition?.device?.slaveType == .smokeSensor {
            
            self.title = NSLocalizedString("Non Security Mode", tableName: "MacroPage")
            
            iconList.append("scene_smoke")
            iconList.append("scene_no_smoke")
            
            titleList.append(GlobarMethod.getSmokeSensorName(withValue: 0))
            titleList.append(GlobarMethod.getSmokeSensorName(withValue: 1))
            
        }  else if condition?.device?.slaveType == .waterLeakSensor {
            
            self.title = NSLocalizedString("Water Leak Sensor", tableName: "MacroPage")
            
            iconList.append("scene_leak_weater")
            iconList.append("scene_no_leak_weater")
            
            titleList.append(GlobarMethod.getWaterLeakSensorName(withValue: 0))
            titleList.append(GlobarMethod.getWaterLeakSensorName(withValue: 1))
            
        }
        else if condition?.device?.slaveType == .doorSensor {
            
            self.title = NSLocalizedString("Door magnetic induction", tableName: "MacroPage")
            
            iconList.append("scene_kaimen")
            iconList.append("scene_guanmen")
            
            titleList.append(GlobarMethod.getDoorSensorName(withValue: 0))
            titleList.append(GlobarMethod.getDoorSensorName(withValue: 1))
        }
        
        for index in 0...(iconList.count - 1) {
            let icon: String = iconList[index]
            let title: String = titleList[index]
            let iconItem = TopItem()
            
            if condition?.conditionName == "trigger"{
                if additionValues.count > 0{
                    
                    if additionValues.count == 1{
                        if index != Int((additionValues.first)!) {
                            iconItem.swichOnState = 2
                        }
                    }else{
                        iconItem.swichOnState = 2
                    }
                    
                }
               
                for value in triggerValues {
                    if value == index{
                        iconItem.swichOnState = 1
                    }
                }
            }else{//if condition?.conditionName != "Trigger"
                if triggerValues.count > 0{
                   
                    if triggerValues.count == 1{
                        if index != Int((triggerValues.first)!) {
                            iconItem.swichOnState = 2
                        }
                    }else{
                        iconItem.swichOnState = 2
                    }
                    
                }
                
                if additionValues.count > 0 {
                    if index == Int((additionValues.first)!) {
                        iconItem.swichOnState = 1
                    }else{
                        iconItem.swichOnState = 2
                    }
                }
            }
            iconItem.text = title
            iconItem.icon = icon
            if  iconItem.swichOnState  == 2{
                iconItem.detailedText = NSLocalizedString("Ban", tableName: "MacroPage")
                iconItem.accessoryType = .none
            } else if iconItem.swichOnState == 1 {
                if condition?.conditionName == "trigger"{
                    iconItem.detailedText = NSLocalizedString("Trigger", tableName: "MacroPage")
                } else {
                    iconItem.detailedText = NSLocalizedString("Addition", tableName: "MacroPage")
                }
            } else {
                iconItem.accessoryType = .selectedBtn
                if selectedRow == -1{
                    selectedRow = Int32(index)
                }
            }
            
            itemList0.append(iconItem)
        }
        
        if selectedRow == -1{
            self.navigationItem.rightBarButtonItem = nil
        }
        list.append(itemList0)
        
        if (condition?.device?.slaveType == .doorSensor ||
            condition?.device?.slaveType == .motionSensor) &&
            condition?.conditionName == "trigger"{
            var itemList = [TopItem]()
            timeItem.icon = "scene_time"
            
            timeItem.text =  NSLocalizedString("Duration", tableName: "MacroPage")
            itemList.append(timeItem)
            list.append(itemList)
        }
        
        if type == .edit {
            var itemList1 = [TopItem]()
            let deleteItem = TopItem()//初始化
            deleteItem.text = NSLocalizedString("Delete", tableName: "MacroPage")
           
            itemList1.append(deleteItem)
            list.append(itemList1)
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
    
    
    func deleteCondition(_ view: UIView){
        
        let alertController = UIAlertController(title: NSLocalizedString("Delete", tableName: "MacroPage")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
     
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", tableName: "MacroPage"), style: .destructive, handler: {
            (action) -> Void in
            let currentCondition: TopCondition  = TopDataManager.shared.condition!
            
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
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func processTimerStart(){
        processTimerStart(3.0)
    }
    
    
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
        selectedRow = Int32((cell.indexPath?.row)!)
        
        if selectedCell != nil {
            selectedCell?.setLeftBtnSelected(false)
            selectedCell = cell
            cell.setLeftBtnSelected(true)
            return
        }
        selectedCell = cell
        cell.setLeftBtnSelected(true)
    }
    
    @IBAction func saveBtnDidCilcked(_ sender: Any) {
        
        
        let currentCondition: TopCondition  = TopDataManager.shared.condition!
        var  value = SGlobalVars.conditionHandle.getMacroBoradValueString(Int8(selectedRow + 1))
        switch condition?.device?.slaveType {
        case .macroKey4?, .securityRC?:
            value =  SGlobalVars.conditionHandle.getMacroBoradValueString(Int8(selectedRow + 1))
        case .motionSensor?:
            value = SGlobalVars.conditionHandle.getDoorMotionValueString(selectedRow == 0)
        case .doorSensor?:
            value = SGlobalVars.conditionHandle.getDoorMotionValueString(selectedRow == 0)
        case .smokeSensor?:
            value = SGlobalVars.conditionHandle.getDoorMotionValueString(selectedRow == 0)
        case .waterLeakSensor?:
            value = SGlobalVars.conditionHandle.getDoorMotionValueString(selectedRow == 0)
        default:
            break
        }
        currentCondition.duration = delayTime
        
        currentCondition.value =  value
        
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopAditionVC.classForCoder()) {
                let theVC: TopAditionVC = vc as! TopAditionVC
                let isAdded = theVC.addCondition(currentCondition)
                if isAdded{
                    navigationController?.popToViewController(vc, animated: true)
                    return
                    
                }else{
                    alertMessage(NSLocalizedString("The condition have been added", tableName: "MacroPage"))
                }
            }
        }
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKind(of: TopTriggerVC.classForCoder()) {
                let theVC: TopTriggerVC = vc as! TopTriggerVC
                let isAdded = theVC.addCondition(currentCondition)
                if isAdded{
                    navigationController?.popToViewController(vc, animated: true)
                    return
                    
                }else{
                    alertMessage(NSLocalizedString("The condition have been added", tableName: "MacroPage"))
                }
            }
        }
    }
    
    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemList = list[section]
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if section == 1 {
            if list[section].first!.text == NSLocalizedString("Duration", tableName: "MacroPage") {
                return NSLocalizedString("Duration: The elapsed time of the state after the device status changes.\nFor example, if MotionSensor is set to detect that nobody is turned off after 5 minutes, instead of detecting that nobody is turning off the light immediately, the problem that the light is easily turned off can be solved.", tableName: "MacroPage")
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemList = list[indexPath.section]
        let item =  itemList[indexPath.row]
        if indexPath.section == 0 {
            
            
            let cell: TopSuperCell = TopSuperCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "TopSuperCell")
            cell.setLeftBtnSelected(false)
            cell.indexPath = indexPath
            
            cell.item = item
            
            if indexPath.row == selectedRow{
                cell.setLeftBtnSelected(true)
                selectedCell = cell
            }
            
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        } else {
            if item == timeItem {
                let cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "")
                cell.textLabel?.text = item.text
                cell.imageView?.image = UIImage(named: item.icon)
                
               
                cell.detailTextLabel?.text =  GlobarMethod.getTimeStr(withMin: Int(delayTime))
                cell.accessoryType = .disclosureIndicator
                return cell;
            }
            
            let cell: UITableViewCell = UITableViewCell()
            cell.textLabel?.text = item.text
            cell.textLabel?.textColor = APP_ThemeColor
            cell.textLabel?.frame = cell.contentView.frame
            cell.textLabel?.textAlignment = .center
            deleteCell = cell
            return cell;
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let itemList = list[indexPath.section]
        let item = itemList[indexPath.row]
        if item.swichOnState != 0 {
            return
        }
        if item == self.timeItem {
            self.showDulationPickedView()
            return
        }
        selectItem = item
        weak var weakSelf = self
        item.block(weakSelf!)
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell == deleteCell {
            deleteCondition(cell!)
        } else {
            self.selectedRow = Int32(indexPath.row)
            self.tableView.reloadData()
        }
    }
}



