//
//  TopTimerVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/12.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

enum TopTimerVCType: Int {
    case TopTimerVCTypeTimeSet
    case TopTimerVCTypeConditionAdd
    case TopTimerVCTypeConditionEdit
}

class TopTimerVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopWeekTbCellDelegate {
   
    var type : TopTimerVCType?
    var weekCell: TopWeekTbCell?
    
    var timeCell: TopSelectTimeCell?
    var _timerModel = TopTimerModel()
    
    var usefulWeek = [Bool]()
    var beginTime: Int32 = 0
    var endTime: Int32 = 1439
    var addtionWeek:Int32 = 0x7f
    var selectEndTime: Int32 = 1439//cell选择的时间范围
    var selectBeginTime: Int32 = 0//cell选择的时间范围
    var beginTimeList = [Int32]()
    var endTimeList = [Int32]()
    
    var timerModel: TopTimerModel? {
        set {
            _timerModel = (newValue as TopTimerModel?)!
        }
        get{
           return _timerModel
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        //设置文本
        title = NSLocalizedString("Timing setting", tableName: "MacroPage")
        
        tableView.register(UINib(nibName: "TopWeekTbCell", bundle: nil), forCellReuseIdentifier: "TopWeekTbCell")
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "TopSelectTimeCell", bundle: nil), forCellReuseIdentifier: "TopSelectTimeCell")
        tableView.bounces = false
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        initData()
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableView.reloadData()
    }
    
    func initData() -> Void {
        if self.type == .TopTimerVCTypeTimeSet{
            return
        }
        for _ in 0...6 {
            usefulWeek.append(true)
        }
        for additionContion in (TopDataManager.shared.macro?.additionalConditions)! {
            if additionContion.conditionType != .effectiveTime {
                continue
            }
            for weekIndex in 0...6 {
                usefulWeek[weekIndex] = false
            }
            if self.type == .TopTimerVCTypeConditionAdd{
                timerModel?.weekDayByte = additionContion.usefulTime.weekDayByte
                timerModel?.timer = additionContion.usefulTime.beginTime
            }
            let additionWeek = additionContion.usefulTime.weekDayByte
            addtionWeek = additionContion.usefulTime.weekDayByte!
            if additionContion.usefulTime.beginTime! < additionContion.usefulTime.endTime!{
               
                for index in 0...6{
                    if (additionWeek!>>index) % 2 == 1{
                        usefulWeek[index] = true
                    }
                }
                 self.selectEndTime = additionContion.usefulTime.endTime!
               
            }else{
                for index in 0...6{
                    if (additionWeek!>>index) % 2 == 1{
                        usefulWeek[index] = true
                        usefulWeek[(index + 1)%6] = true
                    }
                }
                if additionContion.usefulTime.weekDayType == .everyDay{
                     self.selectEndTime = additionContion.usefulTime.endTime!
                }else{
                     self.selectEndTime = 1439
                }
               
            }
         
            self.beginTime = additionContion.usefulTime.beginTime!
            self.selectBeginTime = additionContion.usefulTime.beginTime!
            self.endTime = additionContion.usefulTime.endTime!
           
        }
        self.tableView.reloadData()
    }
    
    func checkConflict() -> Bool {
        if self.type == .TopTimerVCTypeTimeSet{
            return false
        }
        var conflictList: Array = [Bool]()
        var currentWeek = weekCell?.week
        for _ in 0...6{
            
            if currentWeek! % 2 == 1{
                conflictList.append(true)
            }else{
                conflictList.append(false)
            }
            currentWeek = currentWeek! >> 1
        }
        
        let time = timeCell?.time
        
        var isHasEffective: Bool = false
        for additionContion in (TopDataManager.shared.macro?.additionalConditions)! {
            if additionContion.conditionType != .effectiveTime {
                continue
            }
            isHasEffective = true
            var currentWeek = weekCell?.week
            var additionWeek = additionContion.usefulTime.weekDayByte
            for index in 0...6{
                if conflictList[index] == true{
                    if currentWeek! % 2 != 1 {
                        conflictList[index] = false
                        continue
                    }
                    else{//  if conflict[index] == false
                        
                        if (additionWeek!%2) == 1{
                            if additionContion.usefulTime.beginTime! < additionContion.usefulTime.endTime!{
                                if time! > additionContion.usefulTime.beginTime! &&  time! < additionContion.usefulTime.endTime!{
                                    conflictList[index] = false
                                    continue
                                }
                            }else{
                                if time! > additionContion.usefulTime.beginTime!{
                                    conflictList[index] = false
                                }
                                
                                if time! < additionContion.usefulTime.endTime!{//判断上一天跨越今天的时间
                                    let nextIndex = (index + 1) % 6
                                    conflictList[nextIndex] = false
                                    
                                }
                            }
                        }
                        
                    }
                    
                    // else{//  if conflict[index] == false
                    currentWeek = currentWeek!>>1
                    additionWeek = additionWeek!>>1
                    
                }//endfor index in 0...6{
                break
            }// for additionContion in (TopDataManager.shared.macro?.additionalConditions)! {
        }
        if isHasEffective{
            for conflict in conflictList {
                if conflict == true{
                   
                    return true
                }
            }
        }
        return false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let macroConditionGet = NSNotification.Name("macroConditionSetResp")
        NotificationCenter.default.addObserver(self, selector: #selector(macroConditionSetResp), name:macroConditionGet, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let macroConditionGet = NSNotification.Name("macroConditionSetResp")
        NotificationCenter.default.removeObserver(self, name: macroConditionGet, object: nil)
     
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
   
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.type == .TopTimerVCTypeConditionEdit {
            return 3
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return tableView.width / 7 + 64
//          return tableView.height * 0.15
        }
        if indexPath.section == 1 {
            return tableView.height * 0.4
//            return tableView.height * 0.4
        }
        return 44
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.view.width <= 320 {
            return 44
        }
        return 30;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 1)  && self.type != .TopTimerVCTypeTimeSet {
            let screenW: CGFloat = UIScreen.main.bounds.size.width
            var height: CGFloat = 30
            if  self.view.width <= 320
            {
                height = 44
            }
            let tableHeaderFooterView :UITableViewHeaderFooterView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: screenW, height: height))
            
            let theHeaderTipLabel: UILabel = UILabel(frame: CGRect(x: 16, y: 0, width: screenW - 32, height: height))
           
            if self.selectBeginTime < self.selectEndTime {
                theHeaderTipLabel.text = NSLocalizedString("Valid Time", tableName: "MacroPage")+": "+String(glTime: Int16(self.selectBeginTime))+" - "+String(glTime: Int16(self.selectEndTime))
                
            } else if self.selectBeginTime > self.selectEndTime {
                theHeaderTipLabel.text = NSLocalizedString("Valid Time", tableName: "MacroPage")+": "+String(glTime: Int16(self.selectBeginTime))+"-"+String(glTime: Int16(1439))+" | "+String(glTime: Int16(0))+"-"+String(glTime: Int16(self.selectEndTime))
            }
            theHeaderTipLabel.font = UIFont.systemFont(ofSize: 13)
            theHeaderTipLabel.numberOfLines = 0
            tableHeaderFooterView.contentView.addSubview(theHeaderTipLabel)
            tableHeaderFooterView.backgroundColor = UIColor.clear
            return tableHeaderFooterView;
        }
        return UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if indexPath.section == 2 {
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
                if vc.isKind(of: TopTriggerVC.classForCoder()) {
                    let theVC: TopTriggerVC = vc as! TopTriggerVC
                    theVC.removeCondetion(currentCondition)
                    weakSelf?.navigationController?.popToViewController(theVC, animated: true)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if indexPath.section == 0 {
          
                let cell: TopWeekTbCell = tableView.dequeueReusableCell(withIdentifier: "TopWeekTbCell")! as! TopWeekTbCell
                cell.usefulWeek = self.usefulWeek
                if timerModel != nil{
                    cell.week = (timerModel?.weekDayByte)!
                }
                weekCell = cell
                cell.delegate = self
                
                return cell
            
        }
        if indexPath.section == 1{
           
                
            let cell: TopSelectTimeCell =  tableView.dequeueReusableCell(withIdentifier: "TopSelectTimeCell")! as! TopSelectTimeCell
           
            if timerModel != nil{
                cell.time = (timerModel?.timer)!
            }
            
            timeCell = cell
            cell.selectionStyle = .none
            return cell
            
        }
        

      
        let cell: UITableViewCell = UITableViewCell()
        cell.textLabel?.text = NSLocalizedString("Delete", comment: "")
        cell.textLabel?.textColor = APP_ThemeColor
        cell.textLabel?.frame = cell.contentView.frame

        cell.textLabel?.textAlignment = .center
        return cell;
    }
    
    @IBAction func saveBtnDidClicked(_ sender: Any) {
        if checkConflict(){
             self.alertMessage(NSLocalizedString("There is a conflict with the valid time of setting up", tableName: "MacroPage"))
            return
        }
        
           
        if (type == .TopTimerVCTypeConditionAdd) || (type == .TopTimerVCTypeConditionEdit){
            let currentCondition: TopCondition  = TopDataManager.shared.condition!
            
            currentCondition.value = "0"
            currentCondition.timerModel.timer = (timeCell?.time)!
            currentCondition.timerModel.weekDayByte = (weekCell?.week)!
            
                for vc in (navigationController?.viewControllers)! {
                    if vc.isKind(of: TopTriggerVC.classForCoder()) {
                        let theVC: TopTriggerVC = vc as! TopTriggerVC
                        
                        let isAdded = theVC.addCondition(currentCondition)
                        if isAdded {
                             navigationController?.popToViewController(vc, animated: true)
                        } else {
                             self.alertMessage(NSLocalizedString("The condition have been added", tableName: "MacroPage") )
                        }
                        return
                       
                    }
                }
            return
            
        }else//普通的时间修改
        {
            _timerModel.timer = timeCell?.time
            _timerModel.weekDayByte = weekCell?.week
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func seekTbCellDelegateSelectUnUsefunWeek(_ week: Int32) {
        alertMessage(NSLocalizedString("The effective time time does not include ", tableName: "MacroPage")+String(glWeekShort: Int8(week)))
    }
    
    func seekTbCellDelegateSelectUsefunWeek(_ week: Int32) {
        if self.type == .TopTimerVCTypeTimeSet{
            return
        }
        if beginTime < endTime{//没有跨天
            return
        }
        let addtionWeek = self.addtionWeek
        var isNeedEndTime = true
        timerModel?.weekDayByte = week
        for index in 0...6{
            if (week>>index)%2 == 1{
                if (addtionWeek>>index) % 2 != 1{
                    selectBeginTime =  0
                    selectEndTime = endTime
                    self.tableView.reloadData()
                    return
                }
                if index > 0{
                    if (addtionWeek>>(index - 1)) % 2 != 1{
                        isNeedEndTime = false
                        break
                    }
                }else{
                    if (addtionWeek>>6) % 2 != 1{
                        isNeedEndTime = false
                        break
                    }
                }
            }
           
        }//end for index in 0...6{
        self.selectBeginTime = beginTime
        if isNeedEndTime{
            selectEndTime = endTime
        }else{
            selectEndTime = 1439
        }
        
        self.tableView.reloadData()
       
    }
    
 
}

