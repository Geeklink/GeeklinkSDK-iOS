//
//  TopRestrictiveVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/13.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopAditionVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopConditionCellDelegate, TopUsefulTimeConditionCellDelegate {
//
//    var editItem: UIBarButtonItem!
//    var doneItem: UIBarButtonItem!

    
    var conditionList = Array<TopCondition>()
    weak var outoMacroItem: TopItem!
    weak var textInputCell: TopTextInputCell!
    weak var nextCell: UITableViewCell!
    var backVC: UIViewController?
    var isChanged: Bool = false
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //设置文本
        title = NSLocalizedString("Restrictive condition", tableName: "MacroPage")
        
        tableView.register(UINib(nibName: "TopConditionCell", bundle: nil), forCellReuseIdentifier: "TopConditionCell")
        tableView.register(UINib(nibName: "TopUsefulTimeConditionCell", bundle: nil), forCellReuseIdentifier: "TopUsefulTimeConditionCell")
        
//        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(editItemDidclicked))
//        editItem  = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItemDidclicked))
//
        let backItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .done, target: self, action: #selector(backItemDidclicked))
        backItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backItem
       // navigationItem.rightBarButtonItems = [doneItem]
        
        //清除空白横线
        tableView.tableFooterView = UIView()
        getRefreshData()
        let macro = TopDataManager.shared.macro
       
        if macro?.additionalConditions.count == 0 {
           
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let iVc: TopAditionListVC = sb.instantiateViewController(withIdentifier: "TopAditionListVC") as! TopAditionListVC
            if backVC != nil {
                iVc.backVC = backVC
            }
            self.show(iVc, sender: nil)
            
        }
        
    }

    override func getRefreshData() {
        let macro = TopDataManager.shared.macro
        conditionList = (macro?.additionalConditions)!
        tableView.reloadData()
       // resetrightBarButtonItems()
    }
    
    //MARK: -
    
