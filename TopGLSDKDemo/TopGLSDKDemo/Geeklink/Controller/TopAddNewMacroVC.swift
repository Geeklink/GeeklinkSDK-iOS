//
//  TopAddNewMacroVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/7.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopAddNewMacroVC:  TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopTextInputCellDelegate,TopSuperCellDelegate, TopSelectMacroIconVCDelegate, UITextFieldDelegate, TopTypeSelectedVCDelegate{
    
    
    
    var itemLists: NSMutableArray =
        NSMutableArray()
    
    var itemNotifyList: NSMutableArray =
        NSMutableArray()
    var notifyItem :TopItem!
    
    weak var outoMacroItem :TopItem!
    
    weak var textInputCell: TopTextInputCell!
    weak var nextCell: UITableViewCell!
    var isChangeName: Bool = false
    var iconItem :TopItem?
    var nameItem :TopItem!
    var securityModeItem : TopItem = TopItem()
    var memberItem :TopItem!
    @IBOutlet weak var tableView: UITableView!
    
    
  
    
    
    var macro: TopMacro?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        initItemList()
     
        title = NSLocalizedString("Add scenario",tableName: "MacroPage")
        
        let notifyItem = TopItem()
        notifyItem.text = NSLocalizedString("Notification",tableName: "MacroPage")
        notifyItem.headerTitle = NSLocalizedString("",tableName: "MacroPage")
        notifyItem.accessoryType = .switchBtn
        self.notifyItem = notifyItem
        itemNotifyList.add(notifyItem)
        
        let cancelItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .done, target: self, action: #selector(cancelItemDidclicked))
        cancelItem.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = cancelItem
        
        self.navigationItem.backBarButtonItem?.action = #selector(cancelItemDidclicked)
        
        tableView.register(UINib(nibName: "TopRightIconTBCell", bundle: nil), forCellReuseIdentifier: "TopRightIconTBCell")
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
        
    }
    
    
    @objc func cancelItemDidclicked(_ view: UIView) -> Void {
        let alertController = UIAlertController(title: NSLocalizedString("Cancel add",tableName: "MacroPage")+"?", message:  "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel",tableName: "MacroPage"), style: .cancel, handler: nil)
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = view.bounds
        }
        
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Confirm",tableName: "MacroPage"), style: .destructive, handler: {
            (action) -> Void in
            weakSelf?.navigationController?.popToRootViewController(animated: true)
            
        })
        alertController.addAction(actionOk)
        alertController.addAction(actionCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
      
        //注册cell
        resetMemberItemDetailText()
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        
    }
   
    //请求回复
    
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
    
    func initItemList(){
        itemLists.removeAllObjects()
      
        macro = TopDataManager.shared.macro
        let itemList1: NSMutableArray =
            NSMutableArray()
    
        //itemList1
      
        
        iconItem = TopItem()
        iconItem?.accessoryType = .disclosureIndicator
        iconItem?.text = NSLocalizedString("Scenario icon",tableName: "MacroPage")
        weak var weakSelf = self
        iconItem?.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let selectIconVC: TopSelectMacroIconVC = sb.instantiateViewController(withIdentifier: "TopSelectMacroIconVC") as! TopSelectMacroIconVC
            selectIconVC.delegate = self
            selectIconVC.selectedRow = (weakSelf?.macro?.icon)!

            weakSelf?.navigationController?.show(selectIconVC, sender: nil)

           // vc.performSegue(withIdentifier: "TopSelectMacroIconVC", sender: nil)
            
        }
        iconItem?.icon = (macro?.iconName)!
        itemList1.add(iconItem!)
        itemLists.add(itemList1)
        
        nameItem = TopItem()
        nameItem.cellClassName = "TopTextInputCellTableViewCell"
        nameItem.text = NSLocalizedString("Scenario name",tableName: "MacroPage")
        nameItem.detailedText = (macro?.name)!
        itemList1.add(nameItem as Any)
        
        memberItem = TopItem()
        memberItem.cellClassName = "TopSuperCell"
        memberItem.text = NSLocalizedString("Members Enable",tableName: "RoomPage")
        memberItem.accessoryType = .disclosureIndicator
        resetMemberItemDetailText()
        memberItem?.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopMacroManagerListVC = sb.instantiateViewController(withIdentifier: "TopMacroManagerListVC") as! TopMacroManagerListVC
            
            vc.macro = (weakSelf?.macro)!
            weakSelf?.navigationController?.show(vc, sender: nil)
            
            // vc.performSegue(withIdentifier: "TopSelectMacroIconVC", sender: nil)
            
        }
        itemList1.add(memberItem as Any)
        
        securityModeItem = TopItem()
        securityModeItem.cellClassName = "TopSuperCell"
        securityModeItem.text = NSLocalizedString("Switch Security", tableName: "MacroPage")
        securityModeItem.accessoryType = .disclosureIndicator
        securityModeItem.detailedText = (macro?.security_mode_str)!
        securityModeItem.block = { (vc: UIViewController) in
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let vc: TopMacroSelectSecuriteVC = sb.instantiateViewController(withIdentifier: "TopMacroSelectSecuriteVC") as! TopMacroSelectSecuriteVC
            vc.delegate = self
            vc.securityModeType = (weakSelf?.macro?.security_mode)!
            weakSelf?.navigationController?.show(vc, sender: nil)
            // vc.performSegue(withIdentifier: "TopSelectMacroIconVC", sender: nil)
            
        }
        itemList1.add(securityModeItem as Any)
        
        
       
            //itemList2
        let itemList2: NSMutableArray =
            NSMutableArray()
        let outoMacroItem = TopItem()
        outoMacroItem.swichIsOn = (macro?.autoOnOff)!
        outoMacroItem.text = NSLocalizedString("Auto Execution",tableName: "MacroPage")
        outoMacroItem.detailedText = (macro?.name)!
        outoMacroItem.accessoryType = .switchBtn
        self.outoMacroItem = outoMacroItem
        itemList2.add(outoMacroItem)
        itemLists.add(itemList2)
        
        //itemNotifyList
       
        if  (macro?.autoOnOff == true){
            itemLists.add(itemNotifyList)
        }
        //itemList2
        let itemList3: NSMutableArray =
            NSMutableArray()
        let nextItem = TopItem()
        nextItem.text = NSLocalizedString("Next", comment: "")
        itemList3.add(nextItem)
        itemLists.add(itemList3)
        
    
    }
    
    
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return itemLists.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let groupList = itemLists[section] as! NSMutableArray
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0{
            return 88
        } else {
            return 44
        }
    }
    
    /**
     *
     */
    
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let groupList = itemLists[indexPath.section] as! NSMutableArray
        let item: TopItem = groupList[indexPath.row] as! TopItem
        
        if indexPath.section == 0 {
            if indexPath.row == 0{
                
                let cell:TopRightIconTBCell = tableView.dequeueReusableCell(withIdentifier: "TopRightIconTBCell")
                    as! TopRightIconTBCell
                cell.item = item
                cell.accessoryType = .disclosureIndicator
                return cell
                
            }
            
            if indexPath.row == 1{
                let cell: TopTextInputCell =  TopTextInputCell(style: .default, reuseIdentifier: "TopTextInputCell")
                cell.item = item
                textInputCell = cell
                textInputCell.delegate = self
        
                cell.selectionStyle = .none
                return cell;
                
            }
            let cell: TopSuperCell = TopSuperCell(style: .value1, reuseIdentifier: "TopSuperCell")
            cell.item = item
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.delegate = self
            return cell
 
        } else if indexPath.section == itemLists.count-1 {
    
            let cell: UITableViewCell = UITableViewCell()
            cell.textLabel?.text = item.text
            cell.textLabel?.textColor = APP_ThemeColor
            if  (macro?.name.isEmpty)! {cell.textLabel?.textColor = UIColor.gray}
            nextCell = cell;
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            cell.textLabel?.frame = cell.contentView.frame
            cell.textLabel?.textAlignment = .center
            return cell;
        }
       
        let cell: TopSuperCell = TopSuperCell(style: .default, reuseIdentifier: "TopSuperCell")
        cell.item = item
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        cell.delegate = self
        return cell
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        if  (TopDataManager.shared.stringIsEmoji(string) == true) {
            GlobarMethod.notifyError(withStatus: NSLocalizedString("Inputting illicit", comment: ""))
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        if cell != textInputCell {
             textInputCell.textField?.endEditing(true)
            textInputCell.textField?.delegate = self
        }
      
        
        tableView.deselectRow(at: indexPath, animated: true)
        let groupList = itemLists[indexPath.section] as! NSMutableArray
        let item: TopItem = groupList[indexPath.row] as! TopItem
        weak var weakSelf = self
        item.block(weakSelf!)
        
        if cell == nextCell {
            macro?.name = (textInputCell.textField?.text)!
            if(macro?.name.isEmpty)!{
                GlobarMethod.notifyError(withStatus:
                    NSLocalizedString("Please input the scenario name",tableName: "MacroPage"))
                textInputCell.textField?.becomeFirstResponder()
                return
            }
            if ((macro?.name.lengthOfBytes(using: String.Encoding.utf8))! >= 32) {
                self.alertMessage(NSLocalizedString("Name too long", comment: ""))
               
                return
                
            }
            
            
            if macro?.autoOnOff == true{
                self.performSegue(withIdentifier: "TopAddWorkingConditionVC", sender: nil)
            }else{
                let sb = UIStoryboard(name: "Macro", bundle: nil)
                let addTaskVC: TopAddTaskVC = sb.instantiateViewController(withIdentifier: "TopAddTaskVC") as! TopAddTaskVC
                if macro?.tasks.count == 0 {
                    addTaskVC.backVC = weakSelf
                }
                addTaskVC.type = .TopAddTaskVCTypeMacroSave
                self.show(addTaskVC, sender: nil)
            }
            
        }
    }
    
    func textInputCellDidChangeText(_ cell: TopTextInputCell, text: String) { 
        self.macro?.name = text
        nameItem.detailedText = text
        isChangeName = true
        if  (macro?.name.isEmpty)! {
            nextCell.textLabel?.textColor = UIColor.gray
        }
        else{
            nextCell.textLabel?.textColor = APP_ThemeColor
        }
        
    }
    
    func selectMacroIconVCDidSlecetIcon(_ item: TopItem) {
        macro?.icon = item.iconNum
        if isChangeName == false {
            macro?.name = item.text
            nameItem.detailedText = item.text
        }
        iconItem?.icon =  (macro?.iconName)!
        self.tableView.reloadData()
    }
    
    
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
        if item == self.notifyItem {
             macro?.pushOnOff = item.swichIsOn
        }else{
             macro?.autoOnOff = item.swichIsOn
            
           
            if (macro?.autoOnOff)! {
                if !itemLists.contains(itemNotifyList){
                    itemLists.insert(itemNotifyList, at:2)

                }
            }else{
                if itemLists.contains(itemNotifyList){
                    itemLists.remove(itemNotifyList)
                
                    item.swichIsOn = false
                    macro?.pushOnOff = false
                }
            }
            self.tableView.reloadData()
          
        }
       
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textInputCell.textField?.endEditing(true)
    }
    func typeSelectedVCDidSelectMode(_ mode: GLSecurityModeType) {
        self.macro?.security_mode = mode
        securityModeItem.detailedText = (self.macro?.security_mode_str)!
        self.tableView.reloadData()
    }
    
    
}
