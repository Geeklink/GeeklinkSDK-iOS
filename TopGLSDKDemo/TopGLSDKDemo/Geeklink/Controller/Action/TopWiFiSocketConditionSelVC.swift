//
//  TopWiFiSocketConditionSelVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/8/16.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopWiFiSocketConditionSelVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopSuperCellDelegate {
    weak var showPickerView: PickerView?
    weak var deleteCell: UITableViewCell?
    weak var selectedCell: TopSuperCell?
    var triggerValues = Array<Int8>()
    var additionValues = Array<Int8>()
    var condition: TopCondition?
    var list = NSMutableArray()
    var type: TopSelectAdditionOrTriggerActionVCType = .add
    var selectItem: TopItem?
    var selectedRow :Int32 = -1
    var timeItem: TopItem = TopItem()
    var delayTime: Int32 = 0
    
    var itemList0 = [TopItem]()
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //设置文本
        title = TopDataManager.shared.condition?.device?.deviceName
        self.alertMessage(NSLocalizedString("Tip: please ensure that the socket and the host are connected in the same network.", tableName: "MacroPage"), withTitle: NSLocalizedString("Hint", comment: ""))
        //设置
        initItemList()
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if showPickerView != nil {
            showPickerView?.frame = (UIApplication.shared.keyWindow?.bounds)!
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: -
    
    func initItemList() {
        
        list.removeAllObjects()
        condition = TopDataManager.shared.condition
        delayTime = (condition?.duration)!
        
        if self.type == .edit {
            let plugConditionInfo: GLPlugConditionInfo = SGlobalVars.conditionHandle.getWiFiSocketConditionInfo(condition?.value)
            
            if !plugConditionInfo.isPowerMode &&  plugConditionInfo.switchCtrlInfo.aOn {
                self.selectedRow = 0
            }
            else if plugConditionInfo.isPowerMode &&  plugConditionInfo.isPowerStart {
                self.selectedRow = 1
            }
            else if plugConditionInfo.isPowerMode &&  !plugConditionInfo.isPowerStart {
                self.selectedRow = 2
            }else{
                self.selectedRow = 3
            }
        }
        
        var iconList = [String]()
        var titleList = [String]()
        
        for theCondition in (TopDataManager.shared.macro?.triggerConditions)!{
            
            if theCondition.device?.deviceId == condition?.device?.deviceId{
                if condition?.conditionName == "trigger" && theCondition.value == condition?.value{
                    continue
                }
                let plugConditionInfo: GLPlugConditionInfo = SGlobalVars.conditionHandle.getWiFiSocketConditionInfo(theCondition.value)
                
                if !plugConditionInfo.isPowerMode &&  plugConditionInfo.switchCtrlInfo.aOn {
                    triggerValues.append(0)//开
                }
                else if plugConditionInfo.isPowerMode &&  plugConditionInfo.isPowerStart {
                    triggerValues.append(1)//开始用电
                }
                else if plugConditionInfo.isPowerMode &&  !plugConditionInfo.isPowerStart {
                    triggerValues.append(2)//停止用电
                }else{
                    triggerValues.append(3)//停止用电
                }
                
            }
            
        }
        
        
        for theCondition in (TopDataManager.shared.macro?.additionalConditions)!{
            
            if theCondition.device?.deviceId == condition?.device?.deviceId{
                
                if condition?.conditionName != "trigger" && theCondition.value == condition?.value{
                    continue
                }
                let plugConditionInfo: GLPlugConditionInfo = SGlobalVars.conditionHandle.getWiFiSocketConditionInfo(theCondition.value)
                
                if !plugConditionInfo.isPowerMode &&  plugConditionInfo.switchCtrlInfo.aOn {
                    additionValues.append(0)//开
                }
                else if plugConditionInfo.isPowerMode &&  plugConditionInfo.isPowerStart {
                    additionValues.append(1)//开始用电
                }
                else if plugConditionInfo.isPowerMode &&  !plugConditionInfo.isPowerStart {
                    additionValues.append(2)//停止用电
                }else{
                    additionValues.append(3)//关
                }
            }
            
        }
        
        
        self.title = NSLocalizedString("Wi-Fi Socket", tableName: "MacroPage")
        
        iconList.append("scene_socket_on")
        iconList.append("scene_socket_electricity")
        iconList.append("scene_socket_notuseelectricity")
        iconList.append("scene_socket_off")
    
        
        titleList.append(NSLocalizedString("ON", tableName: "MacroPage"))
        titleList.append( NSLocalizedString("Start using electricity", tableName: "MacroPage"))
        titleList.append( NSLocalizedString("Stop using electricity", tableName: "MacroPage"))
        titleList.append( NSLocalizedString("OFF", tableName: "MacroPage"))
       
        
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
            }else if iconItem.swichOnState  == 1{
                if condition?.conditionName == "trigger"{
                    iconItem.detailedText = NSLocalizedString("Trigger", tableName: "MacroPage")
                }else{
                    iconItem.detailedText = NSLocalizedString("Addition", tableName: "MacroPage")
                }
            }
            else{
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
        list.add(itemList0)
       
        
        if type == .edit{
            var itemList1 = [TopItem]()
            let deleteItem = TopItem()//初始化
            deleteItem.text =  NSLocalizedString("Delete", tableName: "MacroPage")
            
            itemList1.append(deleteItem)
            list.add(itemList1)
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
        var  value = ""
        let subType: Int32 = (condition?.device?.deviceInfo.subType)!
        let glType: GLGlDevType = GLGlDevType(rawValue: Int(subType))!
        switch glType {
        case .plug, .plugPower, .plugFour:
            var plugConditionInfo: GLPlugConditionInfo = GLPlugConditionInfo(isPowerMode: false, isPowerStart: false, switchCtrlInfo: GLSwitchCtrlInfo(rockBack: false, aCtrl: true, bCtrl: false, cCtrl: false, dCtrl: false, aOn: true, bOn: false, cOn: false, dOn: false))
            if selectedRow == 1 {
                plugConditionInfo = GLPlugConditionInfo(isPowerMode: true, isPowerStart: true, switchCtrlInfo: GLSwitchCtrlInfo(rockBack: false, aCtrl: true, bCtrl: true, cCtrl: true, dCtrl: true, aOn: true, bOn: true, cOn: true, dOn: true))
            }
            else if selectedRow == 2 {
                plugConditionInfo = GLPlugConditionInfo(isPowerMode: true, isPowerStart: false, switchCtrlInfo: GLSwitchCtrlInfo(rockBack: false, aCtrl: true, bCtrl: true, cCtrl: true, dCtrl: true, aOn: true, bOn: true, cOn: true, dOn: true))
            }else if selectedRow == 3 {
                  plugConditionInfo = GLPlugConditionInfo(isPowerMode: false, isPowerStart: false, switchCtrlInfo: GLSwitchCtrlInfo(rockBack: false, aCtrl: true, bCtrl: false, cCtrl: false, dCtrl: false, aOn: false, bOn: false, cOn: false, dOn: false))
            }
            value = SGlobalVars.conditionHandle.getWiFiSocketConditionValue(plugConditionInfo)
        default: break
            
        }
        
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
        let itemList: Array = list[section] as! Array<TopItem>
        return  itemList.count
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("Tip: please ensure that the socket and the host are connected in the same network.", tableName: "MacroPage")
    }
    
   
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
        
    }
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemList: Array = list[indexPath.section] as! Array<TopItem>
        let item: TopItem =  itemList[indexPath.row]
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
            if item == timeItem{
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
        
        let itemList: Array = list[indexPath.section] as! Array<TopItem>
        let item: TopItem = itemList[indexPath.row]
        if item.swichOnState != 0 {
            return
        }
        if item == self.timeItem{
            self.showDulationPickedView()
            return
        }
        selectItem = item
        weak var weakSelf = self
        item.block(weakSelf!)
        
        let cell = tableView.cellForRow(at: indexPath)
        if cell == deleteCell {
            deleteCondition(cell!)
        }else{
            self.selectedRow = Int32(indexPath.row)
            self.tableView.reloadData()
        }
        
        
    }
    
}



