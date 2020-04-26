//
//  TopSecurityConditionVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2019/4/23.
//  Copyright © 2019 Geeklink. All rights reserved.
//

import UIKit
enum TopSecurityConditionVCType: Int {
    case add
    case edit
}
class TopSecurityConditionVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource{
  
    private weak var selectItem: TopItem?
    @IBOutlet weak var tableView: UITableView!
    private  weak var selectedCell: TopSuperCell?
    var condition: TopCondition!
    
    var type = TopSecurityConditionVCType.add
    /**
     *选择的item数组
     */
    var _itemList: Array<TopItem>?
    var itemList: Array<TopItem>?{
        set{
            _itemList = newValue as Array<TopItem>?
        }get{
            if _itemList == nil{
                _itemList = [TopItem]()
                self.tableView.reloadData()
            }
            return _itemList
        }
    }
    
    var selectedRow :Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Security Mode", comment: "")
        getRefreshData()
    }
    override func getRefreshData() {
        self.condition = TopDataManager.shared.condition
        var safeList = Array<TopSafe>()
        
        
        
        let goOutSafe: TopSafe = TopSafe()
        goOutSafe.mode = .leave
        safeList.append(goOutSafe)
        TopDataManager.shared.safe = goOutSafe
        
        let atHomeSafe: TopSafe = TopSafe()
        atHomeSafe.mode = .home
        
        safeList.append(atHomeSafe)
        
        let nightSafe: TopSafe = TopSafe()
        nightSafe.mode = .night
        safeList.append(nightSafe)
        
        let disarm: TopSafe = TopSafe()
        disarm.mode = .disarm
        safeList.append(disarm)
        
        var itemList = [TopItem]()
        for safe in safeList {
            let icon: String =  safe.selectIcon
            let title: String = safe.name
            let iconItem = TopItem()
            
            iconItem.text = title
            iconItem.icon = icon
            iconItem.accessoryType = .disclosureIndicator
            itemList.append(iconItem)
        }
        self.itemList = itemList
        
        
        switch  condition.securityMode{
        case .leave:
            selectedRow = 0
        case .home:
            selectedRow = 1
        case .night:
            selectedRow = 2
        case .disarm:
            selectedRow = 3
        default:
            break
        }
        self.tableView.reloadData()
        
    }
    @objc func saveItemDidClicked() -> Void {
        var mode: GLSecurityModeType = .leave
        switch selectedRow {
        case 0:
            mode = .leave
        case 1:
            mode = .home
        case 2:
            mode = .night
        case 3:
            mode = .disarm

        default:
            break
        }
        let currentCondition: TopCondition  = TopDataManager.shared.condition!

        condition.securityMode = mode
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
    
    func deleteCondition(){
        
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
            
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1;
    }
    
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return type == .edit ? 2 : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return  itemList!.count
        default:
            return 1
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30;
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let item = itemList![indexPath.row]
            let cell: TopSuperCell = TopSuperCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TopSuperCell")
            
            cell.indexPath = indexPath
            cell.item = item
            
            cell.selectionStyle = .none
            return cell
            
        default:
            
            let cell: UITableViewCell = UITableViewCell()
            cell.textLabel?.text = NSLocalizedString("Delete", comment: "")
            cell.textLabel?.textColor = UIColor.red
            cell.textLabel?.frame = cell.contentView.frame
            cell.textLabel?.textAlignment = .center
           
            return cell;
        }
      
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            self.selectedRow = indexPath.row
            self.saveItemDidClicked()
        default:
           self.deleteCondition()
            
        }
        
        
    }
    
    
}
