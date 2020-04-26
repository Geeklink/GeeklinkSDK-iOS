//
//  TopAddSecutityVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/28.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

protocol TopAddAutoRuleVCDelegate : class {
    
    
    func addAutoRuleVCReturnAutoRuleInfo(_ autoRuleInfo: TopAutoRuleInfo) -> Bool;
    
}
class TopAddAutoRuleVC:  TopSuperVC ,UITableViewDelegate, UITableViewDataSource, TopTypeSelectedVCDelegate{
    weak var delegate : TopAddAutoRuleVCDelegate?
    
    var _autoRuleInfo: TopAutoRuleInfo?
    var  autoRuleInfo: TopAutoRuleInfo?{
        set{
            _autoRuleInfo = newValue as TopAutoRuleInfo?
        }
        get{
            if _autoRuleInfo == nil{
                _autoRuleInfo = TopAutoRuleInfo()
                _autoRuleInfo?.mode = .leave
            }
            return _autoRuleInfo
        }
   
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var itemList = [TopItem]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Add rule", comment: "")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveItemDidClicked))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetItem()
        
    }
    
    @objc func saveItemDidClicked() -> Void {
        
         

        if delegate?.addAutoRuleVCReturnAutoRuleInfo(self.autoRuleInfo!)  == false {
            return
        }
      
        self.navigationController?.popViewController(animated: true)
    }
   
   
    
    
    func resetItem() -> Void {
        itemList.removeAll()
        let timeItem: TopItem = TopItem()
        timeItem.text = NSLocalizedString("Timing setting", comment: "")
        timeItem.detailedText = (autoRuleInfo?.timeMode.timerStr)!+"\n"+(autoRuleInfo?.timeMode.weekDayStr)!
        weak var weakSelf = self
        timeItem.block = { (vc: UIViewController) in
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let timerVC: TopTimerVC = sb.instantiateViewController(withIdentifier: "TopTimerVC") as! TopTimerVC
            timerVC.type = .TopTimerVCTypeTimeSet
            timerVC.timerModel = weakSelf?.autoRuleInfo?.timeMode
            vc.show(timerVC, sender: nil)
            
        }
        timeItem.accessoryType = .disclosureIndicator
        itemList.append(timeItem)
        
        let securityItem: TopItem = TopItem()
        securityItem.text = NSLocalizedString("Security selecting", comment: "")
        securityItem.detailedText = (autoRuleInfo?.name)!
        securityItem.block = { (vc: UIViewController) in
            weakSelf?.showTypeSelectView()
            
        }
        
        securityItem.accessoryType = .disclosureIndicator
        itemList.append(securityItem)
        
        self.tableView.reloadData()
    }
        
        
    func showTypeSelectView(){
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
            iconItem.accessoryType = .selectedBtn
            itemList.append(iconItem)
        }
        
        var selectRow: Int = 0
        switch autoRuleInfo?.mode {
        case .leave?:
            selectRow = 0
        case .home?:
            selectRow = 1
        case .night?:
            selectRow = 2
        case .disarm?:
            selectRow = 3
        default:
            break
        }
        
        
  
        
        let sb = UIStoryboard(name: "Security", bundle: nil)
        let typeSelectedVC: TopTypeSelectedVC = sb.instantiateViewController(withIdentifier: "TopTypeSelectedVC") as! TopTypeSelectedVC
        typeSelectedVC.selectedRow = selectRow
        typeSelectedVC.itemList = itemList
        typeSelectedVC.delegate = self
        show(typeSelectedVC, sender: nil)
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        return itemList.count
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 44
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item: TopItem = itemList[indexPath.row]
        let cell: TopSuperCell = TopSuperCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "TopSuperCell")
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.item = item;
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        let item: TopItem = itemList[indexPath.row]
        weak var weakSelf = self
        item.block(weakSelf!)
    }
    
    func typeSelectedVCDidSelectMode(_ mode: GLSecurityModeType) {
        
        self.autoRuleInfo?.mode =  mode
    }
    
    
    
    
    
  
    
    
}
