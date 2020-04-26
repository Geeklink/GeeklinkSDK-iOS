//
//  TopStartConditionVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/12.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopTriggerVC:  TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopTimingConditionCellDelegate, TopConditionCellDelegate {
  
    var editItem: UIBarButtonItem!
    var doneItem: UIBarButtonItem!

    var conditionList = [TopCondition]()
    var backVC: UIViewController?
    weak var outoMacroItem: TopItem!
    weak var textInputCell: TopTextInputCell!
    weak var addCell: UITableViewCell!
    
    var isChanged = false
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - UITableView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置文本
        title = NSLocalizedString("Trigger Event", tableName: "MacroPage")
        
        
        tableView.register(UINib(nibName: "TopConditionCell", bundle: nil), forCellReuseIdentifier: "TopConditionCell")
        tableView.register(UINib(nibName: "TopTimingConditionCell", bundle: nil), forCellReuseIdentifier: "TopTimingConditionCell")
        
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(editItemDidclicked))
        editItem  = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItemDidclicked))
        
        let backItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .done, target: self, action: #selector(backItemDidclicked))
        backItem.tintColor = UIColor.white
        
        navigationItem.leftBarButtonItem = backItem
        //navigationItem.rightBarButtonItems = []
        
        //假数据
       // initItemList()
   
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
        navigationItem.backBarButtonItem?.action = #selector(backItemDidclicked)
        let macro = TopDataManager.shared.macro
        if macro?.triggerConditions.count == 0 {
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let iVc: TopTriggerListVC = sb.instantiateViewController(withIdentifier: "TopTriggerListVC") as! TopTriggerListVC
            if backVC != nil {
                iVc.backVC = backVC
            }
            self.show(iVc, sender: nil)
            
        }
        getRefreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let macro = TopDataManager.shared.macro
        macro?.triggerConditions = conditionList
      
    }
    
    @objc func editItemDidclicked(_ sender: Any) {
        
        self.tableView.isEditing = !self.tableView.isEditing
        //resetrightBarButtonItems()
        self.tableView.reloadData()
    }
    

    @objc func backItemDidclicked(_ view: UIView) -> Void {
        if isChanged == true{
            TopDataManager.shared.isChanged = true
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    override func getRefreshData() {
        let macro = TopDataManager.shared.macro
        conditionList = (macro?.triggerConditions)!
        tableView.reloadData()
      
        //self.resetrightBarButtonItems()
    }
    

    //MARK: - UITableView
    

    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return conditionList.count
        } else {
            if self.tableView.isEditing {
                return 0
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let condition = conditionList[indexPath.row]
            if condition.conditionType != .time {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopConditionCell") as! TopConditionCell
                cell.condition = condition
                cell.delegate = self
                if tableView.isEditing{
                    cell.editBtn.isHidden = true
                } else {
                    cell.editBtn.isHidden = false
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopTimingConditionCell") as! TopTimingConditionCell
                 cell.condition = condition
                 cell.delegate = self
                 cell.editBtn.isHidden = tableView.isEditing
          
                return cell
            }
        }
        let cell: TopAddCell = TopAddCell(style: .default, reuseIdentifier: "")
        cell.setTitle(title: conditionList.count == 0 ? NSLocalizedString("Add Trigger", tableName: "MacroPage") : NSLocalizedString("Add More Trigger", tableName: "MacroPage"))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
            switch hostSubType {
            case .thinker, .thinkerPro:
                if self.conditionList.count >= 20 {
                    GlobarMethod.notifyFullError()
                    return
                }
            case .thinkerMini:
                if self.conditionList.count >= 4 {
                    GlobarMethod.notifyFullError()
                    return
                }
            default:
                break
            }
            self.performSegue(withIdentifier: "TopTriggerListVC", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let condition = self.conditionList[indexPath.row]
            TopDataManager.shared.condition = condition
            let cell = tableView.cellForRow(at: indexPath)
            self.deleteCondition(cell!)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        isChanged = true
        swap(&conditionList[sourceIndexPath.row], &conditionList[destinationIndexPath.row])
        self.tableView.reloadData()
    
    }
    
    //MARK: -

    func deleteCondition(_ view: UIView){
        
        let alertController = UIAlertController(title: NSLocalizedString("Delete", comment: "")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = view.bounds
        }
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: {
            (action) -> Void in
    
            let currentCondition: TopCondition  = TopDataManager.shared.condition!
            weakSelf?.removeCondetion(currentCondition)
            if weakSelf?.conditionList.count == 0{
               // weakSelf?.editItemDidclicked(weakSelf?.editItem as Any)
            }
          
          
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
        
    }
    
    func processTimerStart(){
        processTimerStart(3.0)
    }
   
    
    func timingConditionCellDidClickedEditButton(condition: TopCondition) {
      
        let sb = UIStoryboard(name: "Macro", bundle: nil)
        let timerVC: TopTimerVC = sb.instantiateViewController(withIdentifier: "TopTimerVC") as! TopTimerVC
        TopDataManager.shared.condition = condition
        timerVC.type = .TopTimerVCTypeConditionEdit
        timerVC.timerModel = condition.timerModel
        self.show(timerVC, sender: nil)
        
    }
  
    func conditionCellDidClickedEditButton(_ cell: TopConditionCell) {
   
        let condition = cell.condition
        if condition?.device == nil{
            TopDataManager.shared.condition = condition
            deleteCondition(cell)
            return
        }
        if condition?.device?.slaveType == .macroKey1{
            TopDataManager.shared.condition = condition
            deleteCondition(cell)
            return
        }
        if condition?.device?.slaveType == .shakeSensor{
            TopDataManager.shared.condition = condition
            deleteCondition(cell)
            return
        }
        
        
        switch condition?.conditionType {
        case .feedbackSwitch?:
            
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let feedbackSwitchSetVC: TopFeedfbackSwitchConditionVC = sb.instantiateViewController(withIdentifier: "TopFeedfbackSwitchConditionVC") as! TopFeedfbackSwitchConditionVC
            TopDataManager.shared.condition = condition
            feedbackSwitchSetVC.type = .TopFeedfbackSwitchConditionVCTypeEdit
            self.show(feedbackSwitchSetVC, sender: nil)
            return
        case .thirdParty?:
            TopDataManager.shared.condition = condition
            deleteCondition(cell)
            return
            
        case .tempAndHum? :
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let temAndHumSetVC: TopTemAndHumSetVC = sb.instantiateViewController(withIdentifier: "TopTemAndHumSetVC") as! TopTemAndHumSetVC
            TopDataManager.shared.condition = condition
            temAndHumSetVC.type = .TopTemAndHumSetVCTypeEdit
            self.show(temAndHumSetVC, sender: nil)
            return
        case .location?:
             TopDataManager.shared.condition = condition
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopLocationTriggerVC = sb.instantiateViewController(withIdentifier: "TopLocationTriggerVC") as! TopLocationTriggerVC
             
            vc.condition = condition
            self.show(vc, sender: nil)
            return
        default:
            break
        }
        if condition?.conditionType == .some(.socket_macroPanel) {
            self.showSelectfeedbackSwitchOrScenario(cell, condition: condition!)
            return
        }
        
        
        if (condition?.conditionType == .socket){
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let wifiSocketConditionSelVC: TopWiFiSocketConditionSelVC = sb.instantiateViewController(withIdentifier: "TopWiFiSocketConditionSelVC") as! TopWiFiSocketConditionSelVC
            
            TopDataManager.shared.condition = condition
            wifiSocketConditionSelVC.type = .edit
            self.show(wifiSocketConditionSelVC, sender: nil)
            return
            
        }
        
        switch condition?.device?.slaveType {
            
        case .macroKey4?, .securityRC?:
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let selectActionVC: TopSelectTriggerActionVC = sb.instantiateViewController(withIdentifier: "TopSelectTriggerActionVC") as! TopSelectTriggerActionVC
            TopDataManager.shared.condition = condition
            selectActionVC.type = .TopSelectTriggerActionTypeEdit
            var selectRro: Int = 0
            if (condition?.device?.slaveType == .macroKey4) {
                selectRro = Int(SGlobalVars.conditionHandle.getMacroBoradRoad(condition?.value)) - 1
            } else if (condition?.device?.slaveType == .securityRC) {
                selectRro = Int(SGlobalVars.conditionHandle.getMacroBoradRoad(condition?.value)) - 1
            }
            selectActionVC.selectedRow = Int32(selectRro)
            navigationController?.show(selectActionVC, sender: nil)
        case .doorSensor?,.motionSensor?, .smokeSensor?, .waterLeakSensor?:
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let selectActionVC = sb.instantiateViewController(withIdentifier: "TopSelectAdditionOrTriggerActionVC") as! TopSelectAdditionOrTriggerActionVC
            TopDataManager.shared.condition = condition
            selectActionVC.type = .edit
            var selectRro: Int = 0
            let isOn = SGlobalVars.conditionHandle.getDoorMotionState(condition!.value)
            selectRro = isOn ? 0:1
            selectActionVC.selectedRow = Int32(selectRro)
            self.show(selectActionVC, sender: nil)
            
        case .some(.doorlockV2):
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "TopDoorLockTriggerVC") as! TopDoorLockTriggerVC
            vc.type = .edit
            TopDataManager.shared.condition = condition
            self.show(vc, sender: nil)
            
        default:
            break
        }
    }
    func showSelectfeedbackSwitchOrScenario(_ cell:  UIView, condition: TopCondition) -> Void {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      
        if (alertController.popoverPresentationController != nil) {
            
            alertController.popoverPresentationController?.sourceView = cell
            alertController.popoverPresentationController?.sourceRect = (cell.bounds)
        }
        
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let actionFeedback = UIAlertAction(title: NSLocalizedString("Feedback switch", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            TopDataManager.shared.condition = condition
            let feedbackSwitchSetVC: TopFeedfbackSwitchConditionVC = sb.instantiateViewController(withIdentifier: "TopFeedfbackSwitchConditionVC") as! TopFeedfbackSwitchConditionVC
            feedbackSwitchSetVC.type = .TopFeedfbackSwitchConditionVCTypeEdit
            self.show(feedbackSwitchSetVC, sender: nil)
            
            
        })
        
        let sceneAction = UIAlertAction(title: NSLocalizedString("Scene Switch", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let selectActionVC: TopSelectTriggerActionVC = sb.instantiateViewController(withIdentifier: "TopSelectTriggerActionVC") as! TopSelectTriggerActionVC
            TopDataManager.shared.condition = condition
            selectActionVC.type = .TopSelectTriggerActionTypeEdit
            var selectRro: Int = 0
            if SGlobalVars.conditionHandle.getMacroBoradRoad(condition.value) < 15 {
                selectRro = Int(SGlobalVars.conditionHandle.getMacroBoradRoad(condition.value)) - 1
            }
            
            selectActionVC.selectedRow = Int32(selectRro)
            self.show(selectActionVC, sender: nil)
        })
        
        
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionFeedback)
        alertController.addAction(sceneAction)
        present(alertController, animated: true, completion: nil)
        return
    }
    
    func addCondition(_ condition : TopCondition) -> Bool {
        isChanged = true
        if !conditionList.contains(condition) {
            for theCondition in conditionList{
                if condition.conditionType != theCondition.conditionType{
                    continue
                }
                if condition.conditionType == .time{
                    if (condition.timerModel.timer == theCondition.timerModel.timer) && (condition.timerModel.weekDayByte == theCondition.timerModel.weekDayByte) {
                        
                        return false
                    }
                }
                else{
                    if (condition.device?.deviceId == theCondition.device?.deviceId) &&  (condition.value == theCondition.value){
                        
                        return false
                    }
                }
            }
            
            conditionList.append(condition)
        }
        let macro = TopDataManager.shared.macro
        macro?.triggerConditions = conditionList
        //self.resetrightBarButtonItems()
        self.tableView.reloadData()
        return true
        //self.resetrightBarButtonItems()
    }
    
    
    func removeCondetion(_ condition : TopCondition) -> Void{
        if conditionList.contains(condition) {
             isChanged = true
            var index = 0
            for theCondition in conditionList{
                if theCondition == condition{
                    conditionList.remove(at: index)

                    self.tableView.reloadData()
                    break
                }
                index += 1
            }
        }
        let macro = TopDataManager.shared.macro
        macro?.triggerConditions = conditionList
        self.tableView.reloadData()
      // self.resetrightBarButtonItems()
    }
}

