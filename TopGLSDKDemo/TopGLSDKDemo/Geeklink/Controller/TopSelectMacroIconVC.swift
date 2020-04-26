//
//  TopSelectMacroIconVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/15.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopSelectMacroIconVCDelegate : class {
    
    
    func selectMacroIconVCDidSlecetIcon(_ item: TopItem)
    
}
class TopSelectMacroIconVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate,TopSuperCellDelegate {
    
    weak var delegate : TopSelectMacroIconVCDelegate?
   
    var selectedRow :Int32 = 0
    weak var headerTipLabel: UILabel!
    weak var selectedCell: TopSuperCell?
    var list: NSMutableArray = NSMutableArray()
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        let screenW: CGFloat = UIScreen.main.bounds.size.width
        let tableHeaderFooterView :UITableViewHeaderFooterView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: screenW, height: 30))
        self.title = NSLocalizedString("Scenario icon", tableName: "MacroPage")
        
        let theHeaderTipLabel: UILabel = UILabel(frame: CGRect(x: 16, y: 0, width: screenW - 32, height: 30))
        headerTipLabel = theHeaderTipLabel
        headerTipLabel.text = NSLocalizedString("Select icon, pls", tableName: "MacroPage")
        tableHeaderFooterView.contentView.addSubview(headerTipLabel)
        self.tableView.tableHeaderView = tableHeaderFooterView;
         initList()
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
    }
    func initList()  {
        let nameList = NSArray(array: [NSLocalizedString("Go Home", tableName: "MacroPage"),NSLocalizedString("Leave Home", tableName: "MacroPage"),NSLocalizedString("Get up", tableName: "MacroPage"),NSLocalizedString("Sleep", tableName: "MacroPage"),NSLocalizedString("Eat", tableName: "MacroPage"),NSLocalizedString("Work", tableName: "MacroPage"),NSLocalizedString("Sports", tableName: "MacroPage"),NSLocalizedString("Film", tableName: "MacroPage"),NSLocalizedString("Music", tableName: "MacroPage"),NSLocalizedString("Receive", tableName: "MacroPage"),NSLocalizedString("Read", tableName: "MacroPage"),NSLocalizedString("Meeting", tableName: "MacroPage"),NSLocalizedString("Leisure time", tableName: "MacroPage"),NSLocalizedString("Entertainment", tableName: "MacroPage"),NSLocalizedString("Shading", tableName: "MacroPage"),NSLocalizedString("Purify", tableName: "MacroPage"),NSLocalizedString("Dehumidification", tableName: "MacroPage"),NSLocalizedString("Humidification", tableName: "MacroPage"),NSLocalizedString("Cooling", tableName: "MacroPage"),NSLocalizedString("Heat preservation", tableName: "MacroPage"),NSLocalizedString("Aeration", tableName: "MacroPage"),NSLocalizedString("Clean", tableName: "MacroPage"),NSLocalizedString("All the lights are turned off", tableName: "MacroPage"),NSLocalizedString("Turn on all lights", tableName: "MacroPage"),NSLocalizedString("Turn on when open door", tableName: "MacroPage"),NSLocalizedString("Turn on when somebody come", tableName: "MacroPage"),NSLocalizedString("Turn off when everybody leave", tableName: "MacroPage"),NSLocalizedString("Turn off AC when open door or window", tableName: "MacroPage"),NSLocalizedString("Custom", tableName: "MacroPage")])
        
        var index: Int32 = 0
        while index < nameList.count {
            let item: TopItem = TopItem()
            item.text = nameList[Int(index)] as! String
            item.iconNum = index
            item.accessoryType = .selectedBtn
            item.icon = GlobarMethod.getMacroIconName(index)
            index += 1
            list.add(item)
        }
        
    }
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }
        return 8;
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let item: TopItem = list[indexPath.section] as! TopItem
    
        let cell: TopSuperCell = TopSuperCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TopSuperCell")
        cell.item = item;
        if indexPath.section == selectedRow{
            cell.setLeftBtnSelected(true)
            selectedCell = cell
        }
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        cell.delegate = self as TopSuperCellDelegate
        return cell
        
      
    }
   
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
      
        let item: TopItem = list[(cell.indexPath?.section)!] as! TopItem
        delegate?.selectMacroIconVCDidSlecetIcon(item)
        self.navigationController?.popViewController(animated: true)
     
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        let item: TopItem = list[indexPath.section] as! TopItem
        delegate?.selectMacroIconVCDidSlecetIcon(item)
        self.navigationController?.popViewController(animated: true)


    }
}

