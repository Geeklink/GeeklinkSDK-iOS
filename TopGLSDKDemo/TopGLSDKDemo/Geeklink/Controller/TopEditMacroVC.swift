//
//  TopEditMacroVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/16.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopEditMacroVC:  TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopTextInputCellDelegate, TopSuperCellDelegate, TopSelectMacroIconVCDelegate, TopConditionTitleCellDelegate, UITextFieldDelegate , TopTypeSelectedVCDelegate{
   
    //MARK: - Var
    
    var timer: Timer?
    let defult = UserDefaults.init(suiteName: App_Group_ID)
    var currentMacroAckInfo: TopMacroAckInfo?
    
    var itemLists: NSMutableArray =
        NSMutableArray()
    
    var outoMacroItem :TopItem!
    var notifyItem :TopItem!
    var notifyItemAndoutoMacroItemList = [TopItem]()
   
    weak var textInputCell: TopTextInputCell!
    weak var iconCell: TopRightIconTBCell!
    weak var deleteCell: UITableViewCell!
    weak var copyCell: UITableViewCell!
    
    //触发事件头部
    var memberItem :TopItem!
    var securityModeItem : TopItem = TopItem()
    var triggerItem: TopItem = TopItem()
    var addtionalItem: TopItem = TopItem()
    var taskItem: TopItem = TopItem()
    
  

    var triggers: NSMutableArray = NSMutableArray()
    var additionals: NSMutableArray = NSMutableArray()
    var tasks: NSMutableArray = NSMutableArray()
    
    var saveItem: UIBarButtonItem = UIBarButtonItem()
    var iconItem :TopItem?
    var macro: TopMacro?
   
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        macro = TopDataManager.shared.macro
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(macroDetailResp), name:NSNotification.Name("macroDetailResp"), object: nil)
       
        title = NSLocalizedString("Edit scenario", tableName: "MacroPage")
        TopDataManager.shared.isChanged = false
        
        self.isEditing = false
        initConditionAndTaskItem()
        initItemList()
        
        //注册cell
        tableView.register(UINib(nibName: "TopRightIconTBCell", bundle: nil), forCellReuseIdentifier: "TopRightIconTBCell")
        tableView.register(UINib(nibName: "TopConditionTitleCell", bundle: nil), forCellReuseIdentifier: "TopConditionTitleCell")
        tableView.register(UINib(nibName: "TopConditionCell", bundle: nil), forCellReuseIdentifier: "TopConditionCell")
        tableView.register(UINib(nibName: "TopTimingConditionCell", bundle: nil), forCellReuseIdentifier: "TopTimingConditionCell")
        tableView.register(UINib(nibName: "TopUsefulTimeConditionCell", bundle: nil), forCellReuseIdentifier: "TopUsefulTimeConditionCell")
        tableView.register(UINib(nibName: "TopTaskCell", bundle: nil), forCellReuseIdentifier: "TopTaskCell")
     
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        setupnavigationItem()
        getRefreshData()
        self.processTimerStart(12)
        self.addTimer()
        //清除空白横线
        tableView.tableFooterView = UIView()
        tableView.isHidden = true
    }
    
    func setupnavigationItem() -> Void {
        if SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId){
            let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action:#selector(saveItemDidclicked))
            saveItem.tintColor = APP_ThemeColor
            self.saveItem = saveItem
            self.navigationItem.rightBarButtonItem = saveItem
        }
       
        let cancelItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .done, target: self, action: #selector(cancelItemDidclicked))
        cancelItem.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = cancelItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let _ = TopDataManager.shared.resetDeviceInfo()
        self.resetConditionAndTasksList()
        self.resetMemberItemDetailText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(macroSetResp), name:NSNotification.Name("macroSetResp"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeTimer()
        self.isEditing = true

        NotificationCenter.default.removeObserver(self, name:  NSNotification.Name("macroSetResp"), object: nil)
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("macroDetailResp"), object: nil)
//    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.reloadData()
    }
 
    //MARK: - Notification
    
    @objc func macroDetailResp(notificatin: Notification) -> Void {//请求排序返回
        let info = notificatin.object as! TopMacroAckInfo
        processTimerStop()
        
        if info.state == .ok {
            self.removeTimer()
            tableView.isHidden = false
            macro?.macroFullInfo = info.macroFullInfo
           
            securityModeItem.detailedText = (self.macro?.security_mode_str)!
        
            
            self.tableView.reloadData()
            self.resetConditionAndTasksList()
//            GlobarMethod.notifySuccess()
            GlobarMethod.notifyDismiss()
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
    @objc func macroSetResp(notificatin: Notification) {
        
        //请求条件列表回复
        processTimerStop()
//        GlobarMethod.notifyDismiss()
        let info = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            self.navigationController?.popToRootViewController(animated: true)
            
        } else if info.state == .fullError {
            GlobarMethod.notifyFullError()
            
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
    //MARK: - Action
    
    @objc func cancelItemDidclicked(_ view: UIView) -> Void {
        if TopDataManager.shared.isChanged == false {
            self.navigationController?.popViewController(animated: true)
            return
        }
        let alertController = UIAlertController(title: NSLocalizedString("Cancel editors", tableName: "MacroPage")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = view.bounds
        }
        
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", tableName: "MacroPage"), style: .destructive, handler: {
            (action) -> Void in
            weakSelf?.navigationController?.popViewController(animated: true)
            
        })
        alertController.addAction(actionOk)
        alertController.addAction(actionCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func saveItemDidclicked() -> Void {
        macro?.name = (textInputCell.textField?.text)!
        if (macro?.name.isEmpty)!{
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Please input the scenario name",tableName: "MacroPage"))
            textInputCell.textField?.becomeFirstResponder()
            return
        }
        
        if ((macro?.name.lengthOfBytes(using: .utf8))! >= 32) {
            self.alertMessage(NSLocalizedString("Name too long", comment: ""))
            return
        }
        
        if SGlobalVars.macroHandle.macroSetReq(TopDataManager.shared.homeId, action:(macro?.action)!, macroFullInfo: macro?.macroFullInfo) == 0 {
            processTimerStart(3.0)
            
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
    //MARK: -
    
    func resetConditionAndTasksList() -> Void {
        tasks.removeAllObjects()
        tasks.add(taskItem)
        tasks.addObjects(from: (macro?.tasks)!)
        
        triggers.removeAllObjects()
        triggers.add(triggerItem)
        triggers.addObjects(from: (macro?.triggerConditions)!)
        
        additionals.removeAllObjects()
        additionals.add(addtionalItem)
        additionals.addObjects(from: (macro?.additionalConditions)!)
        
        if triggers.count == 1{
            if itemLists.contains(additionals){
                itemLists.remove(additionals)
            }
        }else{
            if !itemLists.contains(additionals){
                if SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId){
                   itemLists.insert(additionals, at: itemLists.count - 3)
                }else {
                   itemLists.insert(additionals, at: itemLists.count - 1)
                }
            }
        }
        self.tableView.reloadData()
    }
  
    //动作
   
    
    override func getRefreshData() {

        if SGlobalVars.macroHandle.macroDetailReq(TopDataManager.shared.homeId, macroId:(macro?.macroID)!) == 0 {
           
        } else {
            GlobarMethod.notifyNetworkError()
        }
    }
    
    func addTimer() -> Void {
        if timer == nil{
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getRefreshData), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode:RunLoop.Mode.common)
        }
    }
    
    func removeTimer() -> Void {
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
    }
  
    
  
    // 请求回复
    
    func initItemList(){
        itemLists.removeAllObjects()
        
        

        let itemList1: NSMutableArray =
            NSMutableArray()
        
        //itemList1
      
        iconItem = TopItem()
        iconItem?.accessoryType = .disclosureIndicator
        iconItem?.text = NSLocalizedString("Scenario icon", tableName: "MacroPage")
        iconItem?.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let selectIconVC: TopSelectMacroIconVC = sb.instantiateViewController(withIdentifier: "TopSelectMacroIconVC") as! TopSelectMacroIconVC
            selectIconVC.delegate = self
            selectIconVC.selectedRow = (self.macro?.icon)!
            self.show(selectIconVC, sender: nil)
            
            // vc.performSegue(withIdentifier: "TopSelectMacroIconVC", sender: nil)
            
        }
        iconItem?.icon = (macro?.iconName)!
        itemList1.add(iconItem!)
        
        let nameItem = TopItem()
        nameItem.cellClassName = "TopTextInputCellTableViewCell"
        nameItem.text = NSLocalizedString("Scenario name", tableName: "MacroPage")
        nameItem.detailedText = (macro?.name)!
        itemList1.add(nameItem)
        
        itemLists.add(itemList1)
        

       
        
        memberItem = TopItem()
        memberItem.cellClassName = "TopSuperCell"
        memberItem.text = NSLocalizedString("Members Enable",tableName: "RoomPage")
        resetMemberItemDetailText()
        
        weak var weakSelf = self
        memberItem?.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopMacroManagerListVC = sb.instantiateViewController(withIdentifier: "TopMacroManagerListVC") as! TopMacroManagerListVC
            vc.macro = (weakSelf?.macro)!
            weakSelf?.navigationController?.show(vc, sender: nil)
        
        }
        memberItem.accessoryType = .disclosureIndicator
        itemList1.add(memberItem as Any)
        
        securityModeItem = TopItem()
        securityModeItem.cellClassName = "TopSuperCell"
        securityModeItem.text = NSLocalizedString("Switch Security", tableName: "MacroPage")
        securityModeItem.detailedText = (self.macro?.security_mode_str)!
        securityModeItem.accessoryType = .disclosureIndicator
        
        securityModeItem.block = { (vc: UIViewController) in
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopMacroSelectSecuriteVC = sb.instantiateViewController(withIdentifier: "TopMacroSelectSecuriteVC") as! TopMacroSelectSecuriteVC
            vc.delegate = self
            vc.securityModeType = (weakSelf?.macro?.security_mode)!
            weakSelf?.navigationController?.show(vc, sender: nil)
            // vc.performSegue(withIdentifier: "TopSelectMacroIconVC", sender: nil)
            
        }
        itemList1.add(securityModeItem as Any)
        
        
        
        
        let itemList3: NSMutableArray = NSMutableArray()
        outoMacroItem = TopItem()
        outoMacroItem.text = NSLocalizedString("Auto Execution", tableName: "MacroPage")
        outoMacroItem.headerTitle = NSLocalizedString("", tableName: "MacroPage")
        outoMacroItem.swichIsOn = (macro?.autoOnOff)!
        outoMacroItem.accessoryType = .switchBtn
        
        itemList3.add(outoMacroItem as Any)
       
        
        if (macro?.autoOnOff)!{
            
            
            notifyItem = TopItem()
            notifyItem.text = NSLocalizedString("Notification", tableName: "MacroPage")
            notifyItem.headerTitle = NSLocalizedString("", tableName: "MacroPage")
            notifyItem.swichIsOn = (macro?.pushOnOff)!
            notifyItem.accessoryType = .switchBtn
            
            itemList3.add(notifyItem as Any)
           
        }
        
        itemLists.add(itemList3)
        

        if (macro?.autoOnOff == true){
            itemLists.add(triggers)
            if triggers.count != 1{
                 itemLists.add(additionals)
            }
           
            itemLists.add(tasks)
            
        }else{
             itemLists.add(tasks)
        }
       
      
        if SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId){
            
            let itemCopyList: NSMutableArray =
                NSMutableArray()
            let copyItem = TopItem()
            copyItem.text = NSLocalizedString("Copy", comment: "")
            copyItem.headerTitle = NSLocalizedString("", tableName: "MacroPage")
            copyItem.accessoryType = .switchBtn
            itemCopyList.add(copyItem)
            itemLists.add(itemCopyList)
            
            let itemLastList: NSMutableArray =
                NSMutableArray()
            let deleteItem = TopItem()
            deleteItem.text = NSLocalizedString("Delete", comment: "")
            deleteItem.headerTitle = NSLocalizedString("", tableName: "MacroPage")
            deleteItem.accessoryType = .switchBtn
            itemLastList.add(deleteItem)
            itemLists.add(itemLastList)
        }
        
       
        
        self.tableView.reloadData()
    
    }
    
    func resetMemberItemDetailText() -> Void {
        if macro?.members == "admin"{
            memberItem.detailedText = NSLocalizedString("Only admin can use it", tableName: "RoomPage")
        }else if macro?.members == "" {
            memberItem.detailedText = NSLocalizedString("All members can use  it", tableName: "RoomPage")
        }else {
            let accountList = (macro?.members.components(separatedBy: ","))!
            if accountList.count == 1 {
                let account = accountList[0]
                if account == SGlobalVars.api.getCurUsername() {
                    memberItem.detailedText = NSLocalizedString("Only admin can use it", tableName: "RoomPage")
                    return
                }
                
            }
            var count = accountList.count
            for account in accountList {
                if account == SGlobalVars.api.getCurUsername() {
                    count -= 1
                    break
                }
            }
            memberItem.detailedText = String.init(format: "%d", count)+NSLocalizedString("member(s) can use it", tableName: "RoomPage")
            
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        if  (TopDataManager.shared.stringIsEmoji(string) == true) {
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Inputting illicit", comment: ""))
            return false
        }
        return true
    }
    func initConditionAndTaskItem() -> Void {
        
        weak var weakSelf = self
        
        
        
        triggerItem.text = NSLocalizedString("Trigger Event(s)", tableName: "MacroPage")
        if SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId){
             triggerItem.accessoryType = .edit
        }else {
            triggerItem.accessoryType = .none
        }
       
        triggerItem.detailedText = NSLocalizedString("When the next condition is satisfied,the scenario will implement，and the restrictive conditions will be judged.", tableName: "MacroPage")
        triggerItem.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            
            let iVc: TopTriggerVC = sb.instantiateViewController(withIdentifier: "TopTriggerVC") as! TopTriggerVC
            if weakSelf?.macro?.triggerConditions.count == 0 {
                iVc.backVC = weakSelf
                weakSelf?.navigationController?.pushViewController(iVc, animated: false)
            }else {
                weakSelf?.show(iVc, sender: nil)
            }
        }
        if triggers.count == 0 {
            triggers.add(triggerItem)
        }
        
        
        addtionalItem.text = NSLocalizedString("Restrictive condition(s)", tableName: "MacroPage")
       
        if SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId){
            addtionalItem.accessoryType = .edit
        }else {
            addtionalItem.accessoryType = .none
        }
        addtionalItem.detailedText = NSLocalizedString("The execution of the scenario is only if the following conditions are satisfied.", tableName: "MacroPage")
        addtionalItem.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let iVc: TopAditionVC = sb.instantiateViewController(withIdentifier: "TopAditionVC") as! TopAditionVC
            if weakSelf?.macro?.additionalConditions.count == 0 {
                iVc.backVC = weakSelf
                weakSelf?.navigationController?.pushViewController(iVc, animated: false)
            }else {
                weakSelf?.show(iVc, sender: nil)
            }
            
            
        }
        
        if tasks.count == 0 {
            tasks.add(taskItem)
        }
        
        additionals.add(triggerItem)
        taskItem.text = NSLocalizedString("Perform Action(s)", tableName: "MacroPage")
        taskItem.detailedText = NSLocalizedString("This rountine executes the following action(s) in order.", tableName: "MacroPage")
        taskItem.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let iVc: TopAddTaskVC = sb.instantiateViewController(withIdentifier: "TopAddTaskVC") as! TopAddTaskVC
           
            if weakSelf?.macro?.tasks.count == 0 {
                iVc.backVC = weakSelf
                weakSelf?.navigationController?.pushViewController(iVc, animated: false)
            } else {
                weakSelf?.show(iVc, sender: nil)
            }
        }
      
        if SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId) {
            taskItem.accessoryType = .edit
        } else {
            taskItem.accessoryType = .none
        }
        if tasks.count == 0 {
            tasks.add(taskItem)
        }
    }

    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemLists.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? String(format: "ID:%d", (macro?.macroInfo?.macroId)!) : ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let groupList = itemLists[section] as! NSMutableArray
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let groupsList: NSMutableArray = itemLists[indexPath.section]  as! NSMutableArray
        if indexPath.section == 0 && indexPath.row == 0{
            return 88
        }
        if (groupsList == additionals) || (groupsList == triggers) || (groupsList == tasks){
            if(indexPath.row == 0){
                let groupList = itemLists[indexPath.section] as! NSMutableArray
                let item: TopItem = groupList[indexPath.row] as! TopItem
                let messageSize = TopDataManager.shared.textSize(text: item.detailedText, font: UIFont.systemFont(ofSize: 11), maxSize: CGSize(width: self.view.width - 32, height: CGFloat.greatestFiniteMagnitude))
                return messageSize.height + 72
            }
            if  (groupsList == tasks){
                return 88
            }
        }
      
        return 44
    }
    
    /**
     *
     */
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let groupList = itemLists[indexPath.section] as! NSMutableArray
       
        
        if indexPath.section == 0 {
             let item: TopItem = groupList[indexPath.row] as! TopItem
            
            if indexPath.row == 0{
                let item: TopItem = groupList[indexPath.row] as! TopItem
               
                let cell:TopRightIconTBCell = tableView.dequeueReusableCell(withIdentifier: "TopRightIconTBCell")
                    as! TopRightIconTBCell
                cell.item = item
                iconCell = cell
                cell.selectionStyle = .none
                let attText: NSMutableAttributedString = NSMutableAttributedString(string: (item.text))
                attText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, ( item.text.utf16.count)))
                cell.textLabel?.attributedText = attText
                cell.accessoryType = .disclosureIndicator
                return cell
                
            }
            if indexPath.row == 1{
                let cell: TopTextInputCell =  TopTextInputCell(style: .default, reuseIdentifier: "TopTextInputCell")
                cell.item = item
               // let text = item.text
                let attText: NSMutableAttributedString = NSMutableAttributedString(string: (item.text))
                attText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, ( item.text.utf16.count)))
                cell.textLabel?.attributedText = attText
                textInputCell = cell
                textInputCell.delegate = self
                textInputCell.textField?.isUserInteractionEnabled = SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId)
               
                cell.selectionStyle = .none
                return cell;
                
            }
            
           
           
        }
        else if indexPath.section == itemLists.count-2 && SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId) {
            let item: TopItem = groupList[indexPath.row] as! TopItem
            let cell: UITableViewCell = UITableViewCell()
            cell.textLabel?.text = item.text
            
            cell.textLabel?.textColor = APP_ThemeColor
            if  (macro?.name.isEmpty)! {cell.textLabel?.textColor = UIColor.gray}
            copyCell = cell;
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.selectionStyle = .none
            cell.textLabel?.frame = cell.contentView.frame
            cell.textLabel?.textAlignment = .center
            return cell;
        }
        
        else if indexPath.section == itemLists.count-1 && SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId) {
            let item: TopItem = groupList[indexPath.row] as! TopItem
            let cell: UITableViewCell = UITableViewCell()
            cell.textLabel?.text = item.text
           
           
            if  (macro?.name.isEmpty)! {cell.textLabel?.textColor = UIColor.gray}
            deleteCell = cell;
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.selectionStyle = .none
            cell.textLabel?.textColor = UIColor.red
            cell.textLabel?.frame = cell.contentView.frame
            cell.textLabel?.textAlignment = .center
            return cell;
        }
    
        
        if (groupList == self.additionals)  || (groupList == self.triggers){
            if indexPath.row == 0{
                let item: TopItem = groupList[indexPath.row] as! TopItem
              
                let cell: TopConditionTitleCell = tableView.dequeueReusableCell(withIdentifier: "TopConditionTitleCell") as! TopConditionTitleCell
                if item == addtionalItem {
                    addtionalItem.detailedText = groupList.count == 1 ? NSLocalizedString("No addition, please add.", tableName: "MacroPage") : NSLocalizedString("The execution of the scenario is only if the following conditions are satisfied.", tableName: "MacroPage")
                }else {
                    triggerItem.detailedText = groupList.count == 1 ? NSLocalizedString("No trigger, please add.", tableName: "MacroPage") : NSLocalizedString("When the next condition is satisfied,the scenario will implement，and the restrictive conditions will be judged.", tableName: "MacroPage")
                }
                cell.item = item
                if groupList.count == 1{
                    cell.rightBtn.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
                    
                }
                
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            }
            else{
              
                if (indexPath.row < groupList.count){
                    let condition: TopCondition = groupList[indexPath.row] as! TopCondition
                    if condition.conditionType == .time{
                        let cell: TopTimingConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopTimingConditionCell") as! TopTimingConditionCell
                        cell.condition = condition
                         cell.selectionStyle = .none
                        return cell
                    }
                    else if condition.conditionType == .effectiveTime{
                        let cell: TopUsefulTimeConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopUsefulTimeConditionCell") as! TopUsefulTimeConditionCell
                        cell.condition = condition
                        cell.selectionStyle = .none
                        return cell
                    }
                    
                    let cell: TopConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopConditionCell") as! TopConditionCell
                    
                    cell.condition = condition
                    
                    return cell
                    
                    
                }
            }
            
        }//end else
        
        else if (groupList == tasks){
            if indexPath.row == 0{
                let item: TopItem = groupList[indexPath.row] as! TopItem
                let cell: TopConditionTitleCell = tableView.dequeueReusableCell(withIdentifier: "TopConditionTitleCell") as! TopConditionTitleCell
                item.detailedText = groupList.count == 1 ? NSLocalizedString("No addition, please add.", tableName: "MacroPage") : NSLocalizedString("This rountine executes the following action(s) in order.", tableName: "MacroPage")
                cell.item = item
                
                if groupList.count == 1{
                    cell.rightBtn.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
                }
                cell.delegate = self
                cell.selectionStyle = .none
                return cell
            } else {
                if (indexPath.row < tasks.count) {
                    
//                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
                    
                    
                    let task: TopTask = tasks[indexPath.row] as! TopTask
                    let cell:TopTaskCell = tableView.dequeueReusableCell(withIdentifier: "TopTaskCell") as! TopTaskCell
                    cell.deleteBtn.isHidden = true
                   
                    cell.task = task
                    //  cell.delegate = self
                    cell.hideArrowView(true)
                    return cell
                }
            }
        }
        let item: TopItem = groupList[indexPath.row] as! TopItem
        let cell: TopSuperCell = TopSuperCell(style: .value1, reuseIdentifier: "TopSuperCell")
        cell.item = item
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        let attText: NSMutableAttributedString = NSMutableAttributedString(string: (item.text))
        attText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 15)], range: NSMakeRange(0, ( item.text.utf16.count)))
        
        if item.detailedText.count > 0 {
            let detailaAttText: NSMutableAttributedString = NSMutableAttributedString(string: (item.detailedText))
            detailaAttText.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font:  UIFont.boldSystemFont(ofSize: 13)], range: NSMakeRange(0, ( item.detailedText.utf16.count)))
            cell.detailTextLabel?.attributedText = detailaAttText
        }
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        if !SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId){
            if cell == textInputCell || cell == iconCell {
                GlobarMethod.notifyInfo(withStatus: NSLocalizedString("Not an admin can't modify it.", tableName: "MacroPage"))
            }
            return
        }
        
        
        if cell != textInputCell {
            textInputCell.textField?.endEditing(true)
        }
    
        tableView.deselectRow(at: indexPath, animated: true)
       
        let groupList = itemLists[indexPath.section] as! NSMutableArray
        if  (groupList == additionals) || (groupList == tasks) || (groupList == triggers){
            if indexPath.row >= 1{
                return
            }
        }
        let item: TopItem = groupList[indexPath.row] as! TopItem
        weak var weakSelf = self
        item.block(weakSelf!)
        if cell == copyCell {
            if TopDataManager.shared.isChanged == true {
                SGlobalVars.macroHandle.macroSetReq(TopDataManager.shared.homeId, action: GLActionFullType.update, macroFullInfo: macro?.macroFullInfo)
            }
            
            macro?.macroID = 0
            macro?.order = 0
            let newName = (macro?.name)!+NSLocalizedString("_Copy", comment: "")
            if newName.lengthOfBytes(using: .utf8) < 32 {
                macro?.name = newName
            }
            
            if SGlobalVars.macroHandle.macroSetReq(TopDataManager.shared.homeId, action: GLActionFullType.insert, macroFullInfo: macro?.macroFullInfo) == 0 {
                self.processTimerStart(3)
            }else {
                GlobarMethod.notifyNetworkError()
            }
        }
        else if cell == deleteCell {
            
            let alertController = UIAlertController(title: NSLocalizedString("Delete",  comment: "")+"?", message:  self.macro?.name, preferredStyle: .actionSheet)
            let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .cancel, handler: nil)
            
            weak var weakSelf = self
            let actionOk = UIAlertAction(title: NSLocalizedString("Delete" , comment: ""), style: .destructive, handler: {
                (action) -> Void in
                weakSelf?.macro?.action = .delete
                if   SGlobalVars.macroHandle.macroSetReq(TopDataManager.shared.homeId, action:(weakSelf?.macro?.action)! , macroFullInfo: weakSelf?.macro?.macroFullInfo) == 0{
                    
                    
                    weakSelf?.processTimerStart(3.0)
                }else{
                    GlobarMethod.notifyFailed()
                }
               
                
            })
            
            if (alertController.popoverPresentationController != nil) {
                alertController.popoverPresentationController?.sourceView = cell
                alertController.popoverPresentationController?.sourceRect = cell.bounds
            }
            alertController.addAction(actionCancel)
            alertController.addAction(actionOk)
            
            if (alertController.popoverPresentationController != nil) {
                let cell = tableView.cellForRow(at: indexPath)
                alertController.popoverPresentationController?.sourceView = cell
                alertController.popoverPresentationController?.sourceRect = (cell?.bounds)!
            }
            present(alertController, animated: true, completion: nil)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textInputCell.textField?.endEditing(true)
    }
    
    
    func textInputCellDidChangeText(_ cell: TopTextInputCell, text: String) { 
        TopDataManager.shared.isChanged = true
        self.macro?.name = text
        if text.count >= 0 {
            saveItem.tintColor = APP_ThemeColor
        }else{
            saveItem.tintColor = UIColor.white
        }
        
    }
    func selectMacroIconVCDidSlecetIcon(_ item: TopItem) {
        if macro?.icon != item.iconNum{
            TopDataManager.shared.isChanged = true
            macro?.icon = item.iconNum
            iconItem?.icon =  (macro?.iconName)!
            self.tableView.reloadData()
        }
    }
    
    

    
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
        if !SGlobalVars.homeHandle.getHomeAdminIsMe(TopDataManager.shared.homeId){
            GlobarMethod.notifyInfo(withStatus: NSLocalizedString("Not an admin can't modify it.", tableName: "MacroPage"))
            item.swichIsOn = !item.swichIsOn
            self.tableView.reloadData()
            return
        }
        self.isEditing = true
        TopDataManager.shared.isChanged = true
        if item == self.notifyItem {
             macro?.pushOnOff = item.swichIsOn
        } else if item == self.outoMacroItem {
            macro?.autoOnOff =  self.outoMacroItem.swichIsOn
            if item.swichIsOn == false{
                macro?.pushOnOff = false
            }
            initItemList()
        }
       
    }
    
    func conditionTitleCellDelegateDidClickedAccessoryView(_ item: TopItem, cell: TopConditionTitleCell) {
        item.block(self)
        
    }
    
    func typeSelectedVCDidSelectMode(_ mode: GLSecurityModeType) {
        self.macro?.security_mode = mode
        securityModeItem.detailedText = (self.macro?.security_mode_str)!
        self.tableView.reloadData()
    }
    
    
}

