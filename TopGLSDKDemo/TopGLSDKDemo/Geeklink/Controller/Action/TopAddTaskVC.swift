//
//  TopAddOperationVCViewController.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/8.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

enum TopAddTaskVCType: Int {
    case TopAddTaskVCTypeMacroDone
    case TopAddTaskVCTypeMacroSave
    case TopAddTaskVCTypeSecuritySave
}

class TopAddTaskVC: TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopTaskCellDelegate {
  
    var type: TopAddTaskVCType = .TopAddTaskVCTypeMacroDone
    weak var showPickerView: PickerView?
    var editItem: UIBarButtonItem!
    var saveItem: UIBarButtonItem!
    var doneItem: UIBarButtonItem!
    var backVC: UIViewController?
    var taskList = Array<TopTask>()
    var safe : TopSafe?
    var currenTask: TopTask?
    var macro: GLMacroInfo?
    var isChanged: Bool = false
    weak var textInputCell: TopTextInputCell!
    weak var nextCell: UITableViewCell!
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //设置文本
        if type == .TopAddTaskVCTypeSecuritySave{
             title = NSLocalizedString("Execution task", tableName: "MacroPage")
        }else{
             title = NSLocalizedString("Perform Action", tableName: "MacroPage")
        }
       
       
        doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(editItemDidclicked))
        
        if (type == .TopAddTaskVCTypeMacroSave) ||
            (type == .TopAddTaskVCTypeSecuritySave) {
           
            saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action:#selector(saveItemDidclicked))
            saveItem.tintColor = APP_ThemeColor
        }
        
        let backItem = UIBarButtonItem(image: UIImage(named: "nav_back"), style: .done, target: self, action: #selector(backItemDidclicked))
        backItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = backItem
        
        if (type == .TopAddTaskVCTypeSecuritySave) {
            TopDataManager.shared.macro = nil
        }
        
        editItem  = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editItemDidclicked))
        
       
        
        //注册cell
        tableView.register(UINib(nibName: "TopTaskCell", bundle: nil), forCellReuseIdentifier: "TopTaskCell")
        
