//
//  TopSecutitySelectedVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/28.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit
protocol TopTypeSelectedVCDelegate : class {
    
    
    func typeSelectedVCDidSelectMode(_ mode: GLSecurityModeType)
    
}
class TopTypeSelectedVC: TopSuperVC, UITableViewDelegate, UITableViewDataSource, TopSuperCellDelegate{
    weak var delegate : TopTypeSelectedVCDelegate?
    private weak var selectItem: TopItem?
    @IBOutlet weak var tableView: UITableView!
    private  weak var selectedCell: TopSuperCell?
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveItemDidClicked))
        self.title = NSLocalizedString("Security selecting", comment: "")
       
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
        delegate?.typeSelectedVCDidSelectMode(mode)
        self.navigationController?.popViewController(animated: true)
    }
 
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  itemList!.count
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
          
            return NSLocalizedString("Select, please.", comment: "")
            
        }
        return  ""
    }
    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
     
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
            
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item: TopItem = itemList![indexPath.row]
        selectItem = item
        self.selectedRow = indexPath.row
        self.tableView.reloadData()
    }
    
    func superCellDidClickedAccessoryView(_ item: TopItem, cell: TopSuperCell) {
        selectedRow = (cell.indexPath?.row)!
        
        if selectedCell != nil {
            selectedCell?.setLeftBtnSelected(false)
            selectedCell = cell
            cell.setLeftBtnSelected(true)
            return
        }
        selectedCell = cell
        cell.setLeftBtnSelected(true)
        
    }
}
