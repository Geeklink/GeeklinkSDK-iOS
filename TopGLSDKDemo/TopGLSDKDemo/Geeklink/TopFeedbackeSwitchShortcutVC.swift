//
//  TopFeedbackeSwitchShortcutVC.swift
//  Geeklink
//
//  Created by YanFeiFei on 2018/12/28.
//  Copyright © 2018 Geeklink. All rights reserved.
//

import UIKit

import IntentsUI

@available(iOS 12.0, *)

class TopFeedbackeSwitchShortcutVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate, INUIAddVoiceShortcutViewControllerDelegate {
    
    weak var deleteCell: UITableViewCell?
    
    var task: TopTask?
    
   
    var homeInfo: GLHomeInfo!
  
    var road: Int32?
    var addVoiceShortcutVC: INUIAddVoiceShortcutViewController!
    var list = NSMutableArray()
    var type: TopFeedbackSwitchSetVCType = .TopFeedbackSwitchSetVCTypeAdd
    var selectItem: TopItem?
    var selectedRow :Int = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //设置文本
        title = NSLocalizedString("Feedback Switch", tableName: "MacroPage")
      
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Next", comment: ""), style: .done, target: self, action: #selector(addShortsuts))
        
        initTaskItem()
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
    }
    
    @objc func addShortsuts() -> Void {
        let itemList: Array = list[0] as! Array<TopItem>
        var item0: TopItem = TopItem()
        var item1: TopItem = TopItem()
        var item2: TopItem = TopItem()
        var item3: TopItem = TopItem()
        let totalCount: Int32 = (task?.switchCount)!
        var isHasCol: Bool = false
        for index in 1...totalCount {
            switch index {
            case 1:
                item0 = itemList[0]
                if item0.swichIsCol == true{
                    isHasCol = true
                }
            case 2:
                item1 = itemList[1]
                if item1.swichIsCol == true{
                    isHasCol = true
                }
            case 3:
                item2 = itemList[2]
                if item2.swichIsCol == true{
                    isHasCol = true
                }
            case 4:
                item3 = itemList[3]
                if item3.swichIsCol == true{
                    isHasCol = true
                }
            default:
                break
            }
        }
        
        
        if (isHasCol == false) {
            self.alertMessage(NSLocalizedString("Control at least one button", tableName: "MacroPage") , withTitle: NSLocalizedString("Error", tableName: "MacroPage"))
            return
        }
        
        let switchCtrlInfo = GLSwitchCtrlInfo(rockBack: (task?.switchCtrlInfo.rockBack)!, aCtrl: item0.swichIsCol, bCtrl: item1.swichIsCol, cCtrl: item2.swichIsCol, dCtrl: item3.swichIsCol, aOn: item0.swichIsOn, bOn: item1.swichIsOn, cOn: item2.swichIsOn, dOn: item3.swichIsOn)
        
        var value = SGlobalVars.actionHandle.getFeedbackSwicthActionValue(switchCtrlInfo)
        if task?.device?.mainType == .geeklink {
              value = SGlobalVars.actionHandle.getWiFiSocketActionValue(switchCtrlInfo)
        }
        
        task?.value = value
        
//        if #available(iOS 12.0, *) {
        
            let intent  = TopIntent()
            //intent.homeId = Globa
            
            intent.homeID = TopDataManager.shared.homeId
            intent.iD = String.init(format: "%d", (task?.device?.deviceId)!)
            intent.action = value
           
            intent.remarks = task?.operationName.string
            intent.type = "device"
            intent.oem = String.init(format: "%d", Int(App_Company.rawValue))
            intent.md5 = task?.device?.md5
            intent.subId = String.init(format: "%d", (task?.device?.subId)!)
            let interaction: INInteraction  = INInteraction.init(intent: intent, response: nil)
            interaction.identifier = String.init(format: "%d", (task?.device?.deviceId)!)
           
            interaction.donate { (error) in
                
            }
            
            guard let shortcut = INShortcut.init(intent: intent) else { return }
            
            let controller = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            controller.delegate = self
            addVoiceShortcutVC = controller
            self.present(controller, animated: true) {
                
            }
//        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        tableView.reloadData()
    }

    
    
    override func viewWillDisappear(_ animated: Bool) {
       
        super.viewWillDisappear(animated)
    }
    
    
  
    
    //MARK: -
    
    func initTaskItem() -> Void {
        list.removeAllObjects()
        task = TopDataManager.shared.task!
        var iconList = [String]()
        
        iconList.append("scene_a")
        iconList.append("scene_b")
        iconList.append("scene_c")
        iconList.append("scene_d")
        
        let totalCount: Int32 = (task?.switchCount)!
        
        var itemList0 = [TopItem]()
        
        for index in 1...totalCount{
            let iconItem = TopItem()
            var icon: String  = ""
            var title: String = ""
            if index <= iconList.count{
                icon = iconList[Int(index) - 1]
                title = SGlobalVars.roomHandle.getSwitchNoteName(TopDataManager.shared.homeId, deviceId: (task?.device?.deviceId)!, road: index)
            }
            if title == "" {
                title = NSLocalizedString("Button", tableName: "MacroPage")
            }
            iconItem.text = title
            iconItem.icon = icon
            
            
            if index == 1{
                iconItem.swichIsOn = (task?.switchCtrlInfo.aOn)!
                iconItem.swichIsCol = (task?.switchCtrlInfo.aCtrl)!
                
            }
            else if index == 2{
                iconItem.swichIsOn = (task?.switchCtrlInfo.bOn)!
                iconItem.swichIsCol = (task?.switchCtrlInfo.bCtrl)!
                
            }
            else if index == 3{
                iconItem.swichIsOn = (task?.switchCtrlInfo.cOn)!
                iconItem.swichIsCol = (task?.switchCtrlInfo.cCtrl)!
                
            }
            else if index == 4{
                iconItem.swichIsOn = (task?.switchCtrlInfo.dOn)!
                iconItem.swichIsCol = (task?.switchCtrlInfo.dCtrl)!
                
            }
            
            
            iconItem.accessoryType = .disclosureIndicator
            itemList0.append(iconItem)
        }
        
        list.add(itemList0)
        
        
    }
   
  
    
    
    //MARK: - UITableView
    
 
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemList: Array = list[section] as! Array<TopItem>
        return  itemList.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return list.count
    }
    

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
           
            return NSLocalizedString("Select, please", tableName: "MacroPage")
          
        }
        return  ""
    }
    
    
    
    
    
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemList: Array = list[indexPath.section] as! Array<TopItem>
        let item: TopItem =  itemList[indexPath.row]
        if task?.switchCtrlInfo.rockBack == true {
            let cell: TopSuperCell = TopSuperCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TopSuperCell")
            cell.setLeftBtnSelected(false)
            cell.indexPath = indexPath
            cell.item = item
            if (item.swichIsCol){
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
            cell.selectionStyle = .none
            return cell
        }else {
            let cell: TopSuperCell = TopSuperCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "TopSuperCell")
            cell.setLeftBtnSelected(false)
            cell.textLabel?.numberOfLines = 0
            cell.indexPath = indexPath
            cell.item = item
            
            if (item.swichIsCol){
                if (item.swichIsOn){
                    cell.detailTextLabel?.text = NSLocalizedString("Turn on", tableName: "MacroPage")
                }
                else{
                    cell.detailTextLabel?.text = NSLocalizedString("Turn off", tableName: "MacroPage")
                }
            }else{
                cell.detailTextLabel?.text = NSLocalizedString("No control", tableName: "MacroPage")
            }
            cell.accessoryView?.isHidden = false
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let view = tableView.cellForRow(at: indexPath)
        let itemList: Array = list[indexPath.section] as! Array<TopItem>
        let item: TopItem = itemList[indexPath.row]
        selectItem = item
    
       
        if task?.switchCtrlInfo.rockBack  == true{
            item.swichIsCol = !item.swichIsCol
            self.tableView.reloadData()
            return
        }
        
        if indexPath.section ==  0{
            changeItemValue(item, view: view!)
            
        }
    }
    
    //MARK: -
    
    func changeItemValue(_ item: TopItem, view: UIView) {
        let alertController = UIAlertController(title: nil, message:  nil, preferredStyle: .actionSheet)
        
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
        if (alertController.popoverPresentationController != nil) {
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = view.bounds
        }
        weak var weakSelf = self
        let actionTurnOn = UIAlertAction(title: NSLocalizedString("Turn on", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            item.swichIsCol = true
            item.swichIsOn = true
            weakSelf?.tableView.reloadData()
        })
        let actionTurnOff = UIAlertAction(title: NSLocalizedString("Turn off", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            item.swichIsCol = true
            item.swichIsOn = false
            weakSelf?.tableView.reloadData()
        })
        let actionNOControl = UIAlertAction(title: NSLocalizedString("No control", tableName: "MacroPage"), style: .default, handler: {
            (action) -> Void in
            item.swichIsCol = false
            item.swichIsOn = false
            weakSelf?.tableView.reloadData()
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionTurnOn)
        alertController.addAction(actionTurnOff)
        alertController.addAction(actionNOControl)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        addVoiceShortcutVC.dismiss(animated: true) {
          
        }
        GlobarMethod.notifySuccess()
        for vc in (self.navigationController?.viewControllers)! {
            if vc is TopSiriShortCutsListVC {
                self.navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
        
    }
    
    @available(iOS 12.0, *)
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        addVoiceShortcutVC.dismiss(animated: true) {
            
        }
    }
    
    
}




