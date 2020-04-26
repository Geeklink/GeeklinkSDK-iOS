//
//  TopMacroManagerListVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/9/25.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopMacroManagerListVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource, TopSuperCellDelegate {
   
    @IBOutlet weak var tableView: UITableView!
    var  macro: TopMacro!
  
    var itemListList =  Array<Array<TopItem>>.init()
    var memberItemList = Array<TopItem>.init()
    var memberList = Array<GLMemberInfo>.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initItemList()
        self.homeMemberGetResp(notificatin: nil)
        self.title =  NSLocalizedString("Members Enable", tableName: "RoomPage")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_back"), style: .done, target: self, action: #selector(leftBarButtonItemDidClicked))
       
    }
    @objc func leftBarButtonItemDidClicked() -> Void {
        let allMemberList = itemListList[0]
        let allMemberItem = allMemberList[0]
        
        let adminList = itemListList[1]
        let adminItem = adminList[0]
        
        var membersStr = ""
        if allMemberItem.isSelected == true {
            membersStr = ""
        }else if adminItem.isSelected == true {
            membersStr = "admin"
        }else {
            for member in self.memberItemList {
                if member.isSelected {
                    if membersStr == "" {
                        membersStr = member.detailedText
                    }else {
                        membersStr += ","+member.detailedText
                    }
                }
            }
            if membersStr.count == 0 {
                GlobarMethod.notifyError(withStatus: NSLocalizedString("Choose at least one", tableName: "RoomPage"))
                return
            }
        }
        macro.members = membersStr
        
        navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(homeMemberGetResp), name:NSNotification.Name("homeMemberGetResp"), object: nil)
        
        getRefreshData()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("homeMemberGetResp"), object: nil)
        
    }
    
    @objc func homeMemberGetResp(notificatin: Notification?) {//获取返回
        //刷新列表
        memberItemList.removeAll()
        var  memberList = SGlobalVars.homeHandle.getHomeMemberList((SGlobalVars.curHomeInfo.homeId)!) as! Array<GLMemberInfo>
        var index = 0
        var selectedAccountList = [String].init()
        if macro.members.count > 0 {
            selectedAccountList = macro.members.components(separatedBy: ",")
        }
        for member in memberList {
            if member.account == SGlobalVars.api.getCurUsername() {
                memberList.remove(at: index)
                continue
            }
            let item = TopItem.init()
            item.text = member.note
            for account in selectedAccountList {
                if account == member.account {
                    item.isSelected = true
                }
            }
            item.icon = "room_member"
            item.accessoryType = .selectedBtn
            item.detailedText = member.account
            self.memberItemList.append(item)
            index += 1
        }
        let item = TopItem.init()
        item.text = NSLocalizedString("Admin", comment: "")
        item.icon = "room_admin"
        item.accessoryType = .checkmark
        item.isSelected = true
        item.detailedText = (SGlobalVars.api.getCurUsername())!
        self.memberItemList.append(item)
        self.itemListList.remove(at: 2)
        self.itemListList.append(memberItemList)
        tableView.reloadData()
    }
    
    func initItemList() -> Void {
        var itemList0 = Array<TopItem>.init()
        let allMemberItem = TopItem.init()
        allMemberItem.accessoryType = .selectedBtn
        allMemberItem.text = NSLocalizedString("All members can use  it", tableName: "RoomPage")
        itemList0.append(allMemberItem)
        allMemberItem.icon = "room_allmember"
        self.itemListList.append(itemList0)
        
        var itemList1 = Array<TopItem>.init()
        let adminItem = TopItem.init()
        adminItem.icon = "room_admin"
        adminItem.accessoryType = .selectedBtn
        adminItem.text = NSLocalizedString("Only admin can use it", tableName: "RoomPage")
        itemList1.append(adminItem)
        self.itemListList.append(itemList1)
        
        if macro.members == "" {
            allMemberItem.isSelected = true
        }
        
        if macro.members == "admin" {
            adminItem.isSelected = true
        }
       
        
        self.itemListList.append(memberItemList)
        self.tableView.reloadData()
        
    }
    override func getRefreshData() -> Void {
        SGlobalVars.homeHandle.homeMemberGetReq((SGlobalVars.curHomeInfo.homeId)!)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemListList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemList = itemListList[section]
        if section == 2 {
            return itemList.count == 0 ?  1 : itemList.count
        }
        return itemList.count
        
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2:
            return NSLocalizedString("The selected members and admin can use it.", tableName: "RoomPage")
        default:
            return ""
        }
    }
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemList = itemListList[indexPath.section]
        if indexPath.section == 2 {
            if itemList.count == 0 {
                let cell: UITableViewCell = UITableViewCell.init()
                cell.textLabel?.frame = cell.contentView.frame
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = UIColor.gray
                cell.textLabel?.text = NSLocalizedString("There are no members to choose from", tableName: "RoomPage")
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                return cell
            }
        }
        
        
        
        
       let cell :TopSuperCell  = TopSuperCell.init(style: .subtitle, reuseIdentifier: "")
        cell.item = itemList[indexPath.row]
        if indexPath.section == 2 {
            let adminList = itemListList[1]
            let adminItem = adminList[0]
            cell.delegate = self
            let allMemberList = itemListList[0]
            let allMemberItem = allMemberList[0]
            if adminItem.isSelected == true{
                cell._selectedBtn?.isSelected = false
            }
            if allMemberItem.isSelected == true{
                cell._selectedBtn?.isSelected = true
            }
            cell.selectionStyle = .none
            
        }
        return cell
    }
    
    func selectIndexPath(_ indexPath: IndexPath) -> Void {
        let itemList = itemListList[indexPath.section]
        if indexPath.section == 2 {
            if itemList.count == 0 {
                return
            }
        }
        
        
        
        let item = itemList[indexPath.row]
        
        let allMemberList = itemListList[0]
        let allMemberItem = allMemberList[0]
        
        let adminList = itemListList[1]
        let adminItem = adminList[0]
        
        
        if indexPath.section == 2 {
            
            if indexPath.row == itemList.count - 1 {
                return
            }
            
            if adminItem.isSelected == true || allMemberItem.isSelected == true {
                adminItem.isSelected = false
                allMemberItem.isSelected = false
                if item.isSelected == false {
                    if self.checkHasFullMember() == false {
                        let item = itemList[indexPath.row]
                        item.isSelected = true
                    }else {
                        self.alertMessage(NSLocalizedString("The number of available members in the scenario has reached 10 upper limits and cannot continue to be added.", tableName: "MacroPage"))
                    }
                }
                
                self.tableView.reloadData()
                return
            }
            
            
            if item.isSelected == false {
                if self.checkHasFullMember()  {
                    self.alertMessage(NSLocalizedString("The number of available members in the scenario has reached 10 upper limits and cannot continue to be added.", tableName: "MacroPage"))
                    return
                }
            }
            
            item.isSelected = !item.isSelected
            
            var selectedCount = 0
            for item in itemList {
                if item.isSelected {
                    selectedCount += 1
                }
            }
            if selectedCount == 0 {
                adminItem.isSelected = true
            }
            self.tableView.reloadData()
            return
        }
        if indexPath.section == 0 {
            
            adminItem.isSelected = false
        }
        
        if indexPath.section == 1 {
            
            allMemberItem.isSelected = false
        }
        
        item.isSelected = true
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       self.selectIndexPath(indexPath)
    }
    func checkHasFullMember() -> Bool {
        let itemList = itemListList[2]
        var selectedCount = 0
        for item in itemList {
            if item.isSelected {
                selectedCount += 1
            }
        }
        return selectedCount >= 10
    }
    
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
        selectIndexPath((cell.indexPath)!)
    }
    
}
