//
//  TopMacroSelectSecuriteVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2019/4/23.
//  Copyright © 2019 Geeklink. All rights reserved.
//

import UIKit

class TopMacroSelectSecuriteVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource, TopSuperCellDelegate{
    weak var delegate : TopTypeSelectedVCDelegate?
    private weak var selectItem: TopItem?
    @IBOutlet weak var tableView: UITableView!
    private  weak var selectedCell: TopSuperCell?
    var securityModeType: GLSecurityModeType = .none
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
        self.itemList = itemList
        
       
        switch  securityModeType{
        case .leave:
            selectedRow = 0
        case .home:
            selectedRow = 1
        case .night:
            selectedRow = 2
        case .disarm:
            selectedRow = 3
        case .none:
            selectedRow = 4
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
        case 4:
            mode = .none
        default:
            break
        }
        delegate?.typeSelectedVCDidSelectMode(mode)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1;
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
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
            cell.setLeftBtnSelected(false)
            cell.indexPath = indexPath
            cell.item = item
            if indexPath.row == selectedRow{
                cell.setLeftBtnSelected(true)
                selectedCell = cell
            }
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
        default:
            
            let cell = UITableViewCell.init(style: .default, reuseIdentifier:"")
            cell.textLabel?.text =  NSLocalizedString("Do not switch security mode",tableName: "MacroPage")
            cell.accessoryType = .disclosureIndicator
            return cell
            
        }
      
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            self.selectedRow = indexPath.row
        default:
            self.selectedRow = 4
        }
        self.saveItemDidClicked()
       
    }
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
       
        self.selectedRow = (cell.indexPath?.row)!
        self.saveItemDidClicked()
        
    }
   
}
