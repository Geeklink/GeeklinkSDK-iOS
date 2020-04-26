//
//  TopAddWorkingConditionVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/9.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit


class TopAddWorkingConditionVC:  TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopConditionTitleCellDelegate{
    

    var itemLists: NSMutableArray =
        NSMutableArray()
    
    var macro: TopMacro?
    weak var textInputCell: TopTextInputCell!
    weak var nextCell: UITableViewCell!
    var currentMacroAckInfo: TopMacroAckInfo?
    
    var additionItem: TopItem!
    var triggerItem: TopItem!
    var actionItem: TopItem!
    
    @IBOutlet weak var tableView: UITableView!
    
   // var macro: TopMacro?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
     
        //设置文本
        title = NSLocalizedString("Add Condition", tableName: "MacroPage")
        
        //注册cell

        tableView.register(UINib(nibName: "TopConditionTitleCell", bundle: nil), forCellReuseIdentifier: "TopConditionTitleCell")
        
        tableView.register(UINib(nibName: "TopConditionCell", bundle: nil), forCellReuseIdentifier: "TopConditionCell")
        tableView.register(UINib(nibName: "TopTimingConditionCell", bundle: nil), forCellReuseIdentifier: "TopTimingConditionCell")
        tableView.register(UINib(nibName: "TopUsefulTimeConditionCell", bundle: nil), forCellReuseIdentifier: "TopUsefulTimeConditionCell")
        tableView.register(UINib(nibName: "TopTaskCell", bundle: nil), forCellReuseIdentifier: "TopTaskCell")
        
