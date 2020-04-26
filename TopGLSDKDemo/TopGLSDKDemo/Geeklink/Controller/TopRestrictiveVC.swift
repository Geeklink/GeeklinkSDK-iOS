//
//  TopRestrictiveVC.swift
//  Geeklink
//
//  Created by YANGFEIFEI on 2018/3/13.
//  Copyright © 2018年 Geeklink. All rights reserved.
//

import UIKit

class TopAditionVC:   TopSuperVC, UITableViewDataSource, UITableViewDelegate, TopConditionCellDelegate,TopUsefulTimeConditionCellDelegate{
   
 
    
    var editItem: UIBarButtonItem!
    var saveItem: UIBarButtonItem!
 
    
    var conditionList: NSMutableArray =
        NSMutableArray.init()
    
    weak var outoMacroItem :TopItem!
    
    weak var textInputCell: TopTextInputCell!
    weak var nextCell: UITableViewCell!
 
    @IBOutlet weak var tableView: UITableView!
    
  //  var macro: TopMacro?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupRefresh(tableView)
        //设置文本
        title = NSLocalizedString("Add start Condition", comment: "")
        
        tableView.register(UINib(nibName: "TopConditionCell", bundle: nil), forCellReuseIdentifier: "TopConditionCell")
        tableView.register(UINib(nibName: "TopUsefulTimeConditionCell", bundle: nil), forCellReuseIdentifier: "TopUsefulTimeConditionCell")
        
        
        saveItem = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action:#selector(saveItemDidclicked))
        editItem  = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(editItemDidclicked))
       
        
      
        self.navigationItem.rightBarButtonItems=[saveItem]
     
        
        //清除导航栏下划线
        let bar = navigationController?.navigationBar
        bar?.setBackgroundImage(UIImage.init(), for: UIBarMetrics.default)
        bar?.shadowImage = UIImage.init();
        
        //清除空白横线
        tableView.tableFooterView = UIView.init()
        
        //initItemList()
        setupRefresh(tableView)
    }
    
    func saveItemDidclicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    func editItemDidclicked(_ sender: Any) {
        
        self.tableView.isEditing = !self.tableView.isEditing
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        
        
        
        let macroConditionGet = NSNotification.Name(rawValue: "macroConditionGetResp")
        NotificationCenter.default.addObserver(self, selector: #selector(macroConditionGetResp), name:macroConditionGet, object: nil)
        
        let macroConditionOrder = NSNotification.Name(rawValue: "macroConditionOrderResp")
        NotificationCenter.default.addObserver(self, selector: #selector(macroConditionOrderResp), name:macroConditionOrder, object: nil)
        
        
        
        if ((TopDataManager.shared.macroAskInfo?.trigger) != nil) {
            
            resetConditionWithConditionList((TopDataManager.shared.macroAskInfo?.trigger)!)
        }
        
        
        tableView.reloadData()
        getRefreshData()
    }
    
    override func getRefreshData() {
        _ = TopDataManager.shared.resetDeviceInfo()
        
        GlobalVars.share().macroDataHandle.handle.macroConditionGetReq(TopDataManager.shared.homeId!, macroId: (TopDataManager.shared.macroInfo?.id)!)
        
    }
    
    
    
    func resetConditionWithConditionList(_ additional:NSMutableArray) {
      
        if(additional.count <= 0){
            self.navigationItem.rightBarButtonItems=[saveItem]
            self.tableView.reloadData()
            return
        }
       self.navigationItem.rightBarButtonItems=[saveItem,editItem]
        conditionList.removeAllObjects()
        let theConditionList = TopDataManager.shared.getAdditionWithConditionInfoList(additional as! Array<GLConditionInfo>)
        conditionList.addObjects(from: theConditionList)
      
        self.tableView.reloadData()
    }
    
    
    func macroConditionGetResp(notificatin: Notification) {//请求条件回复
        processTimerStop()
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            self.resetConditionWithConditionList(info.additional)
            GlobarMethod.notifySuccess()
        } else {
            GlobarMethod.notifyFailed()
        }
        
        
        
    }
    func macroConditionOrderResp(notificatin: Notification) {//家庭请求条件回复
        processTimerStop()
        let info: TopMacroAckInfo = notificatin.object as! TopMacroAckInfo
        if info.state == .ok {
            GlobarMethod.notifySuccess()
        } else {
            GlobarMethod.notifyFailed()
        }
    }
    
  
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let macroConditionGet = NSNotification.Name(rawValue: "macroConditionGetResp")
        NotificationCenter.default.removeObserver(self, name: macroConditionGet, object: nil)
        
        let macroConditionOrder = NSNotification.Name(rawValue: "macroConditionOrderResp")
        NotificationCenter.default.removeObserver(self, name: macroConditionOrder, object: nil)
        
    }
    
    func initItemList(){
        
      
        let deviceList: NSMutableArray = NSMutableArray.init(array: GlobalVars.share().roomHandle.roomDeviceGetAll(TopDataManager.shared.homeId!))
        
        let conditions: NSMutableArray = NSMutableArray.init()
        var index: Int = 0
        while index <  deviceList.count {
            let deviceInfo: GLDeviceInfo = deviceList[index] as! GLDeviceInfo
            let condition :TopCondition = TopCondition.init()
            let device :TopDeviceAckInfo = TopDeviceAckInfo.init()
            device.deviceInfo = deviceInfo
            
            condition.device = device
            index += 1
            if condition.conditionType != .TopConditionTypeUnknow{
                conditions.add(condition)
            }
        }
        let timeCondition: TopCondition = TopCondition.init()
        timeCondition.conditionType = .TopConditionTypeUT
        timeCondition.usefulTime.weekDayType = .weekend
        conditions.add(timeCondition)
        
    
        for indexT  in 0...10 {
         
            let condition: TopCondition = TopCondition.init()
            let value:String = GlobalVars.share().macroHandle.getMacroBoradValueString(Int8(1))
            
            
            let conditionInfo: GLConditionInfo = GLConditionInfo.init(id: 0, order: 0, type: "device", md5: "dssdssd", subId: Int32(indexT), value: value, time: 10, week: 7, begin: 0, end: 0)
            condition.conditionInfo = conditionInfo
            conditionList.add(condition)
            
        }
        
        let condition: TopCondition = TopCondition.init()
        let conditionInfo: GLConditionInfo = GLConditionInfo.init(id: 0, order: 0, type: "valid_time", md5: "valid_time", subId: 0, value: "打开", time: 10, week: 7, begin: 0, end: 0)
        condition.conditionInfo = conditionInfo
        conditionList.add(condition)
        
        
        
        
        // 添加时间条件
        
       
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0) && (conditionList.count==0){
            let screenW: CGFloat = UIScreen.main.bounds.size.width
            let tableHeaderFooterView :UITableViewHeaderFooterView = UITableViewHeaderFooterView.init(frame: CGRect.init(x: 0, y: 0, width: screenW, height: 18))
            let theHeaderTipLabel: UILabel = UILabel.init(frame: CGRect.init(x: 16, y: 0, width: screenW - 32, height: 18))
            theHeaderTipLabel.text = NSLocalizedString("Adding start condition, pls", comment: "")
            tableHeaderFooterView.contentView.addSubview(theHeaderTipLabel)
            tableHeaderFooterView.backgroundColor = UIColor.clear
            return tableHeaderFooterView;
        }
        return UIView.init(frame:CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 8))
     
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) && (conditionList.count == 0){
          return 30
        }else{
            return 8;
        }
        
        
      
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.tableView.isEditing {
            return conditionList.count
        }
        return conditionList.count + 1
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //启动限制
        if (indexPath.section < conditionList.count){
            let condition: TopCondition = conditionList[indexPath.section] as! TopCondition
           if condition.conditionType == .TopConditionTypeUT{
                let cell: TopUsefulTimeConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopUsefulTimeConditionCell") as! TopUsefulTimeConditionCell
                cell.condition = condition
                cell.delegate = self
                cell.editBtn.isHidden = false
                return cell
            }
            
            let cell: TopConditionCell = tableView.dequeueReusableCell(withIdentifier: "TopConditionCell") as! TopConditionCell
            cell.condition = condition
            cell.editBtn.isHidden = false
            cell.delegate = self
            return cell
        }
        
        let cell: TopAddCell = TopAddCell.init(style: .default, reuseIdentifier: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == conditionList.count{
            self.performSegue(withIdentifier: "TopAddRestrictiveVC", sender: nil)
            
            
            
        }
        
    }
    
    
    
    
    
    
   
    func usefulTimeConditionCellDidClickedEditButton(condition: TopCondition) {
        
        
        
        if condition.conditionType == .TopConditionTypeUT{
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let setUsefulTimeVC: TopSetUsefulTimeVC = sb.instantiateViewController(withIdentifier: "TopSetUsefulTimeVC") as! TopSetUsefulTimeVC
            TopDataManager.shared.condition = condition
            setUsefulTimeVC.type = .UsefunTimerVCTypeConditionEdit
            setUsefulTimeVC.usefulTime = condition.usefulTime
            self.navigationController?.pushViewController(setUsefulTimeVC, animated: true)
        }
        
        
        
    }
    
   
    
    
    func conditionCellDidClickedEditButton(_ cell: TopConditionCell)  {
        let condition = cell.condition
        switch condition?.conditionType {
        case .TopConditionTypeFW?,.TopConditionTypeHI?:
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let feedbackSwitchSetVC: TopFeedfbackSwitchConditionVC = sb.instantiateViewController(withIdentifier: "TopFeedfbackSwitchConditionVC") as! TopFeedfbackSwitchConditionVC
            TopDataManager.shared.condition = condition
            feedbackSwitchSetVC.type = .TopFeedfbackSwitchConditionVCTypeEdit
            self.navigationController?.pushViewController(feedbackSwitchSetVC, animated: true)
            return
        case .TopConditionTypeTemPAndHum? :
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let temAndHumSetVC: TopTemAndHumSetVC = sb.instantiateViewController(withIdentifier: "TopTemAndHumSetVC") as! TopTemAndHumSetVC
            TopDataManager.shared.condition = condition
            temAndHumSetVC.type = .TopTemAndHumSetVCTypeEdit
            self.navigationController?.pushViewController(temAndHumSetVC, animated: true)
            return
        default:
            break
        }
        
        
        
        switch condition?.device?.slaveType {
            
        case .macroKey4?,.securityRC?,.doorSensor?,.irSensor?:
            
            let sb = UIStoryboard(name: "Macro", bundle: nil)
            let selectActionVC: TopSelectActionVC = sb.instantiateViewController(withIdentifier: "TopSelectActionVC") as! TopSelectActionVC
            TopDataManager.shared.condition = condition
            selectActionVC.type = .TopSelectActionVCTypeEdit
            var selectRro: Int = 0
            if (condition?.device?.slaveType == .macroKey4){
                selectRro = Int(GlobalVars.share().macroHandle.getRCKey(condition?.value)) - 1
            }else if(condition?.device?.slaveType == .securityRC){
                selectRro = Int(GlobalVars.share().macroHandle.getMacroBoradRoad(condition?.value)) - 1
            }else if (condition?.device?.slaveType == .irSensor) || (condition?.device?.slaveType == .irSensor){
                let isOn: Bool = (GlobalVars.share().macroHandle.getDoorMotionState(condition!.value))
                selectRro = isOn ? 1:0
            }
            selectActionVC.selectedRow = selectRro
            self.navigationController?.pushViewController(selectActionVC, animated: true)
            
        default:
            break
        }
    }
    
    

    
}



