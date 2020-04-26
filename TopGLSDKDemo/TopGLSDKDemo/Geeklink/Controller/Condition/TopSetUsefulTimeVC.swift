//
//  TopSetUsefulTimeVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/14.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
enum UsefunTimerVCType: Int {
    case UsefunTimerVCTypeSetTime
    case UsefunTimerVCTypeConditionAdd
    case UsefunTimerVCTypeConditionEdit
   
}
class TopSetUsefulTimeVC:TopSuperVC, UITableViewDataSource, UITableViewDelegate {
 
    var _usefulTime: TopUsefulTime = TopUsefulTime()
    var weekCell: TopWeekTbCell?
    var usefulTimeCell: TopSetUsefulTimeCell?
    
    var usefulTime: TopUsefulTime?{
        set{
            _usefulTime = (newValue as TopUsefulTime?)!
            
            self.tableView.reloadData()
        }
        get{
            return _usefulTime
        }
    }
    var type:UsefunTimerVCType?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //设置文本
        title = NSLocalizedString("Valid Time", tableName: "MacroPage")
        
        tableView.register(UINib(nibName: "TopWeekTbCell", bundle: nil), forCellReuseIdentifier: "TopWeekTbCell")
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "TopSetUsefulTimeCell", bundle: nil), forCellReuseIdentifier: "TopSetUsefulTimeCell")
        tableView.bounces = false
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
              if (type == .UsefunTimerVCTypeConditionAdd) || (type == .UsefunTimerVCTypeConditionEdit){
                self.usefulTime = TopDataManager.shared.condition?.usefulTime
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.type == .UsefunTimerVCTypeConditionEdit {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return tableView.width / 7 + 64
//                return UIScreen.main.bounds.height * 0.15
            } else {
                return UIScreen.main.bounds.height * 0.7
            }
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                let cell: TopWeekTbCell = tableView.dequeueReusableCell(withIdentifier: "TopWeekTbCell")! as! TopWeekTbCell
                if usefulTime != nil{
                    cell.week = (usefulTime?.weekDayByte)!
                }
                weekCell = cell
                return cell
                
            } else {
                
                let cell: TopSetUsefulTimeCell =  tableView.dequeueReusableCell(withIdentifier: "TopSetUsefulTimeCell")! as! TopSetUsefulTimeCell
                cell.selectionStyle = .none
                usefulTimeCell = cell
                if usefulTime != nil{
                    cell.beginTime = (usefulTime?.beginTime)!
                    cell.endTime = (usefulTime?.endTime)!
                    
                }
                
                return cell
                
            }
        }else{
            
            let cell: UITableViewCell = UITableViewCell()
            cell.textLabel?.text = NSLocalizedString("Delete", comment: "")
            cell.textLabel?.textColor = APP_ThemeColor
            cell.textLabel?.frame = cell.contentView.frame
            cell.textLabel?.textAlignment = .center
            return cell;
        }
        

        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UIView();
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRow(at: indexPath)
            deleteCondition(cell!)
            
        }
    }
    
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
            for vc in (weakSelf?.navigationController?.viewControllers)! {
                if vc.isKind(of: TopAditionVC.classForCoder()) {
                    let theVC: TopAditionVC = vc as! TopAditionVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(vc, animated: true)
                }
            }
    
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
       
    }

    func alertConflictMessage(_ condition: TopCondition) -> Void {
         self.alertMessage(NSLocalizedString("The effective time added does not include timing trigger conditions ", tableName: "MacroPage")+condition.timerModel.weekDayStr+" "+condition.timerModel.timerStr)
    }
    
    @IBAction func saveBtnDidClicked(_ sender: Any) {
       
        
        let beginTime = usefulTimeCell?.beginTime
        let endTime = usefulTimeCell?.endTime
        if beginTime == endTime{
            self.alertMessage(NSLocalizedString("The start time is not equal to the end time", tableName: "MacroPage"))
        }
        for trigerCodition in (TopDataManager.shared.macro?.triggerConditions)!{
            if trigerCodition.conditionType == .time{
                let weekDayByte  = weekCell?.week
    
                let trigerWeek = trigerCodition.timerModel.weekDayByte
                for index in 0...6{
                    let currentDayByte =  weekDayByte!>>index
                    let currentTrigerWeek = trigerWeek!>>index
                    if  currentTrigerWeek % 2 == 1{
                        if beginTime! < endTime!{
                            if currentDayByte % 2 != 1{
                               self.alertConflictMessage(trigerCodition)
                                return
                            }
                            if trigerCodition.timerModel.timer! < beginTime! || trigerCodition.timerModel.timer! > endTime! {
                                self.alertConflictMessage(trigerCodition)
                                return
                            }
                        }else{
                            let perDayByte = weekDayByte! >> ((index + 5)%6)
                            if perDayByte%2 == 1{
                                if trigerCodition.timerModel.timer! < beginTime! &&  trigerCodition.timerModel.timer! > endTime!{
                                    self.alertConflictMessage(trigerCodition)
                                    return
                                }
                            }else{
                                if trigerCodition.timerModel.timer! < beginTime!{
                                    self.alertConflictMessage(trigerCodition)
                                    return
                                }
                            }
                        }
                    }
                    
                    
                }
            }
        }
        
        //条件的添加或者修改
        if (type == .UsefunTimerVCTypeConditionAdd) || (type == .UsefunTimerVCTypeConditionEdit){
          
            
            let currentCondition: TopCondition  = TopDataManager.shared.condition!
            currentCondition.usefulTime.weekDayByte  = weekCell?.week
            currentCondition.usefulTime.beginTime = usefulTimeCell?.beginTime
            currentCondition.usefulTime.endTime = usefulTimeCell?.endTime
            currentCondition.value = "0"
            
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
            return
        }
        
        //简单的时间修改
        self.navigationController?.popViewController(animated: true)
       
        
        
    }
    
    
    
}


