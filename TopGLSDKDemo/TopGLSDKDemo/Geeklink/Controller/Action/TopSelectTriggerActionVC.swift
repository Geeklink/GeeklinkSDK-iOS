//
//  TopSelectActionVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/21.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

enum TopSelectTriggerActionType: Int {
    case TopSelectTriggerActionTypeAdd
    case TopSelectTriggerActionTypeEdit
}

class TopSelectTriggerActionVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopSuperCellDelegate {
    
    weak var deleteCell: UITableViewCell?
    weak var selectedCell: TopSuperCell?
    var values = Array<Int8>()
    var condition: TopCondition?
    var list = NSMutableArray()
    var type: TopSelectTriggerActionType = .TopSelectTriggerActionTypeAdd
    var selectItem: TopItem?
    var selectedRow :Int32 = -1
    weak var showPickerView: PickerView?
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if showPickerView != nil {
            showPickerView?.frame = (UIApplication.shared.keyWindow?.bounds)!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: -
    
    func initItemList() {
        
        list.removeAllObjects()
        condition = TopDataManager.shared.condition
        delayTime = (condition?.duration)!
        
        var iconList = [String]()
        var titleList = [String]()
        
        for theCondition in (TopDataManager.shared.macro?.triggerConditions)!{
            
            if theCondition.device?.deviceId == condition?.device?.deviceId && theCondition.value != condition?.value{
                var value: Int8 = 0
                switch condition?.device?.slaveType {
                case .macroKey4?, .securityRC?, .some(.feedbackSwitchWithScenario1), .some(.feedbackSwitchWithScenario2), .some(.feedbackSwitchWithScenario3):
                    value =  SGlobalVars.conditionHandle.getMacroBoradRoad(theCondition.value)
             
                default:
                    break
                }
                values.append(value)
            }
            
        }
        
       
        if  condition?.device?.slaveType == .macroKey4 {
            self.title = NSLocalizedString("Scene Switch", tableName: "MacroPage")
            
            iconList.append("scene_a")
            iconList.append("scene_b")
            iconList.append("scene_c")
            iconList.append("scene_d")
    
            
            titleList.append("A")
            titleList.append("B")
            titleList.append("C")
            titleList.append("D")
            
        } else if condition?.device?.slaveType == .securityRC {
            self.title = NSLocalizedString("Security remote control", tableName: "MacroPage")
            
            iconList.append("scene_bufang")
            iconList.append("scene_chefang")
            iconList.append("scene_youren")
            iconList.append("scene_sos")
            titleList.append(GlobarMethod.getSRCName(withValue: Int32(1)))
            titleList.append(GlobarMethod.getSRCName(withValue: Int32(2)))
            titleList.append(GlobarMethod.getSRCName(withValue: Int32(3)))
            titleList.append(GlobarMethod.getSRCName(withValue: Int32(4)))
            
        }else {
            var roadCount = 1;
            if  condition?.device?.slaveType == .some(.feedbackSwitchWithScenario2) {
                roadCount = 2
            }else if condition?.device?.slaveType == .some(.feedbackSwitchWithScenario3) {
                roadCount = 3
            }
            
           
            self.title = condition?.device?.deviceName
            
            if roadCount >= 1 {
                iconList.append("scene_a")
            }
            if roadCount >= 2 {
                iconList.append("scene_b")
            }
            if roadCount >= 3 {
                iconList.append("scene_c")
            }
            if roadCount >= 4 {
                iconList.append("scene_d")
            }
            
        
            
            titleList.append(NSLocalizedString("A", tableName: "MacroPage"))
            titleList.append(NSLocalizedString("B", tableName: "MacroPage"))
            titleList.append(NSLocalizedString("C", tableName: "MacroPage"))
            titleList.append(NSLocalizedString("D", tableName: "MacroPage"))
            
        }
        
        for index in 1...iconList.count {
            let icon: String = iconList[index - 1]
            let title: String = titleList[index - 1]
            let iconItem = TopItem()
            for value in values {
                if value == index {
                     iconItem.isSelected = true
                }
            }
            iconItem.text = title
            iconItem.icon = icon
            if  iconItem.isSelected  == true {
                iconItem.detailedText = NSLocalizedString("Trigger", tableName: "MacroPage")
                iconItem.accessoryType = .none
            } else {
                iconItem.accessoryType = .selectedBtn
                if selectedRow == -1 {
                    selectedRow = Int32(index - 1)
                }
            }
            if condition?.device?.slaveType == .securityRC {
                let stateInfo = SGlobalVars.slaveHandle.getSlaveState(TopDataManager.shared.homeId, deviceIdSub: (condition?.device?.deviceId)!)!
                if stateInfo.safeRCMode == true{
                    if index != 3 {
                         iconItem.accessoryType = .none
                         iconItem.detailedText = NSLocalizedString("Invalid", tableName: "MacroPage")
                    }
                }
            }
            
            
            itemList0.append(iconItem)
        }
        
        if selectedRow == -1{
           self.navigationItem.rightBarButtonItem = nil
        }
        list.add(itemList0)
      
       
        if type == .TopSelectTriggerActionTypeEdit{
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
        var value = SGlobalVars.conditionHandle.getMacroBoradValueString(Int8(selectedRow + 1))
        switch condition?.device?.slaveType {
        case .macroKey4?, .securityRC?:
            value =  SGlobalVars.conditionHandle.getMacroBoradValueString(Int8(selectedRow + 1))
        case .motionSensor?:
            value = SGlobalVars.conditionHandle.getDoorMotionValueString(selectedRow == 0)
        case .doorSensor?:
            value = SGlobalVars.conditionHandle.getDoorMotionValueString(selectedRow == 0)
        default:
            break
        }
        currentCondition.duration = delayTime
        
        currentCondition.value =  value
       
        
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
        if section == 0 {
          
            return NSLocalizedString("Select, please", tableName: "MacroPage")
            
        }
        return ""
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
                
                let str = NSLocalizedString("Min", comment: "")
              
                cell.detailTextLabel?.text = String(format: "%d", delayTime)+" "+str
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
        if item.isSelected {
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