        initItemList()
       //initItemDemoList()
        macro = TopDataManager.shared.macro
    
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
        let macroSet = NSNotification.Name("macroSetResp")
        NotificationCenter.default.addObserver(self, selector: #selector(macroSetResp), name:macroSet, object: nil)
        
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action:#selector(saveItemDidclicked))
        saveItem.tintColor = APP_ThemeColor
        self.navigationItem.rightBarButtonItem = saveItem
        tableView.reloadData()
       
    }
    @objc func saveItemDidclicked() -> Void {
        if SGlobalVars.macroHandle.macroSetReq(TopDataManager.shared.homeId, action:(macro?.action)!, macroFullInfo: macro?.macroFullInfo) == 0 {
            processTimerStart(3.0)
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    @objc func macroSetResp(notificatin: Notification) {
        //请求条件列表回复
        processTimerStop()
       
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            self.navigationController?.popToRootViewController(animated: true)
        } else if info.state == .fullError {
            GlobarMethod.notifyFullError()
        }
        else {
            
            GlobarMethod.notifyFailed()
        }
    }
    
    deinit {
        let macroConditionGet = NSNotification.Name("macroConditionGetResp")
        NotificationCenter.default.removeObserver(self, name: macroConditionGet, object: nil)
        
    }
    
    
   

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
       let _ = TopDataManager.shared.resetDeviceInfo()
       self.tableView.reloadData()
        
    }
    
  
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
  
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.reloadData()
    }
   
    
    func initItemList(){
        
        
        weak var weakSelf = self
        
        let Item = TopItem()
        Item.text = NSLocalizedString("Trigger Event(s)", tableName: "MacroPage")
        Item.accessoryType = .add
        self.triggerItem = Item
        Item.detailedText = NSLocalizedString("When the next condition is satisfied,the scenario will implement，and the restrictive conditions will be judged.", tableName: "MacroPage")
        Item.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            
            let iVc: TopTriggerVC = sb.instantiateViewController(withIdentifier: "TopTriggerVC") as! TopTriggerVC
            
            if weakSelf?.macro?.triggerConditions.count == 0 {
                iVc.backVC = weakSelf
                weakSelf?.navigationController?.pushViewController(iVc, animated: false)
            }else {
                weakSelf?.show(iVc, sender: nil)
            }
            
            
        }
        
        itemLists.add(Item)
    
        let limitItem = TopItem()
        self.additionItem = limitItem
        limitItem.text = NSLocalizedString("Restrictive condition(s)", tableName: "MacroPage")
        limitItem.accessoryType = .add
        limitItem.detailedText = NSLocalizedString("The execution of the scenario is only if the following conditions are satisfied.", tableName: "MacroPage")
        limitItem.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let iVc: TopAditionVC = sb.instantiateViewController(withIdentifier: "TopAditionVC") as! TopAditionVC
           
            if weakSelf?.macro?.additionalConditions.count == 0 {
                iVc.backVC = weakSelf
                weakSelf?.navigationController?.pushViewController(iVc, animated: false)
            }else {
                weakSelf?.show(iVc, sender: nil)
            }
            
        }
        itemLists.add(limitItem)
        
        let implementItem = TopItem()
        self.actionItem = implementItem
        implementItem.text = NSLocalizedString("Perform Action(s)", tableName: "MacroPage")
        implementItem.detailedText = NSLocalizedString("This rountine executes the following action(s) in order.", tableName: "MacroPage")
        implementItem.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let iVc: TopAddTaskVC = sb.instantiateViewController(withIdentifier: "TopAddTaskVC") as! TopAddTaskVC
           
            if weakSelf?.macro?.tasks.count == 0 {
                iVc.backVC = weakSelf
                weakSelf?.navigationController?.pushViewController(iVc, animated: false)
            }else {
                weakSelf?.show(iVc, sender: nil)
            }
           
        }
    
        implementItem.accessoryType = .add
        itemLists.add(implementItem)
        
        
    
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }
   
    
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let hederContentView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 44))
        let item: TopItem = itemLists[section] as! TopItem
        let label: UILabel = UILabel()
        label.text = item.headerTitle
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 13)
        label.frame = CGRect(x: 16, y: 00, width: self.view.width - 16, height: 44)
        hederContentView.addSubview(label)
        hederContentView.backgroundColor = UIColor(red: 240/255, green: 239/255, blue: 245/255, alpha: 1)
        return hederContentView;
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let item: TopItem = itemLists[section] as! TopItem
       
        return item.headerTitle
    }
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
          return itemLists.count
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        switch section {
        case 0:
            return (macro?.triggerConditions.count)! + 1
        case 1:
            if (macro?.triggerConditions.count)! > 0{
                return (macro?.additionalConditions.count)! + 1
            }else{
                return (macro?.tasks.count)! + 1
            }
           
        case 2:
            if (macro?.triggerConditions.count)! > 0{
                 return (macro?.tasks.count)! + 1
            }
        default:
            break
        }
        return 0
       

        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let item: TopItem = itemLists[indexPath.section] as! TopItem
            let messageSize = TopDataManager.shared.textSize(text: item.detailedText, font: UIFont.systemFont(ofSize: 11), maxSize: CGSize(width: self.view.width - 32, height: CGFloat.greatestFiniteMagnitude))
            return messageSize.height + 72
        }
        if indexPath.section == 1{
             if (macro?.triggerConditions.count)! == 0{
                return 88
            }
        }
       
        if indexPath.section == 2{
            return 88
        }
        return 44
      
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if indexPath.row == 0 {
            var item: TopItem = itemLists[indexPath.section] as! TopItem
            if (macro?.triggerConditions.count)! == 0{
                if indexPath.section == 1{
                    item = itemLists[indexPath.section + 1] as! TopItem
                }
            }
            if item == triggerItem {
                item.detailedText = (macro?.triggerConditions.count)! > 0 ? NSLocalizedString("When the next condition is satisfied,the scenario will implement，and the restrictive conditions will be judged.", tableName: "MacroPage") : NSLocalizedString("No trigger, please add.", tableName: "MacroPage")
            }else if item == additionItem{
                 item.detailedText = (macro?.additionalConditions.count)! > 0 ? NSLocalizedString("The execution of the scenario is only if the following conditions are satisfied.", tableName: "MacroPage") : NSLocalizedString("No addition, please add.", tableName: "MacroPage")
            }else if item ==  actionItem{
                item.detailedText = (macro?.tasks.count)! > 0 ? NSLocalizedString("This rountine executes the following action(s) in order.", tableName: "MacroPage") : NSLocalizedString("No action, please add.", tableName: "MacroPage")
            }
           
            let cell: TopConditionTitleCell = tableView.dequeueReusableCell(withIdentifier: "TopConditionTitleCell") as! TopConditionTitleCell
            cell.item = item
            cell.delegate = self
            cell.selectionStyle = .none
            return cell

        }else{
            if (indexPath.section == 0) {
               //触发事件
                     
                if (indexPath.row <= (macro?.triggerConditions.count)!){
                    let condition: TopCondition = (macro?.triggerConditions[indexPath.row - 1])!
                   if condition.conditionType == .time{
                        let cell: TopTimingConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopTimingConditionCell") as! TopTimingConditionCell
                        cell.condition = condition
                        
                        return cell
                    }
                   
                    let cell: TopConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopConditionCell") as! TopConditionCell
                    cell.condition = condition
                
                    return cell
                    
                    
                }
                
                
            }
                
           if (indexPath.section == 1) {
                if (macro?.triggerConditions.count)! > 0{
                    
                    if (indexPath.row <= (macro?.additionalConditions.count)!){
                        let condition: TopCondition = (macro?.additionalConditions[indexPath.row - 1])!
                        
                        if condition.conditionType == .effectiveTime{
                            let cell: TopUsefulTimeConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopUsefulTimeConditionCell") as! TopUsefulTimeConditionCell
                            cell.condition = condition
                            return cell
                        }
                        
                        let cell: TopConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopConditionCell") as! TopConditionCell
                        cell.condition = condition
                        return cell
                    }
                }else{
                    let task: TopTask = (macro?.tasks[indexPath.row-1])!
                    let cell:TopTaskCell = tableView.dequeueReusableCell(withIdentifier: "TopTaskCell") as! TopTaskCell
                    cell.deleteBtn.isHidden = true
                    cell.task = task
                    //  cell.delegate = self
                    return cell
               }
            
                
            }
                
                
            
           
           if(indexPath.section == 2){
                let task: TopTask = (macro?.tasks[indexPath.row-1])!
                let cell:TopTaskCell = tableView.dequeueReusableCell(withIdentifier: "TopTaskCell") as! TopTaskCell
                cell.deleteBtn.isHidden = true
                cell.task = task
              //  cell.delegate = self
                return cell
            }
            
            let cell: TopSuperCell = TopSuperCell(style: .default, reuseIdentifier: "TopSuperCell")
            cell.selectionStyle = .none
            return cell
            
        }
     
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
    }
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
       
    }
    
    
    

    func conditionTitleCellDelegateDidClickedAccessoryView(_ item: TopItem, cell: TopConditionTitleCell) {
        
          item.block(self)
        
    }
    
    
    
    
        
        
    
    
    
}