//    func resetrightBarButtonItems() -> Void {
//        if tableView.isEditing {
//            self.navigationItem.rightBarButtonItems = [doneItem]
//            return
//        }
//
//        if conditionList.count > 0 {
//
//            self.navigationItem.rightBarButtonItems = [editItem]
//        } else {
//            navigationItem.rightBarButtonItems = []
//        }
//
//
//    }
//
    @objc func backItemDidclicked(_ view: UIView) -> Void {
        if isChanged{
            TopDataManager.shared.isChanged = true
        }
        let macro = TopDataManager.shared.macro
        macro?.additionalConditions = conditionList
        navigationController?.popViewController(animated: true)
        
//        if isChanged == false{
//            self.navigationController?.popViewController(animated: true)
//            return
//        }
//        let alertController = UIAlertController(title: NSLocalizedString("Cancel editors", tableName: "MacroPage")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
//        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
//        if (alertController.popoverPresentationController != nil) {
//            alertController.popoverPresentationController?.sourceView = view
//            alertController.popoverPresentationController?.sourceRect = view.bounds
//        }
//
//        weak var weakSelf = self
//        let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", tableName: "MacroPage"), style: .destructive, handler: {
//            (action) -> Void in
//            weakSelf?.navigationController?.popViewController(animated: true)
//
//        })
//        alertController.addAction(actionOk)
//        alertController.addAction(actionCancel)
//        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func doneItemDidclicked(_ sender: Any) {
        if self.tableView.isEditing {
            //editItemDidclicked(doneItem)
            return
        }
        if isChanged == true{
            TopDataManager.shared.isChanged = true
        }
        let macro = TopDataManager.shared.macro
        macro?.additionalConditions = conditionList
        navigationController?.popViewController(animated: true)
    }
        
    func editItemDidclicked(_ sender: Any) {
        
        tableView.isEditing = !tableView.isEditing
        
//        if tableView.isEditing {
//            self.navigationItem.rightBarButtonItems = [doneItem]
//        }else{
//            self.navigationItem.rightBarButtonItems = [doneItem,editItem]
//        }
        tableView.reloadData()
    }
    
   
    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return conditionList.count
        } else {
            if tableView.isEditing {
                return 0
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //启动限制
        if indexPath.section == 0 {
            let condition = conditionList[indexPath.row]
            if condition.conditionType == .effectiveTime {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TopUsefulTimeConditionCell") as! TopUsefulTimeConditionCell
                cell.condition = condition
                cell.delegate = self
                cell.editBtn.isHidden = tableView.isEditing
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopConditionCell") as! TopConditionCell
            cell.condition = condition
            cell.editBtn.isHidden = tableView.isEditing
            cell.delegate = self
            return cell
        } else {
            
            let cell = TopAddCell(style: .default, reuseIdentifier: "")
            cell.setTitle(title: conditionList.count == 0 ? NSLocalizedString("Add Addition", tableName: "MacroPage") : NSLocalizedString("Add More Addition", tableName: "MacroPage"))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
            switch hostSubType {
            case .thinker, .thinkerPro:
                if self.conditionList.count >= 20{
                    GlobarMethod.notifyFullError()
                    return
                }
            case .thinkerMini:
                if self.conditionList.count >= 4{
                    GlobarMethod.notifyFullError()
                    return
                }
            default:
                break
            }
            self.performSegue(withIdentifier: "TopAditionListVC", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        isChanged = true
        swap(&conditionList[sourceIndexPath.row], &conditionList[destinationIndexPath.row])
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let condition = self.conditionList[indexPath.row]
            TopDataManager.shared.condition = condition
            let cell = tableView.cellForRow(at: indexPath)
            self.deleteCondition(cell!)
        }
    }
    
    //MARK: - Condition
    
    func deleteCondition(_ view: UIView){
        
        let alertController = UIAlertController(title: NSLocalizedString("Delete", tableName: "MacroPage")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
        
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", tableName: "MacroPage"), style: .destructive, handler: {
            (action) -> Void in
            
            let currentCondition: TopCondition  = TopDataManager.shared.condition!
            weakSelf?.removeCondetion(currentCondition)
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
    }
    
    func addCondition(_ condition : TopCondition) -> Bool{
        isChanged = true
        
        if !conditionList.contains(condition) {
            for theCondition in conditionList{
                if condition.conditionType != theCondition.conditionType{
                    continue
                }
                if condition.conditionType == .effectiveTime{
                    if (condition.usefulTime.beginTime == theCondition.usefulTime.beginTime) && (condition.usefulTime.endTime == theCondition.usefulTime.endTime) && (condition.usefulTime.weekDayByte == theCondition.usefulTime.weekDayByte) {
                       
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
        //self.resetrightBarButtonItems()
        let macro = TopDataManager.shared.macro
        macro?.additionalConditions = conditionList
        self.tableView.reloadData()
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let macro = TopDataManager.shared.macro
        macro?.additionalConditions = conditionList
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }
    
    
    func removeCondetion(_ condition : TopCondition) -> Void{
        if conditionList.contains(condition) {
            isChanged = true
            var index = 0
            for theCondition in conditionList{
                if theCondition == condition{
                  
                    conditionList.remove(at: index)
                    //self.resetrightBarButtonItems()
                    self.tableView.reloadData()
                    break
                }
                index += 1
            }
        }
        let macro = TopDataManager.shared.macro
        macro?.additionalConditions = conditionList
    }
    
    //MARK: - Condition
    
    //编辑有效时间条件
    func usefulTimeConditionCellDidClickedEditButton(condition: TopCondition) {
        
        if condition.conditionType == .effectiveTime{
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let setUsefulTimeVC: TopSetUsefulTimeVC = sb.instantiateViewController(withIdentifier: "TopSetUsefulTimeVC") as! TopSetUsefulTimeVC
            TopDataManager.shared.condition = condition
            setUsefulTimeVC.type = .UsefunTimerVCTypeConditionEdit
            self.show(setUsefulTimeVC, sender: nil)
        }
    }
    
    
    func conditionCellDidClickedEditButton(_ cell: TopConditionCell)  {
        
        let condition = cell.condition
        if condition?.conditionType == .some(.securityMode) {
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopSecurityConditionVC = sb.instantiateViewController(withIdentifier: "TopSecurityConditionVC") as! TopSecurityConditionVC
            TopDataManager.shared.condition = condition
            vc.type = .edit
            self.show(vc, sender: nil)
            return
        }
        if condition?.device == nil{
            TopDataManager.shared.condition = condition
            deleteCondition(cell)
            return
        }
        
        switch condition?.conditionType {
        case .feedbackSwitch?, .some(.socket_macroPanel):
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let feedbackSwitchSetVC: TopFeedfbackSwitchConditionVC = sb.instantiateViewController(withIdentifier: "TopFeedfbackSwitchConditionVC") as! TopFeedfbackSwitchConditionVC
            TopDataManager.shared.condition = condition
            feedbackSwitchSetVC.type = .TopFeedfbackSwitchConditionVCTypeEdit
            self.show(feedbackSwitchSetVC, sender: nil)
            return
        case .tempAndHum? :
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let temAndHumSetVC: TopTemAndHumSetVC = sb.instantiateViewController(withIdentifier: "TopTemAndHumSetVC") as! TopTemAndHumSetVC
            TopDataManager.shared.condition = condition
            temAndHumSetVC.type = .TopTemAndHumSetVCTypeEdit
            self.show(temAndHumSetVC, sender: nil)
            return
        case .location? :
            TopDataManager.shared.condition = condition
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopLocationAdditionVC = sb.instantiateViewController(withIdentifier: "TopLocationAdditionVC") as! TopLocationAdditionVC
            vc.condition = condition
            self.show(vc, sender: nil)
           
            return
      
        default:
            break
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
            
        default:
            break
        }
    }
    
}