//        //清除导航栏下划线
//        let bar = navigationController?.navigationBar
//        bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        bar?.shadowImage = UIImage();
        
        //清除空白横线
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(macroSetResp), name:NSNotification.Name("macroSetResp"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(securityModeInfoResp), name:NSNotification.Name("securityModeInfoResp"), object: nil)
        
        
        getRefreshData()
       
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if showPickerView != nil {
            showPickerView?.frame = (UIApplication.shared.keyWindow?.bounds)!
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("securityModeInfoResp"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("macroConditionGetResp"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("macroSetResp"), object: nil)
    }
    
 
    //MARK: - getRefreshData
    
    override func getRefreshData() {
        
        if type == .TopAddTaskVCTypeSecuritySave{
            safe = TopDataManager.shared.safe
            taskList = (safe?.taskList)!
            tableView.reloadData()
           
            resetrightBarButtonItems()
            return
        }
        let macro = TopDataManager.shared.macro
        taskList = (macro?.tasks)!
        if taskList.count == 0 {
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let iVc: TopDeviceListVC = sb.instantiateViewController(withIdentifier: "TopDeviceListVC") as! TopDeviceListVC
            if backVC != nil {
                iVc.backVC = backVC
            }
            self.show(iVc, sender: nil)
        }
        tableView.reloadData()
        resetrightBarButtonItems()
    }
    
    //MARK: -
    
    @objc func securityModeInfoResp(notificatin: Notification) {
       //家庭设置回复
        processTimerStop()
        GlobarMethod.notifyDismiss()
        let info = notificatin.object as! TopSecurityAckInfo
        if info.state == .ok {
            safe?.securityAckInfo = info
            navigationController?.popViewController(animated: true)
            GlobarMethod.notifySuccess()
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
    @objc func macroSetResp(notificatin: Notification) {//请求条件列表回复
        processTimerStop()
       
        let info = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
            navigationController?.popToRootViewController(animated: true)
        }else if info.state == .fullError {
            GlobarMethod.notifyFullError()
        } else {
            GlobarMethod.notifyFailed()
        }
    }

    func resetrightBarButtonItems() -> Void {
        if type == .TopAddTaskVCTypeMacroDone{
            if tableView.isEditing {
                self.navigationItem.rightBarButtonItems = [doneItem]
                return
            }
            
            if taskList.count > 0 {
                
                self.navigationItem.rightBarButtonItems = [editItem]
            } else {
                navigationItem.rightBarButtonItems = []
            }
        }else{
            if taskList.count > 0 {
               
                if tableView.isEditing {
                     navigationItem.rightBarButtonItems = [doneItem]
                     saveItem.tintColor = UIColor.white
                }else{
                     saveItem.tintColor = APP_ThemeColor
                     navigationItem.rightBarButtonItems = [saveItem, editItem]
                }
            } else {
                navigationItem.rightBarButtonItems = [saveItem]
            }
        }
       
    }
    
    //MARK: - UITableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //+1 后面那个是加号
        if (tableView.isEditing) {
            return taskList.count
        }
        return taskList.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section >= taskList.count {
            return 44
        }
        return 88
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section < (taskList.count)) {
            let task: TopTask = taskList[indexPath.section] 
            let cell:TopTaskCell = tableView.dequeueReusableCell(withIdentifier: "TopTaskCell") as! TopTaskCell
            cell.task = task
            cell.delegate = self
            cell.hideArrowView(tableView.isEditing)
            cell.deleteBtn.isHidden = tableView.isEditing
            
            return cell
        } else {
            let cell: TopAddCell = TopAddCell(style: .default, reuseIdentifier: "")
            cell.setTitle(title: taskList.count == 0 ? NSLocalizedString("Fix Status", tableName: "MacroPage") : NSLocalizedString("Add More Action", tableName: "MacroPage"))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == taskList.count {
            let hostSubType: GLGlDevType = (GLGlDevType.init(rawValue: Int((TopDataManager.shared.hostDeviceInfo?.subType)!)))!
            switch hostSubType {
            case .thinker, .thinkerPro:
                if self.taskList.count >= 50{
                    GlobarMethod.notifyFullError()
                    return
                }
            case .thinkerMini:
                if self.taskList.count >= 16{
                    GlobarMethod.notifyFullError()
                    return
                }
            default:
                break
            }
             self.performSegue(withIdentifier: "TopDeviceListVC", sender: nil)
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            let task = taskList[indexPath.row]
            if task.device == nil {
                deleteTask(cell!, task: task)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) && (taskList.count == 0) {
            let screenW: CGFloat = UIScreen.main.bounds.size.width
            let height: CGFloat = 44
           
            let tableHeaderFooterView :UITableViewHeaderFooterView = UITableViewHeaderFooterView(frame: CGRect(x: 0, y: 0, width: screenW, height: height))
           
            let theHeaderTipLabel: UILabel = UILabel(frame: CGRect(x: 16, y: 0, width: screenW - 32, height: height))
            if type == .TopAddTaskVCTypeSecuritySave{
                 theHeaderTipLabel.text = NSLocalizedString("Please press the \"+\" button to adding scenario tasks.", tableName: "MacroPage")
            }else{
                theHeaderTipLabel.text = NSLocalizedString("Please press the \"+\" button to adding execution action.", tableName: "MacroPage")
            }
            theHeaderTipLabel.font = UIFont.systemFont(ofSize: 13)

            
            theHeaderTipLabel.numberOfLines = 0
            tableHeaderFooterView.contentView.addSubview(theHeaderTipLabel)
            tableHeaderFooterView.backgroundColor = UIColor.clear
            return tableHeaderFooterView;
        }
        return UIView(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 8))
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) && (taskList.count == 0) {
           return 44
        }
        else {
            return 8;
        }
    }
    
    
    //MARK: -
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let task = self.taskList[indexPath.section]
            let cell = tableView.cellForRow(at: indexPath)
            self.deleteTask(cell!, task: task)
        }
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.isChanged = true
        if sourceIndexPath.section == destinationIndexPath.section{
            return
        }
        let task = taskList[sourceIndexPath.section]
        taskList.remove(at: sourceIndexPath.section)
        let desSection = destinationIndexPath.section

        taskList.insert(task, at: desSection)
       
        self.tableView.reloadData()
    }
    
    //MARK: -
    
    func taskCellDidClickedRightTopButton(_ cell: TopTaskCell) {
        if tableView.isEditing{
            return
        }
        currenTask = cell.task
        
        if currenTask?.device == nil {
            deleteTask(cell, task: currenTask!)
            return
        }
        
        weak var weakSelf = self
        let showPickerView : PickerView = PickerView(frame: (UIApplication.shared.keyWindow?.bounds)!,time: (currenTask?.delay)!, showOnlyValidDates: true, type: .time)
        self.showPickerView = showPickerView
        showPickerView.titleLabel.text = NSLocalizedString("Setup Delay", tableName: "MacroPage")
        showPickerView.showInWindow { [unowned self] (time) in
            weakSelf?.currenTask?.delay = time
            self.tableView.reloadData()
        }
    }
    
    
    
    func taskCellDidClickedRightBottomButton(_ cell: TopTaskCell) {
        if tableView.isEditing{
            return
        }
        let task = cell.task
        let sb = UIStoryboard(name: "DeviceDetail", bundle: nil)
        if task?.device == nil {
            deleteTask(cell, task: task!)
            return
        }
        
        TopDataManager.shared.task = task
        
        switch task?.device?.mainType {
        case .custom?:
            let subType: Int = Int((task?.device?.deviceInfo.subType)!)
            let customType: GLCustomType = GLCustomType(rawValue:subType)!
            
            switch customType {
            case .AC,.TV,.STB,.soundbox,.fan, .rcLight, .acFan, .projector, .airPurifier, .oneKey:
                let adVc = sb.instantiateViewController(withIdentifier: "TopActionDatabaseVC") as! TopActionLiveDeviceVC
                adVc.deviceInfo = (task?.device?.deviceInfo)!
                
                adVc.homeInfo = SGlobalVars.curHomeInfo
                self.show(adVc, sender: nil)
            default:
                let acVc = sb.instantiateViewController(withIdentifier: "TopActionCustomVC") as! TopActionCustomVC
                acVc.deviceInfo = (task?.device?.deviceInfo)!
                
                acVc.homeInfo = SGlobalVars.curHomeInfo
                show(acVc, sender: nil)
            }
            
        case .database?:
            let adVc: TopActionLiveDeviceVC = sb.instantiateViewController(withIdentifier: "TopActionDatabaseVC") as! TopActionLiveDeviceVC
            adVc.deviceInfo =  (task?.device?.deviceInfo)!
            adVc.homeInfo = SGlobalVars.curHomeInfo
            adVc.oldActionInfo = (task?.action)!
            show(adVc, sender: nil)
        case .slave?:
            if (task?.device?.slaveType == .fb11) || (task?.device?.slaveType == .fb12) || (task?.device?.slaveType == .fb13) || (task?.device?.slaveType == .fb1Neutral1) || (task?.device?.slaveType == .ioModula) || (task?.device?.slaveType == .fb1Neutral2) || (task?.device?.slaveType == .fb1Neutral3) || (task?.device?.slaveType == .ioModulaNeutral) {
                if  (task?.switchCtrlInfo.rockBack)!{
                    let sb = UIStoryboard(name: "Macro", bundle: nil)
                    let feedbackSwitchSetVC = sb.instantiateViewController(withIdentifier: "TopFeedbackSwitchSetVC") as! TopFeedbackSwitchSetVC
                    feedbackSwitchSetVC.type = .TopFeedbackSwitchSetVCTypeAddTask
                    self.show(feedbackSwitchSetVC, sender: nil)
                 
                   
                }else{
                    let sb = UIStoryboard(name: "Macro", bundle: nil)
                   
                    TopDataManager.shared.task = task
                    let feedbackSwitchSetVC = sb.instantiateViewController(withIdentifier: "TopFeedbackSwitchSetVC") as! TopFeedbackSwitchSetVC
                    feedbackSwitchSetVC.type = .TopFeedbackSwitchSetVCTypeAddTask
                    self.show(feedbackSwitchSetVC, sender: nil)
                }
                
            } else if (task?.device?.slaveType == .curtain ||
                task?.device?.slaveType == .dimmerSwitch) {
                
                let sb = UIStoryboard(name: "DeviceDetail", bundle: nil)
                let curtainVc = sb.instantiateViewController(withIdentifier: "TopCurtainVC") as! TopSliderAndBtnVC
                curtainVc.type = .editTask
                self.show(curtainVc, sender: nil)
            } else if (task?.device?.slaveType == .siren) {
                
                let sb = UIStoryboard(name: "Macro", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "TopSirenTimePickerVC") as! TopSirenTimePickerVC
                vc.type = .edit
                self.show(vc, sender: nil)
            }
            break
        case .geeklink?:
            let glType: GLGlDevType = GLGlDevType(rawValue: Int((task?.device?.deviceInfo.subType)!))!
            switch glType {
                
            case .plug, .plugPower, .plugFour:
                
                
                 let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Make sure %@ and the home host (%@) is connect to same network", tableName: "MacroPage"), (task?.device?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    let adVc = sb.instantiateViewController(withIdentifier: "TopActionDatabaseVC") as! TopActionLiveDeviceVC
                    adVc.deviceInfo = (task?.device?.deviceInfo)!
                    adVc.homeInfo = SGlobalVars.curHomeInfo
                    self.show(adVc, sender: nil)
                    
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
            case .rgbwBulb :
                let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Make sure %@ and the home host (%@) is connect to same network", tableName: "MacroPage"), (task?.device?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    let sb = UIStoryboard(name: "Room", bundle: nil)
                    let adVc = sb.instantiateViewController(withIdentifier: "TopRGBWLightActionVC") as! TopRGBWLightActionVC
                    adVc.deviceInfo = task?.device?.deviceInfo
                    self.show(adVc, sender: nil)
                    
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
            case .rgbwLightStrip :
                let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Make sure %@ and the home host (%@) is connect to same network", tableName: "MacroPage"), (task?.device?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    let sb = UIStoryboard(name: "Room", bundle: nil)
                    let adVc = sb.instantiateViewController(withIdentifier: "TopRGBWLightActionVC") as! TopRGBWLightActionVC
                    adVc.deviceInfo = task?.device?.deviceInfo
                    self.show(adVc, sender: nil)
                    
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
            case .wifiCurtain:
                 let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Make sure %@ and the home host (%@) is connect to same network", tableName: "MacroPage"), (task?.device?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    let sb = UIStoryboard(name: "Room", bundle: nil)
                    let curtainVc = sb.instantiateViewController(withIdentifier: "TopCurtainVC") as! TopSliderAndBtnVC
                    self.show(curtainVc, sender: nil)
                    
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
            case .acManage:
                let alertController = UIAlertController(title: NSLocalizedString("Hint", comment: ""), message: String.init(format: NSLocalizedString("Make sure %@ and the home host (%@) is connect to same network", tableName: "MacroPage"), (task?.device?.deviceName)!, (TopDataManager.shared.hostDeviceInfo?.name)!), preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                
                let actionOk = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive, handler: {
                    (action) -> Void in
                    let sb = UIStoryboard(name: "ACManager", bundle: nil)
                    let vc: TopACManagerActionVC = sb.instantiateViewController(withIdentifier: "TopACManagerActionVC") as! TopACManagerActionVC
                    let acManageCtrlInfo: GLAcManageCtrlInfo =  (SGlobalVars.actionHandle.getAcManageActionInfo(task?.value))!
                    switch acManageCtrlInfo.ctrlType{
                    case .airConMode, .airConTemperature, .airConSpeed, .airConPower:
                        vc.type = GLAirConSubType.ac
                    case .freshPower, .freshSpeed, .freshMode:
                        vc.type = GLAirConSubType.freshAir
                    default:
                        vc.type = GLAirConSubType.underfloorHeating
                    }
                    
                    
                    self.show(vc, sender: nil)
                    
                })
                
                alertController.addAction(actionCancel)
                alertController.addAction(actionOk)
                present(alertController, animated: true, completion: nil)
                
            default:
                break
            }
         
        case .BGM?:
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let adVc = sb.instantiateViewController(withIdentifier: "TopAISpeakerActionVC") as! TopAISpeakerActionVC
            self.show(adVc, sender: nil)
        default:
            break
        }
    }
    
    func taskCellDidClickedDeleteButton(_ cell: TopTaskCell) {
        if tableView.isEditing{
            return
        }
        deleteTask(cell, task: cell.task!)
    }
    
    //MARK: -
    
    
    func deleteTask(_ view: UIView, task: TopTask){
        
        let alertController = UIAlertController(title: NSLocalizedString("Delete", tableName: "MacroPage")+"?", message:  TopDataManager.shared.condition?.name, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "MacroPage"), style: .cancel, handler: nil)
       
        weak var weakSelf = self
        let actionOk = UIAlertAction(title: NSLocalizedString("Delete", tableName: "MacroPage"), style: .destructive, handler: {
            (action) -> Void in
           weakSelf?.removeTask(task: task)
           
            
            
        })
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        present(alertController, animated: true, completion: nil)
    }

    @objc func backItemDidclicked(_ view: UIView) -> Void {
        if isChanged == true{
            TopDataManager.shared.isChanged = true
        }else{
            navigationController?.popViewController(animated: true)
            return
        }
        if type == .TopAddTaskVCTypeMacroDone{
            TopDataManager.shared.macro?.tasks = taskList
            navigationController?.popViewController(animated: true)
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
    
    
    @objc func saveItemDidclicked(_ sender: Any) {
        if tableView.isEditing {
            editItemDidclicked(saveItem as Any)
            return
        }
        if type == .TopAddTaskVCTypeMacroSave {
            TopDataManager.shared.macro?.tasks = taskList
            if SGlobalVars.macroHandle.macroSetReq(TopDataManager.shared.homeId, action:(TopDataManager.shared.macro?.action)!, macroFullInfo: TopDataManager.shared.macro?.macroFullInfo) == 0{
                processTimerStart(3.0)
            } else {
                GlobarMethod.notifyFailed()
            }
            return
        }
        if type == .TopAddTaskVCTypeSecuritySave {
            safe?.taskList = taskList
            if   SGlobalVars.securityHandle.securityModeInfoSetReq(TopDataManager.shared.homeId, securityModeInfo: safe?.securityModeInfo!) == 0 {
                processTimerStart(3.0)
            } else {
                GlobarMethod.notifyFailed()
            }
            return
        }
      
    }
    
    @objc func editItemDidclicked(_ sender: Any) {
        
        tableView.isEditing = !tableView.isEditing
        self.resetrightBarButtonItems()
        tableView.reloadData()
    }
    
    func addTask(task: TopTask) -> Void {
        isChanged = true
        if !taskList.contains(task) {
            taskList.append(task)
        }
        tableView.reloadData()
        resetrightBarButtonItems()
    }
    
    func removeTask(task: TopTask) -> Void {
        isChanged = true
        if taskList.contains(task) {
            var index = 0
            for theTask in taskList {
                if theTask == task {
                    taskList.remove(at: index)
                    resetrightBarButtonItems()
                    break
                }
                index += 1
            }
        }
        if taskList.count == 0{
            tableView.isEditing = false
        }
        tableView.reloadData()
    }
   
}

